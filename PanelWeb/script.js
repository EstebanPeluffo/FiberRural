//const API = "http:iplocal:8000";
const API = "https://fiberrural-api.onrender.com";
if (!sessionStorage.getItem("adminEmail")) {
    window.location.href = "index.html";
}

function goTo(section) {
    const sections = ["users", "reports", "active", "resolved"];
    sections.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.add("hidden");
    });
    document.getElementById(section).classList.remove("hidden");

    // Actualizar tabs activos
    sections.forEach(id => {
        const tab = document.getElementById("tab-" + id);
        if (tab) tab.classList.remove("active");
    });
    const activeTab = document.getElementById("tab-" + section);
    if (activeTab) activeTab.classList.add("active");
}

function cerrarSesion() {
    sessionStorage.removeItem("adminEmail");
    window.location.href = "index.html";
}

function badgeEstado(estado) {
    const clases = {
        "Pendiente":  "badge badge-pendiente",
        "En Proceso": "badge badge-proceso",
        "Resuelto":   "badge badge-resuelto",
    };
    return `<span class="${clases[estado] || 'badge'}">${estado}</span>`;
}

async function cambiarEstado(idReporte, nuevoEstado) {
    await fetch(`${API}/admin/reporte/${idReporte}/estado?estado=${encodeURIComponent(nuevoEstado)}`, {
        method: "PUT"
    });
    cargarDatos();
}

function filaReporte(r, mostrarSelector = true) {
    const selector = mostrarSelector ? `
        <select class="estado-select" onchange="cambiarEstado(${r.id}, this.value)">
            <option ${r.estado === 'Pendiente'  ? 'selected' : ''}>Pendiente</option>
            <option ${r.estado === 'En Proceso' ? 'selected' : ''}>En Proceso</option>
            <option ${r.estado === 'Resuelto'   ? 'selected' : ''}>Resuelto</option>
        </select>` : badgeEstado(r.estado);

    const fecha = new Date(r.fecha).toLocaleDateString('es-CO');

    return `<tr>
        <td>${r.id}</td>
        <td>${r.usuario}</td>
        <td>${r.tipo_falla}</td>
        <td>${r.descripcion}</td>
        <td>${r.direccion}</td>
        <td>${selector}</td>
        <td>${fecha}</td>
    </tr>`;
}

async function cargarDatos() {
    try {
        const stats = await fetch(`${API}/admin/stats`).then(r => r.json());
        document.getElementById("statUsuarios").textContent = stats.usuarios;
        document.getElementById("statReportes").textContent = stats.reportes;
        document.getElementById("statActivos").textContent  = stats.activos;
        document.getElementById("statResueltos").textContent = stats.resueltos;

        const usuarios = await fetch(`${API}/admin/usuarios`).then(r => r.json());
        document.getElementById("tablaUsuarios").innerHTML = usuarios.map(u => `
            <tr>
                <td>${u.id}</td>
                <td>${u.usuario}</td>
                <td>${u.email}</td>
            </tr>
        `).join("");

        const reportes = await fetch(`${API}/admin/reportes`).then(r => r.json());
        document.getElementById("tablaReportes").innerHTML = reportes.map(r => filaReporte(r, true)).join("");

        const activos = reportes.filter(r => r.estado !== "Resuelto");
        document.getElementById("tablaActivos").innerHTML = activos.map(r => filaReporte(r, true)).join("");

        const resueltos = reportes.filter(r => r.estado === "Resuelto");
        document.getElementById("tablaResueltos").innerHTML = resueltos.map(r => filaReporte(r, false)).join("");

    } catch (e) {
        console.error("Error cargando datos:", e);
    }
}

window.addEventListener("DOMContentLoaded", () => {
    goTo("reports");
    cargarDatos();
});
function filaReporte(r, mostrarSelector = true) {
    const selector = mostrarSelector ? `
        <select class="estado-select" onchange="cambiarEstado(${r.id}, this.value)">
            <option ${r.estado === 'Pendiente'  ? 'selected' : ''}>Pendiente</option>
            <option ${r.estado === 'En Proceso' ? 'selected' : ''}>En Proceso</option>
            <option ${r.estado === 'Resuelto'   ? 'selected' : ''}>Resuelto</option>
        </select>` : badgeEstado(r.estado);

    const fecha = new Date(r.fecha).toLocaleDateString('es-CO');

    return `<tr>
        <td>${r.id}</td>
        <td>${r.usuario}</td>
        <td>${r.tipo_falla}</td>
        <td>${r.descripcion}</td>
        <td>${r.direccion}</td>
        <td>${selector}</td>
        <td>${fecha}</td>
    </tr>`;
}

async function cargarDatos() {
    try {
        // Stats
        const stats = await fetch(`${API}/admin/stats`).then(r => r.json());
        document.getElementById("statUsuarios").textContent = stats.usuarios;
        document.getElementById("statReportes").textContent = stats.reportes;
        document.getElementById("statActivos").textContent  = stats.activos;
        document.getElementById("statResueltos").textContent = stats.resueltos;

        // Usuarios
        const usuarios = await fetch(`${API}/admin/usuarios`).then(r => r.json());
        document.getElementById("tablaUsuarios").innerHTML = usuarios.map(u => `
            <tr>
                <td>${u.id}</td>
                <td>${u.usuario}</td>
                <td>${u.email}</td>
            </tr>
        `).join("");

        // Todos los reportes
        const reportes = await fetch(`${API}/admin/reportes`).then(r => r.json());
        document.getElementById("tablaReportes").innerHTML = reportes.map(r => filaReporte(r, true)).join("");

        // Activos
        const activos = reportes.filter(r => r.estado !== "Resuelto");
        document.getElementById("tablaActivos").innerHTML = activos.map(r => filaReporte(r, true)).join("");

        // Resueltos
        const resueltos = reportes.filter(r => r.estado === "Resuelto");
        document.getElementById("tablaResueltos").innerHTML = resueltos.map(r => filaReporte(r, false)).join("");

    } catch (e) {
        console.error("Error cargando datos:", e);
    }
}

window.addEventListener("DOMContentLoaded", () => {
    goTo("reports");
    cargarDatos();
});