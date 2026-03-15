
# Portal - App iOS para Inversores Inmobiliarios

Aplicación iOS desarrollada en SwiftUI para gestionar inversiones inmobiliarias. Permite a los inversores visualizar su portafolio, seguir el rendimiento de sus propiedades, y consultar el historial de pagos mensuales.

## Características Principales

### Dashboard (Inicio)
- Resumen del portafolio con valor total de inversión
- Gráfica de rendimiento del portafolio
- Lista de propiedades recientes con valor y rentabilidad
- Navegación por tabs: Inicio | Propiedades | Documentos | Mi Perfil

### Propiedades
- Lista completa de propiedades con información detallada:
  - Nombre y ubicación
  - Fecha de compra
  - Valor inicial vs valor actual
  - Plusvalía con porcentaje
  - Rendimiento anual (ej: 9%)
- Detalle de propiedad con 3 tabs:
  - **Resumen**: Valores, cálculo del rendimiento, ganancia total
  - **Pagos**: Historial de pagos mensuales agrupados por año
  - **Rendimiento**: Métricas y proyección a 5 años
- Desglose de pagos mensuales (rendimiento anual pagado mensualmente)

### Autenticación
- Login con email y contraseña
- Almacenamiento seguro de tokens en Keychain
- Gestión de estado de autenticación

## Arquitectura

```
Portal/
├── Portal/
│   ├── Core/
│   │   └── Services/
│   │       ├── AuthService.swift      # Gestión de autenticación
│   │       └── KeychainService.swift  # Almacenamiento seguro
│   ├── Models/
│   │   ├── Property.swift             # Entidad de propiedad
│   │   └── PortfolioSummary.swift     # Resumen del portafolio
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift   # Lógica del dashboard
│   │   ├── PropertiesViewModel.swift  # Lógica de propiedades
│   │   └── LoginViewModel.swift       # Lógica de login
│   └── Views/
│       ├── Auth/
│       │   └── LoginView.swift
│       ├── Dashboard/
│       │   ├── HomeView.swift         # TabView principal
│       │   ├── PropertyCard.swift     # Card de propiedad
│       │   ├── PerformanceChartView.swift  # Gráfica de rendimiento
│       │   └── TotalValueCard.swift   # Card de valor total
│       └── Properties/
│           ├── PropertiesListView.swift    # Lista de propiedades
│           ├── PropertyRowView.swift       # Fila de propiedad
│           └── PropertyDetailView.swift    # Detalle de propiedad
├── PortalTests/
└── PortalUITests/
```

## Tecnologías Utilizadas

- **SwiftUI** - Framework de UI declarativo
- **Swift Charts** - Gráficas de rendimiento
- **Keychain** - Almacenamiento seguro de tokens
- **MVVM** - Patrón de arquitectura
- **async/await** - Programación asíncrona

## Modelos de Datos

### Property
```swift
struct Property {
    let id: UUID
    let name: String
    let address, city, country: String
    let currentValue, investedValue: Decimal
    let appreciationPercentage: Double
    let purchaseDate: Date
    let annualYield: Double           // Ej: 9.0 para 9%
    let monthlyPayments: [MonthlyPayment]
}
```

### MonthlyPayment
```swift
struct MonthlyPayment {
    let month: Date
    let amount: Decimal               // Pago mensual calculado
    let yieldPercentage: Double       // % mensual (anual/12)
    let isPaid: Bool
    let paidDate: Date?
}
```

## Cálculo del Rendimiento

Las propiedades tienen un **rendimiento anual del 9%** que se paga **mensualmente**:

```
Pago Mensual = Valor Invertido × (9% ÷ 12)
             = Valor Invertido × 0.75%
```

Por ejemplo, una propiedad con valor invertido de $380,000:
- Rendimiento anual: 9%
- Pago mensual: $380,000 × 0.75% = $2,850
- Pagos recibidos: $2,850 × número de meses

## Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Instalación

1. Clonar el repositorio
2. Abrir `Portal.xcodeproj` en Xcode
3. Seleccionar el simulador o dispositivo destino
4. Compilar y ejecutar (⌘+R)

## Próximas Funcionalidades

- [ ] Integración con API backend (.NET 8)
- [ ] Sincronización de datos en tiempo real
- [ ] Notificaciones push para pagos
- [ ] Descarga de documentos
- [ ] Modo offline con persistencia local
- [ ] Tests unitarios y de UI

## Backend (.NET 8)

Este proyecto iOS está diseñado para trabajar con una API backend en .NET 8 con:
- Clean Architecture (Domain, Application, Infrastructure, API)
- Entity Framework Core
- JWT Authentication con Refresh Tokens
- CQRS con MediatR
- Integración con ERP interno

## Licencia

Copyright © 2026. Todos los derechos reservados.
