import pymysql

def get_db_connection():
    connection = pymysql.connect(
        host="localhost",
        user="root",
        password="root",
        database="fiberRural",
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection