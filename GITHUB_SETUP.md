# 🚀 Guía de Publicación en GitHub

## 📋 Paso 1: Crear Repositorio en GitHub

1. Ve a [GitHub](https://github.com) e inicia sesión
2. Haz clic en el botón **"+"** en la esquina superior derecha
3. Selecciona **"New repository"**
4. Configuración del repositorio:
   - **Repository name:** `autopulse` (o el nombre que prefieras)
   - **Description:** `🚗 AutoPulse - Gestión Inteligente de Talleres Automotrices (Flutter/Dart)`
   - **Visibility:** 
     - ⚠️ **Private** (recomendado - el código no será público)
     - O **Public** (si quieres compartir el código)
   - ❌ **NO** marques "Add a README file" (ya lo tenemos)
   - ❌ **NO** marques "Add .gitignore" (ya lo tenemos)
   - ❌ **NO** selecciones licencia (ya la tenemos)
5. Haz clic en **"Create repository"**

## 📤 Paso 2: Subir el Código a GitHub

GitHub te mostrará instrucciones. Usa estas (ajusta con tu nombre de usuario):

```powershell
# Agregar el repositorio remoto (reemplaza [TU-USUARIO] con tu username de GitHub)
git remote add origin https://github.com/[TU-USUARIO]/autopulse.git

# Renombrar la rama a 'main' (si no lo está ya)
git branch -M main

# Subir todo el código
git push -u origin main
```

**Ejemplo con usuario real:**
```powershell
git remote add origin https://github.com/juanperez/autopulse.git
git branch -M main
git push -u origin main
```

Git te pedirá autenticación. Usa tu **token de acceso personal** (no tu contraseña).

### 🔑 Crear Token de Acceso Personal (si no tienes uno)

1. En GitHub, ve a **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Nombre: `AutoPulse Development`
4. Expiration: `90 days` (o el que prefieras)
5. Scopes: marca **`repo`** (acceso completo a repositorios)
6. Click **"Generate token"**
7. **⚠️ COPIA EL TOKEN INMEDIATAMENTE** (solo se muestra una vez)
8. Usa este token como contraseña cuando Git te lo pida

## 🌐 Paso 3: Publicar las Políticas de Privacidad con GitHub Pages

### Opción A: Activar GitHub Pages (Repositorio Público)

1. En tu repositorio en GitHub, ve a **Settings**
2. En el menú lateral, busca **Pages**
3. En **Source**, selecciona:
   - Branch: **`main`**
   - Folder: **`/docs`**
4. Click **"Save"**
5. Espera 1-2 minutos
6. GitHub te dará una URL como: `https://[TU-USUARIO].github.io/autopulse/`
7. ¡Listo! Tus políticas estarán públicas en esa URL

### Opción B: Repositorio Privado + GitHub Pages

Si tu repositorio es **privado**, GitHub Pages requiere una cuenta **GitHub Pro** ($4/mes).

**Alternativas gratuitas:**
- **Firebase Hosting** (ya usas Firebase)
- **Netlify** (free tier generoso)
- **Vercel** (excelente para sitios estáticos)

## 🔥 Opción Alternativa: Firebase Hosting (RECOMENDADO)

Ya que tu app usa Firebase, puedes hospedar las políticas ahí:

```powershell
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar Firebase Hosting
firebase login
firebase init hosting

# Seleccionar opciones:
# - Use existing project → selecciona tu proyecto de Firebase
# - Public directory → docs
# - Single-page app → No
# - Overwrite index.html → No

# Desplegar
firebase deploy --only hosting
```

Firebase te dará una URL como: `https://autopulse-xxxx.web.app`

## ✅ Paso 4: Actualizar los Enlaces en el Código

Una vez que tengas la URL pública, actualiza:

1. **docs/index.html** (líneas con `[TU-USUARIO]`):
```html
<a href="https://[TU-URL-AQUI]/PRIVACY_POLICY.md" target="_blank">PRIVACY_POLICY.md</a>
<a href="https://[TU-URL-AQUI]/PRIVACY_POLICY_EN.md" target="_blank">PRIVACY_POLICY_EN.md</a>
```

2. **Play Store Console** cuando subas la app:
   - Privacy policy URL: `https://[TU-URL-AQUI]/`

## 📝 Comandos Útiles de Git

```powershell
# Ver estado del repositorio
git status

# Ver commits
git log --oneline

# Ver repositorios remotos
git remote -v

# Subir cambios nuevos
git add .
git commit -m "Descripción del cambio"
git push

# Deshacer último commit (sin perder cambios)
git reset --soft HEAD~1

# Ver diferencias
git diff
```

## 🔐 Seguridad - Archivos que NO se subirán (ya configurado en .gitignore)

Estos archivos **NO** se subirán a GitHub (son confidenciales):
- ✅ `android/app/google-services.json` (Firebase Android)
- ✅ `ios/Runner/GoogleService-Info.plist` (Firebase iOS)
- ✅ `lib/firebase_options.dart` (claves de Firebase)
- ✅ `*.keystore` / `*.jks` (claves de signing)
- ✅ `key.properties` (configuración de signing)

**⚠️ NUNCA subas estos archivos a Git, ni siquiera en un repo privado.**

## 📞 Soporte

Si tienes problemas:
1. Verifica que Git esté instalado: `git --version`
2. Verifica que estés autenticado: `git remote -v`
3. Revisa mensajes de error en PowerShell
4. Consulta [GitHub Docs](https://docs.github.com)

## 🎉 ¡Listo!

Una vez completados estos pasos:
- ✅ Tu código estará respaldado en GitHub
- ✅ Las políticas de privacidad estarán públicas
- ✅ Tendrás control de versiones
- ✅ Podrás trabajar desde múltiples equipos

---

**Siguiente paso:** Configurar el signing de Android para publicar en Play Store.
