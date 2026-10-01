<p align="center"><img src="logo/axe.svg" alt="AXE" width="96" height="96"></p>

<h1 align="center">AXE</h1>
<p align="center"><b>Optimizador de Windows para juegos. Mide el efecto real, revierte con fidelidad y dice cuándo un tweak es placebo.</b></p>

---

## Instalar (1 minuto)

**Requisitos:** Windows 10/11 (64 bits) y PowerShell 5.1 (viene con Windows). Sin cuenta, sin telemetría.

### Opción A — un comando

Abre PowerShell y ejecuta:

```powershell
irm https://raw.githubusercontent.com/CARTY240HZ/AXE-installer/main/Get-AXE.ps1 | iex
```

Descarga la última release, **verifica el SHA256** y ejecuta el instalador. Si el hash no cuadra, aborta sin instalar.

### Opción B — a mano

1. Descarga `AXE-<versión>.zip` y `SHA256SUMS` desde [Releases](../../releases/latest).
2. Comprueba el hash: `(Get-FileHash .\AXE-1.1.1.zip).Hash.ToLower()` debe coincidir con `SHA256SUMS`.
3. Extrae el ZIP y ejecuta `Install-AXE.ps1` **como administrador**.
4. Abre **AXE** desde el menú Inicio.

Instala en `Program Files\AXE` (binarios protegidos) y `ProgramData\AXE` (snapshots). No crea tareas programadas ni procesos de fondo. Las actualizaciones son manuales.

> **Aviso honesto:** esta release **no está firmada** (proyecto gratuito, sin certificado de firma de código). SmartScreen avisará, así que verificar el hash es obligatorio. Si el ZIP conserva la marca de descarga, lanza `powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-AXE.ps1 -AllowUnsigned`.

## Probar sin instalar

```bat
AXE.bat -SelfTest
```

Valida la integridad del catálogo (82 tweaks, 112 comprobaciones) sin tocar el sistema ni pedir admin. Desde una carpeta clonada AXE **bloquea las operaciones elevadas** a propósito: solo se aplican tweaks desde la copia instalada.

## Desinstalar

Revierte los tweaks desde la app (**Revertir todo**) antes de desinstalar. Después borra `Program Files\AXE`, `ProgramData\AXE` y el acceso del menú Inicio.

## Por qué confiar en esto

- **Auditable:** el motor es PowerShell abierto. `dist/AXE.ps1` es la concatenación de 31 módulos; fuente, tests y CI viven en el repositorio de desarrollo.
- **Verificable:** cada release publica `SHA256SUMS` y `sbom.json` (CycloneDX) con los componentes de terceros.
- **Honesto:** la mayoría de tweaks mueven el FPS dentro del ruido de medición, también en las herramientas de pago. AXE lo dice y marca los probables placebo.

Guía completa, comparativa y modos CLI: [docs/GUIA-COMPLETA.md](docs/GUIA-COMPLETA.md). Historial: [CHANGELOG.md](CHANGELOG.md). Licencia: [MIT](LICENSE).
