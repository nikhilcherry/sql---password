import tkinter as tk
import pyodbc


# ---------------------- SQL CONNECTION FUNCTION ---------------------- #
def get_sql_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost,1433;"
        "DATABASE=test;"       # <- your DB name
        "UID=sa;"
        "PWD=Nikhil@123;"
    )


# ---------------------- CREATE TABLE IF NOT EXISTS ---------------------- #
def create_table():
    conn = get_sql_connection()
    cursor = conn.cursor()

    cursor.execute("""
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
    CREATE TABLE users (
        username VARCHAR(50) PRIMARY KEY,
        password VARCHAR(50)
    )
    """)

    conn.commit()
    cursor.close()
    conn.close()


# ---------------------- BUTTON FUNCTIONS ---------------------- #

def submit_action():
    user = username_text.get()
    pwd = password_text.get()

    conn = get_sql_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Creds WHERE username=? AND password=?", (user, pwd))
    result = cursor.fetchone()

    if result:
        label_msg.config(text="Login Successful", fg="green")
    else:
        label_msg.config(text="Login Failed", fg="red")

    cursor.close()
    conn.close()


def check_action():
    pwd = password_text.get()

    if pwd and pwd[0].isupper() and len(pwd) >= 8 and any(char.isdigit() for char in pwd):
        label_msg.config(text="Strong Password", fg="green")
        save_button = tk.Button(main_window, text="Save", command=save_action)
        save_button.grid(row=3, column=2, padx=5)
    else:
        label_msg.config(text="Weak Password", fg="red")
        username_text.delete(0, tk.END)
        password_text.delete(0, tk.END)
        username_text.focus()


def save_action():
    user = username_text.get()
    pwd = password_text.get()

    if not user or not pwd:
        label_msg.config(text="Enter both username and password", fg="red")
        return

    conn = get_sql_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("INSERT INTO Creds (username, password) VALUES (?, ?)", (user, pwd))
        conn.commit()
        label_msg.config(text="Credentials Saved to SQL!", fg="green")
    except pyodbc.IntegrityError:
        label_msg.config(text="Username already exists!", fg="red")

    cursor.close()
    conn.close()


def clear_action():
    username_text.delete(0, tk.END)
    password_text.delete(0, tk.END)
    label_msg.config(text="")


# ---------------------- GUI SETUP ---------------------- #

main_window = tk.Tk()
main_window.geometry("450x350")
main_window.title("SQL Login System")

# Heading
label1 = tk.Label(main_window, text="Enter Username and Password", font=("Arial", 12))
label1.grid(row=0, column=1, pady=10)

# Username
tk.Label(main_window, text="Username").grid(row=1, column=0, padx=5, pady=10)
username_text = tk.Entry(main_window)
username_text.grid(row=1, column=1, padx=5, pady=10)

# Password
tk.Label(main_window, text="Password").grid(row=2, column=0, padx=5, pady=10)
password_text = tk.Entry(main_window, show="*")
password_text.grid(row=2, column=1, padx=5, pady=10)

# Buttons
tk.Button(main_window, text="Check", command=check_action).grid(row=3, column=1, padx=5)
tk.Button(main_window, text="Submit", command=submit_action).grid(row=3, column=0, padx=5)
tk.Button(main_window, text="Clear", command=clear_action).grid(row=3, column=3, padx=5)

# Output label
label_msg = tk.Label(main_window, text="")
label_msg.grid(row=10, column=1, pady=10)

# Create table when app starts
create_table()

main_window.mainloop()
