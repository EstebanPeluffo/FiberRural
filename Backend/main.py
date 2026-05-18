from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from modelos import LoginData, RegistroData, RecuperarData, CambiarPasswordData, ReporteData, AdminLoginData
from consultas import (
    get_user,
    get_user_by_email,
    usuario_existe,
    email_existe,
    crear_usuario,
    actualizar_password,
    verificar_password,
    crear_reporte,
    get_admin_by_email,
    get_total_usuarios,
    get_total_reportes,
    get_reportes_activos,
    get_reportes_resueltos,
    get_todos_reportes,
    get_todos_usuarios,
    actualizar_estado_reporte,
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── APP MÓVIL ──────────────────────────────────────

@app.post("/login")
def login(data: LoginData):
    user = get_user(data.usuario)
    if not user:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    if not verificar_password(data.password, user["password"]):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    return {"success": True, "id": user["id"], "usuario": user["usuario"]}

@app.post("/registro")
def registro(data: RegistroData):
    if usuario_existe(data.usuario):
        raise HTTPException(status_code=400, detail="El usuario ya está en uso")
    if email_existe(data.email):
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    exito = crear_usuario(data.usuario, data.password, data.email)
    if not exito:
        raise HTTPException(status_code=500, detail="Error al crear el usuario")
    return {"success": True, "mensaje": "Usuario registrado correctamente"}

@app.post("/verificar-email")
def verificar_email(data: RecuperarData):
    user = get_user_by_email(data.email)
    if not user:
        raise HTTPException(status_code=404, detail="No existe una cuenta con ese email")
    return {"success": True, "mensaje": "Email verificado"}

@app.post("/cambiar-password")
def cambiar_password(data: CambiarPasswordData):
    actualizado = actualizar_password(data.email, data.nueva_password)
    if not actualizado:
        raise HTTPException(status_code=404, detail="No se encontró el usuario")
    return {"success": True, "mensaje": "Contraseña actualizada correctamente"}

@app.post("/crear-reporte")
def crear_reporte_endpoint(data: ReporteData):
    exito = crear_reporte(data.id_usuario, data.tipo_falla, data.descripcion, data.direccion)
    if not exito:
        raise HTTPException(status_code=500, detail="Error al crear el reporte")
    return {"success": True, "mensaje": "Reporte creado correctamente"}

# ── PANEL WEB ADMIN ────────────────────────────────

@app.post("/admin/login")
def admin_login(data: AdminLoginData):
    admin = get_admin_by_email(data.email)
    if not admin:
        raise HTTPException(status_code=401, detail="Administrador no encontrado")
    if data.password != admin["password"]:
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    return {"success": True, "email": admin["email"]}

@app.get("/admin/stats")
def admin_stats():
    return {
        "usuarios": get_total_usuarios(),
        "reportes": get_total_reportes(),
        "activos": get_reportes_activos(),
        "resueltos": get_reportes_resueltos(),
    }

@app.get("/admin/reportes")
def admin_reportes():
    reportes = get_todos_reportes()
    for r in reportes:
        if r.get("fecha"):
            r["fecha"] = str(r["fecha"])
    return reportes

@app.get("/admin/usuarios")
def admin_usuarios():
    return get_todos_usuarios()

@app.put("/admin/reporte/{id_reporte}/estado")
def cambiar_estado(id_reporte: int, estado: str):
    estados_validos = ["Pendiente", "En Proceso", "Resuelto"]
    if estado not in estados_validos:
        raise HTTPException(status_code=400, detail="Estado inválido")
    actualizado = actualizar_estado_reporte(id_reporte, estado)
    if not actualizado:
        raise HTTPException(status_code=404, detail="Reporte no encontrado")
    return {"success": True, "mensaje": "Estado actualizado"}