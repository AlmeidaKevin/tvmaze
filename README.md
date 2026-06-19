# 📺 SeriesVault

App móvil Flutter para gestionar una colección personal de series, integrada con la API pública de **TVMaze** y **MongoDB Atlas**.

---

## 👤 Integrante

- Kevin Almeida

---


<p align="center">[LA APLICACION MOVIL]</p>
<p align="center">
  <img width="45%" height="1600" alt="1" src="https://github.com/user-attachments/assets/6aa2620d-b1c6-49a9-a00d-dba0019fd105" />
  <img width="45%" height="1600" alt="2" src="https://github.com/user-attachments/assets/4a2d02f1-f343-4864-81d1-7c7f531eac11" />
  <img width="45%" height="1600" alt="3" src="https://github.com/user-attachments/assets/3308ecbe-1d54-41ba-96b9-de397564871e" />
  <img width="45%" height="1600" alt="4" src="https://github.com/user-attachments/assets/7dc03df6-5166-4740-a585-4fb16a86de69" />
  <img width="45%" height="1600" alt="5" src="https://github.com/user-attachments/assets/cd2031ce-ab7e-467a-a855-a6c81f152365" />
  <img width="45%" height="1600" alt="6" src="https://github.com/user-attachments/assets/87bbc730-73a4-4d91-998c-bf7037e3fdb8" />
  <img width="45%" height="1600" alt="7" src="https://github.com/user-attachments/assets/75f82995-d780-49f3-9b02-1c7d51b75a78" />
  <img width="45%" height="1600" alt="8" src="https://github.com/user-attachments/assets/03e62361-2089-488a-9a96-43783afbf6b2" />
  <img width="45%" height="1600" alt="9" src="https://github.com/user-attachments/assets/2628f25a-cccc-4bf9-b1bb-e69efd01148e" />
  <img width="45%" height="1600" alt="10" src="https://github.com/user-attachments/assets/0b96f292-5e66-4f5d-9d65-0388c567ee38" />
  <img width="45%" height="1600" alt="11" src="https://github.com/user-attachments/assets/a8bfe365-2d8f-49ba-9445-79ca8aa4f696" />
</p>


---

## 🛠️ Requisitos previos

Antes de correr el proyecto necesitas tener instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.0 o superior)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/) con la extensión de Flutter
- Un emulador Android/iOS o un dispositivo físico conectado
- Una cuenta gratuita en [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)

Verifica que Flutter esté bien instalado con:
```bash
flutter doctor
```

---

## ⚙️ Configuración de MongoDB Atlas

1. Entra a [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas) y crea una cuenta gratuita.
2. Crea un **Cluster gratuito (M0)**.
3. En **Database Access** → **Add New Database User**: crea un usuario con contraseña y anótalos.
4. En **Network Access** → **Add IP Address** → selecciona **Allow Access from Anywhere** (`0.0.0.0/0`).
5. En **Database** → **Browse Collections** → **Add My Own Data**:
   - Database name: `seriesvault`
   - Collection name: `series`
6. En **Database** → **Connect** → **Drivers** → selecciona **Node.js** → copia el connection string. Se ve así:
   ```
   mongodb+srv://USUARIO:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
7. Agrega el nombre de la base de datos antes del `?`:
   ```
   mongodb+srv://USUARIO:PASSWORD@cluster0.xxxxx.mongodb.net/seriesvault?retryWrites=true&w=majority
   ```

---

## 📥 Instalación y ejecución

### 1. Clona el repositorio
```bash
git clone https://github.com/AlmeidaKevin/tvmaze.git
cd tvmaze
```

### 2. Pega tu connection string de MongoDB Atlas
Abre el archivo `lib/services/mongo_service.dart` y reemplaza la línea:
```dart
static const _connectionString =
    'mongodb+srv://USUARIO:PASSWORD@cluster.mongodb.net/seriesvault?retryWrites=true&w=majority';
```
con tu connection string real.

### 3. Instala las dependencias
```bash
flutter pub get
```

### 4. Conecta un dispositivo o inicia un emulador
```bash
# Ver dispositivos disponibles
flutter devices

# Iniciar emulador Android (si tienes Android Studio)
flutter emulators --launch <emulator_id>
```

### 5. Corre la app
```bash
flutter run
```

Para correr en modo release:
```bash
flutter run --release
```

---

## 📡 API utilizada: TVMaze

| Endpoint | Descripción |
|----------|-------------|
| `GET /shows?page={n}` | Lista paginada de series (250 por página, empieza en `0`) |
| `GET /search/shows?q={query}` | Búsqueda por nombre |
| `GET /shows/{id}` | Detalle completo de una serie |

- **Base URL:** `https://api.tvmaze.com`
- **Autenticación:** No requiere API key
- **Paginación:** Devuelve `404` cuando no hay más páginas (usado para detener el infinite scrolling)

---

## 📱 Pantallas

| # | Pantalla | Descripción |
|---|----------|-------------|
| 1 | `HomePage` | Menú principal con buscador integrado |
| 2 | `CollectionPage` | CRUD completo + infinite scroll + pull to refresh |
| 3 | `FormPage` | Formulario para crear y editar series con validaciones |
| 4 | `DetailPage` | Detalle de serie guardada localmente |
| 5 | `ApiExplorerPage` | Catálogo TVMaze con infinite scrolling y marcas de guardado |
| 6 | `TVMazeDetailPage` | Detalle completo de serie desde TVMaze con botón guardar |
| 7 | `SearchPage` | Búsqueda simultánea en colección local y TVMaze (tabs) |
| 8 | `TopRatedPage` | Top 50 series mejor puntuadas de TVMaze |
| 9 | `GenresPage` | Filtro por género con resultados paginados |
| 10 | `StatsPage` | Estadísticas de la colección con gráfica de géneros |
| 11 | `AboutPage` | Información del proyecto, integrante y tecnologías |

---

## ✅ Funcionalidades

- CRUD completo en MongoDB Atlas (crear, listar, editar, eliminar, detalle)
- Consumo de TVMaze API sin API key
- Infinite scrolling con `ScrollController` en explorador y géneros
- Búsqueda en paralelo: colección local + TVMaze
- Marca visual en series ya guardadas (✅ verde en poster y borde de card)
- Detección de duplicados al guardar desde TVMaze
- Pull to refresh en la colección
- `AlertDialog` de confirmación al eliminar
- `SnackBar` en todas las operaciones
- Imágenes en caché con `cached_network_image`
- Manejo de errores de red y respuestas 404

---

## 🗂️ Estructura del proyecto

```
lib/
├── main.dart
├── theme.dart
├── models/
│   └── serie.dart
├── services/
│   ├── mongo_service.dart
│   └── tvmaze_service.dart
├── screens/
│   ├── home_page.dart
│   ├── collection_page.dart
│   ├── form_page.dart
│   ├── detail_page.dart
│   ├── api_explorer_page.dart
│   ├── tvmaze_detail_page.dart
│   ├── search_page.dart
│   ├── top_rated_page.dart
│   ├── genres_page.dart
│   ├── stats_page.dart
│   └── about_page.dart
└── widgets/
    └── serie_card.dart
```

---

## 📦 Dependencias principales

```yaml
http: ^1.2.1                    # Peticiones HTTP a TVMaze
mongo_dart: ^0.10.2             # Conexión con MongoDB Atlas
uuid: ^4.3.3                    # Generación de IDs únicos
cached_network_image: ^3.3.1    # Caché de imágenes
flutter_html: ^3.0.0-beta.2     # Renderizado de HTML en sinopsis
```
