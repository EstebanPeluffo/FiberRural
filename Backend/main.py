from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
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
    get_reportes_usuario,
)
from jose import JWTError, jwt
from datetime import datetime, timedelta

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── JWT CONFIG ─────────────────────────────────────
SECRET_KEY = "fiberrural_secret_key_2026"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 horas

security = HTTPBearer()

def crear_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verificar_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        usuario = payload.get("sub")
        if usuario is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")

# ── APP MÓVIL ──────────────────────────────────────

@app.post("/login")
def login(data: LoginData):
    user = get_user(data.usuario)
    if not user:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    if not verificar_password(data.password, user["password"]):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    
    token = crear_token({"sub": user["usuario"], "id": user["id"]})
    
    return {
        "success": True,
        "id": user["id"],
        "usuario": user["usuario"],
        "token": token
    }

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
def crear_reporte_endpoint(data: ReporteData, token: dict = Depends(verificar_token)):
    exito = crear_reporte(data.id_usuario, data.tipo_falla, data.descripcion, data.direccion)
    if not exito:
        raise HTTPException(status_code=500, detail="Error al crear el reporte")
    return {"success": True, "mensaje": "Reporte creado correctamente"}

@app.get("/reportes/{id_usuario}")
def reportes_usuario(id_usuario: int, token: dict = Depends(verificar_token)):
    reportes = get_reportes_usuario(id_usuario)
    for r in reportes:
        if r.get("fecha"):
            r["fecha"] = str(r["fecha"])
    return reportes

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