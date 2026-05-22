import pymysql

def get_db_connection():
    connection = pymysql.connect(
        host="sql10.freesqldatabase.com",
        user="sql10827401",
        password="6FmDYnAlHQ",
        database="sql10827401",
        port=3306,
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection