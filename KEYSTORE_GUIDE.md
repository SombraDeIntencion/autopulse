# 🔐 Guía de Gestión de Keystores para Play Store

## ℹ️ Estado Actual del Proyecto

**✅ BUENAS NOTICIAS:** Tu proyecto **NO tiene keystores todavía** porque es nuevo y solo está configurado para desarrollo (debug signing).

**🔒 SEGURO:** Esto significa que NO hay archivos sensibles que puedan filtrarse en GitHub.

## 📋 Qué es una Keystore

Una **keystore** es un archivo que contiene tu **clave de firma digital**. Es como tu "firma autógrafa" para la app:
- Google Play Store la usa para verificar que **TÚ** eres quien sube las actualizaciones
- ⚠️ **SI LA PIERDES**, no podrás actualizar tu app NUNCA (tendrás que crear una app nueva)
- ⚠️ **SI LA ROBAN**, alguien más podría subir versiones maliciosas de tu app

## 🆕 Cuándo Crear la Keystore

**AHORA NO.** Créala justo antes de publicar en Play Store por primera vez:

1. ✅ Cuando termines de desarrollar todas las funciones
2. ✅ Cuando hayas probado la app completamente
3. ✅ Cuando estés listo para subir a Play Store

**Ventajas de esperar:**
- No la tendrás "dando vueltas" tanto tiempo (menos riesgo)
- Solo la crearás cuando realmente la necesites

## 🔨 Cómo Crear la Keystore (Cuando Estés Listo)

### Paso 1: Generar la Keystore

```powershell
# Ir al directorio de Android
cd android

# Crear la keystore (te pedirá contraseñas e información)
keytool -genkey -v -keystore C:\BackupsDeApps\autopulse-release.keystore -alias autopulse -keyalg RSA -keysize 2048 -validity 10000
```

**Información que te pedirá:**
- **Contraseña de keystore:** (elige una FUERTE, guárdala en un gestor de contraseñas)
- **Contraseña de alias:** (puede ser la misma)
- **Nombre y apellido:** Tu nombre o "AutoPulse"
- **Unidad organizacional:** Tu empresa o "Desarrollo Independiente"
- **Organización:** Tu nombre o empresa
- **Ciudad/Localidad:** Tu ciudad
- **Estado/Provincia:** Tu estado
- **Código de país:** MX (o tu país)

### Paso 2: Crear archivo key.properties

```powershell
# Crear el archivo de configuración
New-Item -Path "android\app\key.properties" -ItemType File -Force
```

**Contenido de `android/app/key.properties`:**
```properties
storePassword=TU_CONTRASEÑA_KEYSTORE
keyPassword=TU_CONTRASEÑA_ALIAS
keyAlias=autopulse
storeFile=C:\\BackupsDeApps\\autopulse-release.keystore
```

⚠️ **IMPORTANTE:** Este archivo YA está en `.gitignore` y NO se subirá a GitHub.

### Paso 3: Configurar build.gradle.kts

Necesitarás modificar `android/app/build.gradle.kts` para usar la keystore en release builds.

## 💾 Sistema de Backup de Keystores

### Ubicación de Backups

```
C:\BackupsDeApps\
├── autopulse-release.keystore          ← Tu keystore
├── autopulse-key.properties            ← Backup de configuración
└── autopulse-keystore-info.txt         ← Contraseñas y alias (encriptado)
```

### Script de Backup Automático (Cuando Tengas Keystore)

```powershell
# Backup completo con fecha
$backupDir = "C:\BackupsDeApps\AutoPulse_Backup_$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -Path $backupDir -ItemType Directory -Force

# Copiar keystore
Copy-Item "C:\BackupsDeApps\autopulse-release.keystore" -Destination "$backupDir\"

# Copiar configuración
Copy-Item "android\app\key.properties" -Destination "$backupDir\autopulse-key.properties"

Write-Host "✅ Backup creado en: $backupDir"
```

### Backup en la Nube (RECOMENDADO)

⚠️ **ENCRIPTA SIEMPRE** antes de subir a la nube:

#### Opción A: Google Drive (con encriptación)
```powershell
# Comprimir con contraseña (requiere 7-Zip)
7z a -p -mhe=on "C:\BackupsDeApps\autopulse-keystore.7z" "C:\BackupsDeApps\autopulse-release.keystore" "android\app\key.properties"

# Subir manualmente el archivo .7z a Google Drive
```

#### Opción B: USB Encriptada (MÁS SEGURO)
1. Comprar USB pequeña (8GB suficiente)
2. Usar BitLocker (Windows Pro) o VeraCrypt (gratis)
3. Guardar en caja fuerte o lugar seguro

## 🛡️ Mejores Prácticas de Seguridad

### ✅ HACER:
1. **Guardar en múltiples lugares físicos:**
   - Disco duro principal (C:\BackupsDeApps)
   - USB encriptada en lugar seguro
   - Nube encriptada (Google Drive con 7-Zip)
   - Backup en otro disco duro/computadora

2. **Usar gestor de contraseñas:**
   - Guarda contraseñas en Bitwarden, 1Password, LastPass
   - Anota en papel y guarda en caja fuerte

3. **Contraseñas fuertes:**
   - Mínimo 16 caracteres
   - Mezcla de letras, números, símbolos
   - Diferente a todas tus otras contraseñas

4. **Verificar backups:**
   - Cada 3-6 meses, verifica que los backups funcionen
   - Intenta firmar una APK de prueba

### ❌ NUNCA:
1. ❌ Subir keystore a GitHub/GitLab (ni en repos privados)
2. ❌ Enviar por email/WhatsApp/Telegram
3. ❌ Compartir con nadie (ni siquiera "confiables")
4. ❌ Usar contraseñas débiles tipo "123456" o "autopulse"
5. ❌ Guardar solo en un lugar (un disco puede fallar)
6. ❌ Subir a Google Drive sin encriptar

## 📱 Google Play App Signing (Alternativa Moderna)

**RECOMENDADO:** Deja que Google maneje la keystore de producción.

### Ventajas:
- ✅ Google guarda la keystore de producción
- ✅ Si pierdes tu "upload key", Google puede resetearla
- ✅ Más seguro (infraestructura de Google)
- ✅ Permite cambiar tu upload key si se compromete

### Cómo funciona:
1. Tú creas una **upload key** (keystore local)
2. Firmas el primer APK/AAB con tu upload key
3. Google re-firma con su **app signing key** (la real)
4. Si pierdes tu upload key, Google te da una nueva

### Configurar (cuando subas a Play Store):
1. En Play Console → App → Setup → App signing
2. Elegir: **"Let Google manage and protect your app signing key"**
3. Subir tu primer APK/AAB firmado con tu upload key
4. ¡Listo! Google maneja el resto

## 🔄 Proceso Completo para Publicación

### Fase 1: Desarrollo (AHORA)
- ✅ Desarrollar la app
- ✅ Probar en emuladores y dispositivos reales
- ✅ Usar debug signing (automático)

### Fase 2: Pre-Producción (Antes de publicar)
1. Crear upload keystore
2. Configurar key.properties
3. Modificar build.gradle.kts para release signing
4. Hacer 3+ backups de la keystore
5. Guardar contraseñas en gestor de contraseñas

### Fase 3: Primera Publicación
1. Generar release APK/AAB firmado
2. Crear cuenta de Play Store Developer ($25 pago único)
3. Activar Google Play App Signing
4. Llenar información de la app (descripciones, capturas, etc.)
5. Subir APK/AAB firmado
6. Enviar a revisión

### Fase 4: Actualizaciones
1. Desarrollar nueva versión
2. Incrementar versionCode en build.gradle.kts
3. Firmar con la MISMA keystore
4. Subir a Play Store

## 📞 Recuperación de Emergencia

### Si pierdes la keystore:

#### Con Google Play App Signing (RECOMENDADO):
✅ Contacta a Google Support → Te dan nueva upload key → Sigues actualizando

#### Sin Google Play App Signing:
❌ **NO HAY RECUPERACIÓN**
- No puedes actualizar la app NUNCA
- Debes publicar una app completamente nueva
- Pierdes todos los usuarios, reviews, ratings

**Por eso es CRÍTICO hacer backups.**

## 🎯 Checklist Rápido para Cuando Publiques

```
📋 ANTES DE CREAR LA KEYSTORE:
□ Tengo un gestor de contraseñas instalado
□ Tengo acceso a C:\BackupsDeApps
□ Tengo una USB disponible para backup
□ Tengo acceso a Google Drive u otra nube

📋 AL CREAR LA KEYSTORE:
□ Usar contraseña fuerte (16+ caracteres)
□ Guardar contraseña en gestor inmediatamente
□ Anotar contraseña en papel como backup
□ Verificar que key.properties esté en .gitignore

📋 DESPUÉS DE CREAR LA KEYSTORE:
□ Backup en C:\BackupsDeApps
□ Backup en USB encriptada
□ Backup en nube (encriptado con 7-Zip)
□ Backup en otra computadora/disco
□ Probar firmar una APK de prueba
□ Verificar que NO se suba a Git (git status)

📋 EN PLAY STORE CONSOLE:
□ Activar Google Play App Signing
□ Verificar que Google tiene tu app signing key
□ Guardar la información del certificado
```

## 🔍 Verificar que Keystore NO está en Git

```powershell
# Ver archivos ignorados
git status --ignored

# Buscar referencias a keystore
git log --all --full-history -- "*.keystore" "*.jks" "*key.properties"

# Si aparece algo, NUNCA hagas push y contacta para ayuda
```

## 📚 Recursos Adicionales

- [Documentación oficial de firma de apps de Android](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Documentación de keytool](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/keytool.html)

## 🎉 Resumen

1. **AHORA:** No hagas nada, tu proyecto está seguro sin keystores
2. **CUANDO TERMINES LA APP:** Crea la keystore siguiendo esta guía
3. **PRIMERA VEZ:** Activa Google Play App Signing (te salva la vida)
4. **SIEMPRE:** Haz backups en 3+ lugares diferentes
5. **NUNCA:** Compartas la keystore con nadie

---

**¿Preguntas? Revisa esta guía cuando estés listo para publicar. ¡Éxito con tu app! 🚀**
