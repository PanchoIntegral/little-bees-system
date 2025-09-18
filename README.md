# Little Bee's POS System

## Descripción General

Little Bee's POS System es una aplicación completa de punto de venta (Point of Sale) diseñada específicamente para pequeñas y medianas empresas. El sistema combina una arquitectura moderna de microservicios con tecnologías robustas para ofrecer una solución integral de gestión comercial.

## Arquitectura del Sistema

### Stack Tecnológico

**Backend:**
- **Framework:** Ruby on Rails 7.2.0
- **Base de Datos:** PostgreSQL 16 (producción) / SQLite3 (desarrollo)
- **Caché & Jobs:** Redis 7 con Sidekiq
- **Autenticación:** JWT + Devise
- **Contenedores:** Docker & Docker Compose

**Frontend:**
- **Framework:** Vue.js 3.4.21 con Composition API
- **Build Tool:** Vite 5.2.8
- **Estado:** Pinia 2.1.7
- **UI Framework:** Tailwind CSS 3.4.3
- **Routing:** Vue Router 4.3.0
- **Lenguaje:** TypeScript 5.4.0

**Infraestructura:**
- **Contenedores:** Docker Compose para desarrollo
- **Proxy:** Vite dev server proxy para API
- **Almacenamiento:** Active Storage para imágenes
- **Red:** Bridge network para comunicación entre servicios

## Características Principales

### 🛡️ Sistema de Seguridad Avanzado

#### Autenticación Multi-Factor (2FA)
- **TOTP (Time-based One-Time Password):** Integración con aplicaciones como Google Authenticator
- **Códigos de Respaldo:** Generación automática de 10 códigos de emergencia
- **Verificación SMS:** Sistema opcional de verificación por mensaje de texto
- **QR Code:** Generación automática para configuración rápida de 2FA

#### Gestión de Sesiones
- **JWT Tokens:** Autenticación stateless con tokens seguros
- **Expiración:** Tokens con validez de 24 horas
- **Refresh Tokens:** Renovación automática de sesiones
- **Logout Seguro:** Invalidación de tokens al cerrar sesión

#### Protección de Cuentas
- **Bloqueo Automático:** Después de 5 intentos fallidos de login
- **Duración de Bloqueo:** 30 minutos de suspensión temporal
- **Tokens de Desbloqueo:** Sistema de tokens seguros para recuperación
- **Políticas de Contraseña:** Validación robusta con caracteres especiales, mayúsculas, minúsculas y números

#### Verificación de Teléfono
- **Códigos SMS:** Generación de códigos de 6 dígitos
- **Expiración:** Códigos válidos por 10 minutos
- **Verificación Opcional:** Sistema complementario al 2FA tradicional

### 👥 Sistema de Roles y Permisos

#### Jerarquía de Roles
1. **Administrador (`admin`)**
   - Acceso completo al sistema
   - Gestión de usuarios y roles
   - Configuración del sistema
   - Acceso a todos los reportes

2. **Gerente (`manager`)**
   - Gestión de productos y inventario
   - Acceso a reportes de ventas
   - Gestión de empleados
   - Configuración de ofertas y descuentos

3. **Empleado (`employee`)**
   - Procesamiento de ventas
   - Consulta de productos
   - Acceso limitado a funcionalidades básicas

#### Control de Acceso
```ruby
# Métodos de verificación de permisos en el modelo User
def can_manage_users?        # admin, manager
def can_access_reports?      # admin, manager
def admin?                   # solo admin
def manager?                 # solo manager
def employee?                # solo employee
```

### 📊 Gestión de Productos e Inventario

#### Características del Producto
- **Información Básica:** Nombre, descripción, precio, SKU único
- **Categorización:** Sistema de categorías dinámico
- **Gestión de Stock:** Control automático de inventario
- **Alertas de Stock Bajo:** Notificaciones configurables
- **Imágenes:** Almacenamiento seguro con Active Storage

#### Control de Inventario
- **Stock en Tiempo Real:** Actualización automática con cada venta
- **Umbral de Stock Bajo:** Configuración personalizada por producto
- **Estados de Stock:** En stock, stock bajo, sin stock
- **Trazabilidad:** Historial completo de movimientos

### 🛒 Sistema de Ventas

#### Procesamiento de Ventas
- **Estados:** Pendiente, completada, cancelada, reembolsada
- **Métodos de Pago:** Efectivo, tarjeta de crédito, tarjeta de débito, billetera digital
- **Clientes:** Ventas con cliente registrado o cliente de mostrador
- **Cálculos Automáticos:** Subtotales, impuestos, descuentos, totales

#### Gestión de Descuentos y Ofertas
- **Sistema Modular:** Módulo independiente de ofertas y descuentos
- **Aplicación Automática:** Descuentos aplicados según reglas configuradas
- **Flexibilidad:** Descuentos por producto o por venta completa

#### Reportes y Análisis
- **Ingresos Diarios/Mensuales:** Cálculos automáticos por período
- **Análisis de Productos:** Productos más vendidos y rentabilidad
- **Métricas de Rendimiento:** Cantidad de ventas, ticket promedio
- **Exportación:** Generación de reportes en PDF

### 🎛️ Dashboard Personalizable

#### Componentes de Dashboard
- **Widgets Dinámicos:** Sistema de widgets intercambiables
- **Métricas en Tiempo Real:** Ventas del día, stock bajo, ingresos
- **Configuración por Usuario:** Cada usuario puede personalizar su vista
- **Grid Layout:** Sistema de grilla flexible para organización

#### Métricas Disponibles
- Ventas totales del día/mes
- Productos con stock bajo
- Número de transacciones
- Ingresos por período
- Productos más vendidos

### 🔧 Configuración y Administración

#### Gestión de Usuarios
- **CRUD Completo:** Crear, leer, actualizar, eliminar usuarios
- **Activación/Desactivación:** Control de acceso granular
- **Información de Sesión:** Tracking de últimos accesos
- **Perfil de Usuario:** Gestión de información personal

#### Configuración del Sistema
- **Configuración de Dashboard:** Personalización por usuario
- **Parámetros Globales:** Tasas de impuestos, configuraciones generales
- **Backup y Restauración:** Códigos de respaldo para 2FA

## Estructura del Proyecto

```
little-bees-system/
├── Backend/                    # API Rails
│   ├── app/
│   │   ├── controllers/       # Controladores API REST
│   │   ├── models/           # Modelos ActiveRecord
│   │   ├── serializers/      # Serialización JSON
│   │   └── services/         # Lógica de negocio
│   ├── config/               # Configuración Rails
│   ├── db/                   # Migraciones y esquemas
│   └── Dockerfile.dev        # Contenedor de desarrollo
├── Frontend/                  # Aplicación Vue.js
│   ├── src/
│   │   ├── components/       # Componentes Vue reutilizables
│   │   ├── views/           # Páginas principales
│   │   ├── services/        # Servicios de API
│   │   ├── stores/          # Estado global Pinia
│   │   └── types/           # Definiciones TypeScript
│   ├── package.json         # Dependencias Node.js
│   └── vite.config.ts       # Configuración Vite
└── docker-compose.yml       # Orquestación de servicios
```

## Instalación y Desarrollo

### Prerrequisitos
- Docker y Docker Compose
- Git

### Configuración Rápida

1. **Clonar el Repositorio**
```bash
git clone <repository-url>
cd little-bees-system
```

2. **Iniciar con Docker Compose**
```bash
docker-compose up --build
```

3. **Acceder a la Aplicación**
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### Configuración Manual

#### Backend (Rails)
```bash
cd Backend
bundle install
rails db:create db:migrate db:seed
rails server -p 3001
```

#### Frontend (Vue.js)
```bash
cd Frontend
npm install
npm run dev
```

## API Documentation

### Endpoints Principales

#### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `POST /api/auth/register` - Registro de usuario
- `POST /api/auth/verify_two_factor` - Verificación 2FA

#### Gestión de Productos
- `GET /api/v1/products` - Listar productos
- `POST /api/v1/products` - Crear producto
- `PUT /api/v1/products/:id` - Actualizar producto
- `DELETE /api/v1/products/:id` - Eliminar producto

#### Sistema de Ventas
- `GET /api/v1/sales` - Listar ventas
- `POST /api/v1/sales` - Crear venta
- `PATCH /api/v1/sales/:id/complete` - Completar venta
- `GET /api/v1/sales/stats` - Estadísticas de ventas

#### Two-Factor Authentication
- `GET /api/v1/two_factor` - Estado del 2FA
- `POST /api/v1/two_factor/setup` - Configurar 2FA
- `POST /api/v1/two_factor/enable` - Activar 2FA
- `POST /api/v1/two_factor/disable` - Desactivar 2FA

## Modelo de Datos

### Entidades Principales

#### User (usuarios)
```ruby
# Campos principales
email, first_name, last_name, role, password_digest
two_factor_enabled, two_factor_secret, phone_number
failed_attempts, locked_at, confirmed_at
```

#### Product (productos)
```ruby
# Campos principales
name, description, price, sku, category
stock_quantity, low_stock_threshold, active
```

#### Sale (ventas)
```ruby
# Campos principales
total_amount, tax_amount, discount_amount, status
payment_method, user_id, customer_id
```

#### SaleItem (items de venta)
```ruby
# Campos principales
quantity, unit_price, line_total, discount_amount
sale_id, product_id
```

## Seguridad y Buenas Prácticas

### Medidas de Seguridad Implementadas

1. **Validación de Entrada**
   - Sanitización de parámetros
   - Validación de formatos (email, teléfono, SKU)
   - Prevención de inyección SQL con ActiveRecord

2. **Gestión de Contraseñas**
   - Hash seguro con bcrypt
   - Políticas de complejidad
   - Expiración opcional de contraseñas (90 días)

3. **Protección CORS**
   - Configuración específica para frontend
   - Headers de seguridad

4. **Auditoria y Logs**
   - Tracking de intentos de login
   - Registro de acciones críticas
   - Monitoreo de sesiones activas

### Herramientas de Seguridad

- **Brakeman:** Análisis estático de vulnerabilidades
- **RuboCop:** Estilo de código y buenas prácticas
- **JWT:** Tokens seguros para autenticación
- **ROTP:** Implementación TOTP para 2FA

## Testing

### Backend Testing
```bash
cd Backend
bundle exec rspec
```

## Contribución

### Convenciones de Código

#### Backend (Ruby)
- Seguir guías de estilo Ruby standard
- Tests obligatorios para nuevas funcionalidades
- Documentación en métodos públicos

#### Frontend (TypeScript/Vue)
- Composition API para nuevos componentes
- TypeScript para type safety
- Props tipadas en componentes


## Deployment

### Consideraciones de Producción

1. **Variables de Entorno**
   - `DATABASE_URL` para PostgreSQL
   - `REDIS_URL` para Redis
   - `SECRET_KEY_BASE` para Rails
   - `JWT_SECRET` para tokens

2. **SSL/TLS**
   - Certificados para HTTPS
   - Configuración segura de cookies

3. **Monitoreo**
   - Logs centralizados
   - Métricas de rendimiento
   - Alertas de sistema

## Soporte y Documentación

### Recursos Adicionales
- Documentación de API: `/api/docs` (en desarrollo)
- Logs de aplicación: `Backend/log/`
- Configuración de desarrollo: `docker-compose.yml`



**Desarrollado por:** Jorge Alejandro Martinez Araujo
**Versión:** 1.0.0
**Última Actualización:** Septiembre 2024
