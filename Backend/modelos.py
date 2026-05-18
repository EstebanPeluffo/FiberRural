from pydantic import BaseModel

class LoginData(BaseModel):
    usuario: str
    password: str

class RegistroData(BaseModel):
    usuario: str
    password: str
    email: str

class RecuperarData(BaseModel):
    email: str

class CambiarPasswordData(BaseModel):
    email: str
    nueva_password: str

class ReporteData(BaseModel):
    id_usuario: int
    tipo_falla: str
    descripcion: str
    direccion: str

class AdminLoginData(BaseModel):
    email: str
    password: str