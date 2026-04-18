# 🌬️ Calculadora de Calidad del Aire

Aplicación móvil desarrollada en **Flutter** que consulta de manera asíncrona la API pública de **Open-Meteo** para obtener información de contaminación atmosférica (PM2.5) según la ciudad seleccionada en Colombia, y calcula un índice de exposición diaria personalizado basado en el tiempo que el usuario pasa al aire libre.

<img width="921" height="1039" alt="image" src="https://github.com/user-attachments/assets/64193bb6-2944-4763-a51b-740938f1c4e6" />
<img width="921" height="1176" alt="image" src="https://github.com/user-attachments/assets/8bdf9513-fe66-40d3-bce7-5ae9ab416cdd" />
<img width="852" height="1355" alt="image" src="https://github.com/user-attachments/assets/c93b707c-6506-4d0f-a8cf-b082ed2da1fb" />

## 📱 Descripción

La app permite al usuario:

1. Seleccionar una **ciudad de Colombia** desde un menú desplegable.
2. Escoger una **fecha específica** mediante un selector de calendario.
3. Indicar las **horas de exposición al aire libre**.
4. Consultar en tiempo real la API de **Open-Meteo Air Quality** para obtener el promedio diario de partículas PM2.5.
5. Calcular y visualizar un **índice de exposición** junto con el **nivel de riesgo** correspondiente.

---

## 🎯 Fórmula de cálculo
índice_exposición = promedio_PM2.5 × horas_exposición

### Clasificación del riesgo

| Valor del índice | Nivel de riesgo | Color |
|------------------|-----------------|-------|
| < 100            | Bajo            | 🟢 Verde |
| 100 – 200        | Moderado        | 🟠 Naranja |
| > 200            | Alto            | 🔴 Rojo |

---

## ✨ Características principales

### 🌐 Integración con API
- Consulta **asíncrona** a la API pública de Open-Meteo Air Quality.
- No requiere API key (gratuita).
- Obtiene valores horarios de PM2.5 y calcula el promedio diario.
- Manejo de errores de red y respuestas inválidas.

### 🎨 Diseño e interfaz de usuario
- **Material Design 3** con tema personalizado.
- **Gradientes dinámicos** que cambian según el nivel de riesgo calculado.
- Cards con sombras suaves y bordes redondeados.
- Iconografía expresiva para cada nivel de riesgo.
- Animaciones sutiles al mostrar el resultado.
- Interfaz completamente responsive y desplazable.

### 🎨 Cambios de color dinámicos
El color principal de la app cambia automáticamente según el resultado:

- **Antes de calcular**: Color teal corporativo (`#00838F`).
- **Riesgo Bajo**: Verde oscuro (`#2E7D32`) con gradiente verde suave.
- **Riesgo Moderado**: Naranja (`#EF6C00`) con gradiente naranja suave.
- **Riesgo Alto**: Rojo (`#C62828`) con gradiente rojo suave.

El cambio afecta al fondo, botón, tarjeta de resultado, iconos y texto del nivel.

### 🔒 Validaciones y bloqueos de campos

#### Campo "Ciudad"
- **Dropdown** con ciudades predefinidas (no editable manualmente).
- Ciudades disponibles: Bogotá, Medellín, Cali, Barranquilla, Cartagena, Bucaramanga, Pereira, Santa Marta.
- Validación: selección obligatoria.

#### Campo "Fecha de consulta"
- Campo de **solo lectura** (`readOnly: true`).
- Se abre un **DatePicker** al tocarlo (no permite escritura manual).
- Rango permitido: desde 2020 hasta 7 días en el futuro.
- Validación: selección obligatoria.
- Formato automático: `YYYY-MM-DD`.

#### Campo "Horas de exposición"
- **Teclado numérico** con punto decimal (`TextInputType.numberWithOptions(decimal: true)`).
- **Filtro de entrada** (`inputFormatters`) con expresión regular: `^\d{0,2}(\.\d{0,2})?`
  - ✅ Acepta números (máximo 2 dígitos enteros).
  - ✅ Acepta un punto decimal con hasta 2 decimales.
  - ❌ Bloquea letras (a-z, A-Z).
  - ❌ Bloquea símbolos (`@`, `#`, `$`, `,`, espacios, etc.).
  - ❌ Bloquea copiar/pegar texto no numérico.
- Validaciones adicionales:
  - No puede estar vacío.
  - Debe ser un número válido.
  - Debe ser mayor a 0.
  - Máximo 24 horas.

### 💡 Recomendaciones personalizadas
Según el nivel de riesgo, la app muestra un mensaje informativo:

- **Bajo**: "El aire está limpio. Disfruta tus actividades al aire libre."
- **Moderado**: "Considera reducir actividades prolongadas al aire libre."
- **Alto**: "Evita actividades al aire libre. Usa mascarilla si sales."

### 📊 Información adicional en resultados
Junto al índice calculado se muestra:
- Valor promedio de **PM2.5** en µg/m³.
- Horas de exposición ingresadas.
- Icono representativo del nivel de riesgo.

---

## 🛠️ Tecnologías utilizadas

- **Flutter** 3.x (Dart SDK ^3.11.0)
- **Material Design 3**
- **http ^1.6.0** — Para peticiones HTTP asíncronas
- **Open-Meteo Air Quality API** — Fuente de datos

---

## 📂 Estructura del proyecto

calidad_aire_app/
├── lib/
│   ├── main.dart                      # Punto de entrada de la app
│   ├── models/
│   │   └── ciudad.dart                # Modelo Ciudad y lista de ciudades
│   ├── services/
│   │   └── air_quality_service.dart   # Servicio de consulta a la API
│   └── screens/
│       └── calculadora_screen.dart    # Pantalla principal
├── android/
│   └── app/src/main/AndroidManifest.xml  # Permiso de internet
├── pubspec.yaml                       # Dependencias
└── README.md


## 🌍 API utilizada

**Open-Meteo Air Quality API**  
Documentación: https://open-meteo.com/en/docs/air-quality-api
