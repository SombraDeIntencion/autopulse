# AutoPulse - Sistema Integral de Gestión de Talleres Automotrices

## 📱 Descripción
AutoPulse es una aplicación móvil para Android (optimizada para tablets) que gestiona el flujo completo de trabajo en talleres automotrices, desde la recepción hasta la entrega del vehículo.

## 🏗️ Estructura del Proyecto

### Configuración Completada ✅

#### 1. **Proyecto Base**
- `pubspec.yaml` - Dependencias de Firebase, Provider, Image Picker, Compression, etc.
- `android/app/build.gradle.kts` - SDK mínimo 35, MultiDex, Firebase
- `android/build.gradle.kts` - Classpath de Firebase y Google Services
- `android/app/src/main/AndroidManifest.xml` - Permisos (cámara, storage, internet)

#### 2. **Configuración y Tema**
- `lib/config/theme.dart` - Tema oscuro con gradientes (#E91E63, #FF6B35, #FFA500)
- `lib/config/constants.dart` - Constantes de la app, colecciones Firebase, etc.

#### 3. **Internacionalización (i18n)**
- `lib/shared/l10n/app_localizations.dart` - Clase abstracta base
- `lib/shared/l10n/translations/es.dart` - Español (completo)
- `lib/shared/l10n/translations/en.dart` - Inglés (completo)
- `lib/shared/l10n/localization_helper.dart` - Helper para cambio de idioma

**Idiomas pendientes de crear:** PT, FR, DE, IT, ZH, JA, RU (seguir mismo patrón)

#### 4. **Modelos de Datos**
- `lib/core/models/vehicle_model.dart` - Modelo de vehículo con Firestore
- `lib/core/models/order_model.dart` - Modelo de orden/servicio
- `lib/core/models/user_model.dart` - Modelo de usuario con roles y suscripción

#### 5. **Servicios**
- `lib/core/services/auth_service.dart` - Autenticación con Firebase Auth
- `lib/core/services/storage_service.dart` - Firebase Storage (subida/descarga con compresión)
- `lib/core/services/firestore_service.dart` - Operaciones CRUD en Firestore
- `lib/core/services/compression_service.dart` - Compresión de imágenes
- `lib/core/services/biometric_auth_service.dart` - Autenticación biométrica (huella/Face ID)

#### 6. **Entry Point**
- `lib/main.dart` - Inicialización de Firebase, orientación landscape, splash screen básico

## 🔐 Autenticación Biométrica

La app soporta **inicio de sesión con huella digital** (o Face ID en dispositivos compatibles):

### Flujo de Autenticación
1. **Primera vez:** Usuario se registra/inicia sesión con email/password
2. **Configuración:** Sistema pregunta si quiere habilitar biometría
3. **Accesos posteriores:** Usa huella digital para acceso rápido
4. **Respaldo:** Si falla biometría, puede usar email/password

### Ejemplo de Uso
Ver archivo completo: `lib/core/examples/auth_integration_example.dart`

```dart
final authIntegration = AuthIntegrationExample();

// Login con huella
await authIntegration.biometricLogin();

// Habilitar biometría
await authIntegration.enableBiometricAuth();
```

## 🚧 Pendiente de Implementar

### Alta Prioridad

1. **Configuración Firebase** ✅ COMPLETADO
   ```
   ✅ google-services.json instalado
   ✅ Authentication habilitado
   ✅ Firestore Database creado
   ✅ Storage configurado
   ```

2. **Assets**
   ```
   - Guardar logo en: assets/images/logo.png
   - Ejecutar: flutter pub run flutter_launcher_icons:main
   ```

3. **Servicios** ✅ COMPLETADO
   ```dart
   ✅ lib/core/services/storage_service.dart
   ✅ lib/core/services/firestore_service.dart
   ✅ lib/core/services/compression_service.dart
   ✅ lib/core/services/biometric_auth_service.dart
   ```

4. **Providers (State Management)** ✅ COMPLETADO
   ```dart
   ✅ lib/features/auth/providers/auth_provider.dart
   ✅ lib/features/workshop/providers/vehicle_provider.dart
   ✅ lib/features/workshop/providers/order_provider.dart
   ✅ lib/shared/providers/settings_provider.dart
   ```

5. **Pantallas de Autenticación** ✅ COMPLETADO
   ```dart
   ✅ lib/features/auth/pages/login_page.dart
   ✅ lib/features/auth/pages/signup_page.dart
   ✅ lib/features/auth/pages/email_verification_page.dart
   ✅ lib/features/auth/pages/forgot_password_page.dart
   ```

6. **Optimizaciones de Memoria** ✅ COMPLETADO
   - Ver detalles en `OPTIMIZATIONS.md`
   - ✅ Fugas de memoria corregidas (11 streams + 2 timers)
   - ✅ Prevención de bucles infinitos
   - ✅ Dispose apropiado en todos los providers
   - ✅ Manejo seguro de BuildContext async

### Media Prioridad

7. **Pantallas del Workshop**5. **Pantallas de Autenticación**
   ```dart
   lib/features/auth/pages/
   ├── login_page.dart
   ├── signup_page.dart
   ├── forgot_password_page.dart
   └── email_verification_page.dart
   ```

6. **Pantallas Workshop (7 Tabs)**
   ```dart
   lib/features/workshop/pages/
   ├── workshop_home_page.dart    // Pantalla principal con tabs
   ├── reception_page.dart         // Tab 1: Recepción
   ├── diagnosis_page.dart         // Tab 2: Diagnóstico
   ├── parts_page.dart             // Tab 3: Refacciones
   ├── approval_page.dart          // Tab 4: Aprobación
   ├── repair_page.dart            // Tab 5: Reparación
   ├── control_page.dart           // Tab 6: Control
   └── delivery_page.dart          // Tab 7: Entrega
   ```

7. **Widgets Reutilizables**
   ```dart
   lib/shared/widgets/
   ├── dialogs/
   │   ├── vehicle_form_dialog.dart       // Registrar vehículo
   │   ├── search_dialog.dart             // Búsqueda rápida
   │   ├── order_type_dialog.dart         // Seleccionar tipo de orden
   │   └── advanced_order_dialog.dart     // Orden avanzada completa
   ├── common/
   │   ├── gradient_button.dart           // Botón con gradiente
   │   ├── custom_input.dart              // Input estilizado
   │   ├── vehicle_card.dart              // Tarjeta de vehículo
   │   ├── workshop_navigation.dart       // Navegación tabs
   │   └── language_selector.dart         // Selector de idioma
   ```

8. **Navegación y Rutas**
   ```dart
   lib/config/routes.dart     // Definición de rutas
   ```

## 🎨 Diseño

### Colores del Gradiente
- **Primary:** #E91E63 (Pink)
- **Secondary:** #FF6B35 (Orange)
- **Tertiary:** #FFA500 (Yellow)

### Fondos
- **Background:** #000000 (Negro)
- **Surface:** #1a1a1a (Gris oscuro)
- **Surface Dark:** #0a0a0a (Gris muy oscuro)

### Workflow (7 Etapas)
1. **Recepción** - Registro inicial del vehículo
2. **Diagnóstico** - Evaluación técnica
3. **Refacciones** - Gestión de piezas
4. **Aprobación** - Autorización del cliente
5. **Reparación** - Ejecución del trabajo
6. **Control** - Calidad y verificación
7. **Entrega** - Finalización y entrega

## 📦 Dependencias Principales

```yaml
# Firebase
firebase_core: ^2.24.2          # Firebase SDK
firebase_auth: ^4.16.0          # Autenticación
cloud_firestore: ^4.14.0        # Base de datos
firebase_storage: ^11.6.0       # Almacenamiento

# State Management
provider: ^6.1.1                # State management

# Seguridad y Permisos
local_auth: ^2.1.8              # Autenticación biométrica (huella/Face ID)
permission_handler: ^11.2.0     # Permisos runtime

# Imágenes y Compresión
image_picker: ^1.0.7            # Cámara/Galería
flutter_image_compress: ^2.1.0  # Compresión de imágenes
path: ^1.9.0                    # Manipulación de paths
```

## 🚀 Comandos Útiles

### Instalación de Dependencias
```bash
flutter pub get
```

### Generar Launcher Icons (después de guardar logo)
```bash
flutter pub run flutter_launcher_icons:main
```

### Ejecutar en Modo Debug
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

### Build App Bundle (para Play Store)
```bash
flutter build appbundle --release
```

## ⚙️ Configuración Necesaria

### 1. Firebase Setup
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar app Android con package name: `com.autopulse.app`
3. Descargar `google-services.json` y colocar en `android/app/`
4. Habilitar Authentication → Email/Password
5. Crear Firestore Database (modo producción)
6. Configurar Storage

### 2. Assets
1. Guardar el logo proporcionado en `assets/images/logo.png`
2. Ejecutar `flutter pub run flutter_launcher_icons:main`

## 📝 Próximos Pasos

1. **Inmediato:**
   - Descargar google-services.json de Firebase
   - Guardar logo en assets/images/
   - Ejecutar `flutter pub get`

2. **Corto Plazo:**
   - Implementar servicios restantes (Storage, Firestore, Compression)
   - Crear providers para state management
   - Desarrollar pantallas de autenticación

3. **Mediano Plazo:**
   - Implementar las 7 pantallas del workflow
   - Crear todos los diálogos y widgets reutilizables
   - Completar los 7 idiomas restantes

4. **Largo Plazo:**
   - Testing completo
   - Configuración de signing
   - Publicación en Play Store

## � Política de Privacidad

AutoPulse toma muy en serio la privacidad de tus datos. **No recopilamos datos para venderlos, sólo son para uso interno del taller.** La aplicación no contiene anuncios ni comparte información con terceros más allá de Firebase (infraestructura de almacenamiento).

**Documentación completa:**
- 🇪🇸 **Español:** [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
- 🇬🇧 **English:** [PRIVACY_POLICY_EN.md](PRIVACY_POLICY_EN.md)

**Resumen ejecutivo:**
- ✅ Almacenamos y encriptamos tus datos de forma segura (Firebase + AES-256)
- ✅ Solo usamos los datos para que el taller funcione correctamente
- ✅ Puedes exportar o eliminar tus datos cuando quieras (30 días para eliminación completa)
- ❌ **NO vendemos** tu información
- ❌ **NO mostramos anuncios**
- ❌ **NO compartimos** con terceros (excepto Firebase como infraestructura)
- ❌ **NO hacemos tracking** publicitario

Contacto: privacy@autopulse.app

## �📄 Licencia

Proyecto privado - Todos los derechos reservados © 2026
