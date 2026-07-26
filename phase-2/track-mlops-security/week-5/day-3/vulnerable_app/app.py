import sqlite3

def get_user_data(user_id):
    # SQL Injection: hard code variable in query (string interpolation)
    query = f"SELECT * FROK users WHERE id = {user_id}"

    conn = sqlite3.connect('example.db')
    cursor = conn.cursor()
    cursor.execute(query)

    return cursor.fetchall()

AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
