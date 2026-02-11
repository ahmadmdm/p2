# Completion Report & System Documentation

## 1. PRD Summary
**Product:** Modular Restaurant/Coffee Shop POS
**Goal:** Scalable, offline-first POS for iPad with integrated QR table self-ordering.
**Target Users:** Waiters, Cashiers, Kitchen Staff, Managers, Customers (Self-Order).

### Core User Stories
- **Cashier/Waiter:** "As a server, I want to take orders offline so that service isn't interrupted by internet outages."
- **Customer:** "As a guest, I want to scan a QR code to view the menu and order without waiting for a waiter."
- **Kitchen Staff:** "As a chef, I want to see orders in real-time on a KDS to prioritize preparation."
- **Manager:** "As a manager, I want to see real-time sales reports and inventory levels."

## 2. Architecture
**Style:** Modular Monolith (NestJS) + Clean Architecture (Flutter).
**Justification:**
- **NestJS:** Provides structure, dependency injection, and easy module separation (Inventory, Orders, Auth). Scaling to microservices is possible later.
- **Flutter:** Single codebase for iOS (iPad POS), Android, and Web (Customer PWA).
- **PostgreSQL:** Reliable relational data for transactions and inventory.
- **Offline Strategy:** "Sync Queue" pattern. POS saves to local Drift DB. SyncService pushes to backend when online.

**Diagram:**
```
[Flutter POS (iPad)] --(HTTP/WS/Sync)--> [NestJS API Gateway]
                                              |
[Customer PWA (Web)] --(HTTP Public API)--> [Rate Limiter]
                                              |
                                       [Modules: Orders, Inventory, Auth, KDS]
                                              |
                                         [TypeORM]
                                              |
                                         [PostgreSQL]
```

## 3. Data Model (ERD)
**Key Entities:**
- **Product:** `id, name (JSON en/ar), price, categoryId, stationId`
- **Order:** `id, tableId, status, totalAmount, paymentStatus`
- **OrderItem:** `id, orderId, productId, quantity, modifiers (JSON)`
- **InventoryItem:** `ingredientId, warehouseId, quantity`
- **RecipeItem:** `productId, ingredientId, quantity`
- **Table:** `id, tableNumber, token (QR), status`
- **User:** `id, username, role, pin`

## 4. API Specification (Key Endpoints)

### Public API (QR Ordering)
- `GET /public-api/menu?t={token}`: Get menu for table.
- `GET /public-api/active-order?t={token}`: Get current open order for table (Multi-customer support).
- `POST /public-api/orders`: Create new order.
- `POST /public-api/orders/{id}/add-items`: Add items to existing order.
- `POST /public-api/request-bill`: Notify staff.
- `GET /public-api/captcha`: Generate captcha for suspicious requests.

### POS API (Authenticated)
- `POST /orders`: Create order (supports offline sync).
- `POST /orders/{id}/pay`: Process payment.
- `POST /orders/{id}/void`: Void order (restores stock).
- `GET /kitchen/orders`: Get active KDS orders.
- `GET /reports/sales/excel`: Export sales report to Excel.
- `GET /reports/sales/pdf`: Export sales report to PDF.

## 5. Security & Rate Limiting
- **Rate Limiting:** Implemented `ThrottlerModule` (60 req/min) globally, applied to Public API.
- **Captcha:** Lightweight Captcha service implemented (`/public-api/captcha`) to challenge suspicious requests.
- **Table Token:** Randomly generated, unguessable tokens validated per request.
- **Validation:** Server-side stock check and price calculation. Client prices are display-only.

## 6. Offline Sync Strategy (Mobile)
- **Local DB:** Drift (SQLite).
- **Queue:** `SyncQueue` table stores requests (method, endpoint, payload).
- **Process:** Background worker processes queue. On success, remove from queue. On failure (4xx), alert user. On failure (5xx/Network), retry with backoff.

## 7. Localization (RTL)
- **Backend:** `name` field is JSON `{en: "...", ar: "..."}`.
- **Frontend:** Flutter `GlobalMaterialLocalizations`. UI mirrors automatically for Arabic locale.

## 8. Status of Tasks (re.md)
- [x] Backend Build Fixed (OrdersService, InventoryService).
- [x] Transactional Inventory Management (deduct/restore stock).
- [x] QR Self-Ordering API (Create, Add Items, Active Order).
- [x] Multi-customer Table Support (Active Order Endpoint).
- [x] PWA Localization (Arabic/English).
- [x] Rate Limiting (ThrottlerGuard).
- [x] Lightweight Captcha (Infrastructure ready).
- [x] Delivery Module Integration (Provider Plugin System).
- [x] Report Exports (PDF/Excel).
- [x] Request Bill Functionality.
- [x] PWA RTL Verification.
