# POS System Specification & Technical Design

## 1. PRD Summary & User Stories

### Core Goal
Build a modular, offline-first Restaurant/Coffee Shop POS system with a Flutter-based client (iPad priority) and a robust NestJS backend. Key differentiators are the offline capability and the seamless QR Table Self-Ordering experience.

### User Stories

#### Staff (Cashier/Waiter)
*   **As a Cashier**, I want to log in quickly using a PIN or biometrics so I can start my shift.
*   **As a Waiter**, I want to select a table from the floor plan and add items to the order so the kitchen starts preparing them immediately.
*   **As a Cashier**, I need to split a bill by amount or by items to accommodate customer requests.
*   **As a Cashier**, I must be able to continue taking orders and printing receipts even if the internet is down.

#### Kitchen Staff
*   **As a Chef**, I want to see orders categorized by station (Grill, Bar) on a KDS screen.
*   **As a Chef**, I want to bump orders to "Ready" status to notify waiters.

#### Manager/Admin
*   **As a Manager**, I want to configure the menu, prices, and taxes from a web dashboard.
*   **As a Manager**, I want to see real-time sales reports to monitor branch performance.
*   **As a Manager**, I want to manage staff permissions to prevent unauthorized voids or discounts.

#### Customer (QR Ordering)
*   **As a Customer**, I want to scan a QR code on my table to view the menu without installing an app.
*   **As a Customer**, I want to customize my order (no onions, extra cheese) and submit it directly to the kitchen.

### Acceptance Criteria
*   POS App starts in < 2s.
*   Offline orders sync automatically when connection restores.
*   QR codes are unique per table and secured with a token.
*   Inventory is deducted automatically upon sale.

---

## 2. Architecture

### System Overview
We will adopt a **Modular Monolith** architecture for the backend to balance development speed with scalability, allowing for future extraction of services (e.g., Reporting, Notification) if needed.

### Tech Stack Selection & Justification

#### Client: Flutter
*   **Platforms**: iOS (iPad focus), Android, Web (Admin/KDS).
*   **State Management**: **Riverpod**.
    *   *Justification*: Compile-safe, no context dependency, great for dependency injection, and excellent testability compared to BLoC (less boilerplate) or Provider.
*   **Local Database**: **Isar**.
    *   *Justification*: Extremely fast (written in Rust), strictly typed, ACID compliant, full-text search support, and designed specifically for Flutter. Better performance than SQLite/Drift for large datasets.

#### Backend: NestJS (Node.js)
*   *Justification*: 
    *   **TypeScript**: Share DTOs/Interfaces with Flutter app.
    *   **Structure**: Angular-like module system forces clean architecture.
    *   **Ecosystem**: Native support for Microservices, WebSockets (Gateways), and OpenAPI.
*   **Database**: **PostgreSQL** (Relational integrity, JSONB support for flexible attributes).
*   **Cache/Queue**: **Redis** (Caching, Rate limiting) + **BullMQ** (Job queues for printing, emails).

### Architecture Diagram (Textual)

```mermaid
graph TD
    subgraph Client_Side
        POS[Flutter POS App]
        KDS[Flutter/Web KDS]
        QR_PWA[Next.js/React PWA]
    end

    subgraph Infrastructure
        LB[Load Balancer / Nginx]
    end

    subgraph Backend_Services
        API[NestJS API Gateway & Core]
        Worker[NestJS Worker (Async Jobs)]
    end

    subgraph Data_Layer
        DB[(PostgreSQL)]
        Cache[(Redis)]
        ObjStore[S3 MinIO]
    end

    POS -- HTTPS/WSS --> LB
    KDS -- WSS --> LB
    QR_PWA -- HTTPS --> LB
    LB --> API
    API --> DB
    API --> Cache
    API -- Events --> Worker
    Worker --> API
```

---

## 3. Data Model (ERD) & DDL

### Key Entities
*   **Tenants/Branches**: Multi-tenant isolation.
*   **Catalog**: Categories, Products, Modifiers (flexible relationship).
*   **Ordering**: Orders, OrderItems (snapshot of product data), Transactions.
*   **Inventory**: Ingredients, Recipes, StockMoves.

### Initial PostgreSQL DDL (Core Tables)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tenant & Branch
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC'
);

-- Catalog
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID REFERENCES branches(id),
    name JSONB NOT NULL, -- { "en": "Drinks", "ar": "مشروبات" }
    sort_order INT DEFAULT 0
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES categories(id),
    name JSONB NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE
);

-- Orders
CREATE TABLE tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID REFERENCES branches(id),
    name VARCHAR(50),
    token VARCHAR(255) UNIQUE NOT NULL -- For QR Security
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID REFERENCES branches(id),
    table_id UUID REFERENCES tables(id),
    order_number SERIAL,
    status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, CONFIRMED, PREPARING, READY, COMPLETED, VOID
    total_amount DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL, -- Snapshot
    unit_price DECIMAL(10, 2) NOT NULL, -- Snapshot
    quantity INT NOT NULL,
    modifiers JSONB -- Selected modifiers snapshot
);
```

---

## 4. API Specification

### Standards
*   RESTful API V1
*   Responses wrapped in standard envelope `{ data: ..., meta: ... }`
*   Snake_case for JSON properties.

### Key Endpoints

#### Authentication
*   `POST /v1/auth/login` (Staff login)
*   `POST /v1/auth/device-register` (Register POS device)

#### Menu & Catalog
*   `GET /v1/catalog/menu` (Full sync for POS)
*   `GET /v1/public/menu?t={table_token}` (Public QR Menu)

#### Orders
*   `POST /v1/orders` (Create order - supports offline sync batching)
*   `PATCH /v1/orders/{id}/status` (Update status)
*   `POST /v1/orders/{id}/pay` (Process payment)

#### Inventory
*   `POST /v1/inventory/stock-take`
*   `GET /v1/inventory/alerts`

---

## 5. Flutter App Structure & Offline Strategy

### Project Structure (Clean Architecture)
```
lib/
├── core/              # Shared utils, constants, error handling
├── data/
│   ├── datasources/   # API Client (Dio), Local DB (Isar)
│   ├── models/        # DTOs, JSON parsing
│   └── repositories/  # Implementation of Domain Repositories
├── domain/
│   ├── entities/      # Pure Dart objects
│   ├── repositories/  # Interfaces
│   └── usecases/      # Business logic (e.g., CreateOrderUseCase)
├── presentation/
│   ├── providers/     # Riverpod providers
│   ├── screens/       # UI Widgets
│   └── widgets/       # Reusable components
└── main.dart
```

### Offline Sync Strategy
1.  **Local First**: All reads/writes go to **Isar** DB first. UI updates immediately.
2.  **Sync Queue**:
    *   When an action (Create Order) happens offline, it's stored in a `SyncQueue` table in Isar.
    *   Payload: `{ id: UUID, type: 'CREATE_ORDER', payload: JSON, timestamp: ... }`
3.  **Background Service**:
    *   Monitors connectivity.
    *   On connect: Process queue FIFO.
    *   **Idempotency**: Each request has a UUID. Backend checks if this UUID was already processed to prevent duplicates on retries.
4.  **Conflict Resolution**: Server is truth. If sync fails (e.g., item out of stock), an alert is pushed to the POS for staff intervention.

---

## 6. Printing & KDS Strategy

### Printing
*   **Abstraction Layer**: `PrinterService` interface in Flutter.
*   **Implementations**:
    *   `EscPosNetworkPrinter`: For thermal printers via LAN.
    *   `BluetoothPrinter`: For portable belt printers.
*   **Routing Logic**:
    *   Map `ProductCategory` -> `PrinterStation` (e.g., Drinks -> Bar Printer).
    *   When order is confirmed, the app splits items and sends commands to respective printers.

### KDS (Kitchen Display System)
*   **Real-time**: Uses **WebSockets** (Socket.io/NestJS Gateway) to receive new orders instantly.
*   **Views**:
    *   **Expeditor View**: Full order view.
    *   **Station View**: Filtered by items (e.g., only Grill items).
*   **Interaction**: Tap to "Bump" (mark prepared). Updates POS status via API.

---

## 7. Security & RBAC

*   **Authentication**:
    *   **Staff**: PIN code (locally verified for speed if session valid) + JWT for API access.
    *   **Admin**: Email/Password + 2FA (TOTP).
*   **RBAC (Role Based Access Control)**:
    *   Defined roles: `Admin`, `Manager`, `Cashier`, `Waiter`.
    *   Permissions: `ORDER_CREATE`, `ORDER_VOID`, `DISCOUNT_APPLY`, `REPORT_VIEW`.
    *   **Implementation**: NestJS Guards check permissions. Flutter hides UI elements based on user role.
*   **Data Security**:
    *   Sensitive data (Tokens) stored in `FlutterSecureStorage`.
    *   API traffic encrypted (TLS 1.2+).

---

## 8. DevOps Plan

*   **Containerization**: Dockerfile for NestJS API. Nginx as reverse proxy.
*   **CI/CD (GitHub Actions)**:
    *   **Build**: Run tests (Unit/Integration).
    *   **Deploy Dev**: Push Docker image to registry -> Deploy to Dev server (e.g., DigitalOcean App Platform or AWS ECS).
    *   **Deploy Prod**: Manual approval trigger.
*   **Environments**:
    *   `development`: Latest commits, seed data.
    *   `staging`: Mirror of prod, for final QA.
    *   `production`: Live data, strict backups.
*   **Backups**: Automated daily PostgreSQL dumps to S3.

---

## 9. Roadmap

### Phase 1: MVP (Month 1-2)
*   Basic POS (Sell, Cart, Receipt).
*   Offline capability.
*   Simple Inventory (Deduction only).
*   One Printer support.

### Phase 2: Restaurant Core (Month 3-4)
*   Table Management (Floor plan).
*   KDS (Kitchen Display).
*   Modifiers & Combos.
*   QR Self-Ordering (Web PWA).

### Phase 3: Scale & Modules (Month 5+)
*   Delivery Integrations.
*   Advanced Reporting & Analytics.
*   Loyalty System.
*   Multi-branch management.

---

## 10. Risks & Mitigations

| Risk | Mitigation |
| :--- | :--- |
| **Network Instability** | Robust "Offline-First" architecture. All critical ops work locally. |
| **Printer Failure** | Fallback routing (e.g., if Grill printer fails, print to Main printer). |
| **Data Sync Conflicts** | Use UUIDs everywhere. Server timestamps rule. Conflict UI for cashiers. |
| **Performance (Large Menu)** | Isar DB is optimized for 100k+ records. Pagination for lists. |
