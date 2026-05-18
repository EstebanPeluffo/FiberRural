import bcrypt
from conexion import get_db_connection

def get_user(usuario):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM login WHERE usuario = %s"
            cursor.execute(sql, (usuario,))
            return cursor.fetchone()
    finally:
        connection.close()

def get_user_by_email(email):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM login WHERE email = %s"
            cursor.execute(sql, (email,))
            return cursor.fetchone()
    finally:
        connection.close()

def usuario_existe(usuario):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT id FROM login WHERE usuario = %s"
            cursor.execute(sql, (usuario,))
            return cursor.fetchone() is not None
    finally:
        connection.close()

def email_existe(email):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT id FROM login WHERE email = %s"
            cursor.execute(sql, (email,))
            return cursor.fetchone() is not None
    finally:
        connection.close()

def crear_usuario(usuario, password, email):
    password_encriptada = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "INSERT INTO login (usuario, password, email) VALUES (%s, %s, %s)"
            cursor.execute(sql, (usuario, password_encriptada, email))
            connection.commit()
            return True
    except Exception:
        connection.rollback()
        return False
    finally:
        connection.close()

def actualizar_password(email, nueva_password):
    password_encriptada = bcrypt.hashpw(nueva_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "UPDATE login SET password = %s WHERE email = %s"
            cursor.execute(sql, (password_encriptada, email))
            connection.commit()
            return cursor.rowcount > 0
    finally:
        connection.close()

def verificar_password(password_plana, password_hash):
    return bcrypt.checkpw(password_plana.encode('utf-8'), password_hash.encode('utf-8'))

def crear_reporte(id_usuario, tipo_falla, descripcion, direccion):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO detalles_reporte (id_usuario, tipo_falla, descripcion, direccion)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (id_usuario, tipo_falla, descripcion, direccion))
            connection.commit()
            return True
    except Exception:
        connection.rollback()
        return False
    finally:
        connection.close()

def get_admin_by_email(email):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM administradores WHERE email = %s"
            cursor.execute(sql, (email,))
            return cursor.fetchone()
    finally:
        connection.close()

def get_total_usuarios():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM login")
            return cursor.fetchone()["total"]
    finally:
        connection.close()

def get_total_reportes():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM detalles_reporte")
            return cursor.fetchone()["total"]
    finally:
        connection.close()

def get_reportes_activos():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM detalles_reporte WHERE estado = 'Pendiente'")
            return cursor.fetchone()["total"]
    finally:
        connection.close()

def get_reportes_resueltos():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM detalles_reporte WHERE estado = 'Resuelto'")
            return cursor.fetchone()["total"]
    finally:
        connection.close()

def get_todos_reportes():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                SELECT dr.id, l.usuario, dr.tipo_falla, dr.descripcion,
                       dr.direccion, dr.estado, dr.fecha
                FROM detalles_reporte dr
                JOIN login l ON dr.id_usuario = l.id
                ORDER BY dr.fecha DESC
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        connection.close()

def get_todos_usuarios():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, usuario, email FROM login ORDER BY id DESC")
            return cursor.fetchall()
    finally:
        connection.close()

def actualizar_estado_reporte(id_reporte, nuevo_estado):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "UPDATE detalles_reporte SET estado = %s WHERE id = %s"
            cursor.execute(sql, (nuevo_estado, id_reporte))
            connection.commit()
            return cursor.rowcount > 0
    finally:
        connection.close()