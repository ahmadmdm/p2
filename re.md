

## Role

You are a complete product + engineering team (CTO, Product Manager, Flutter Lead, Backend Architect, QA Lead, Security Engineer, DevOps). Build a premium, scalable **Restaurant/Coffee Shop POS system** that can later expand into other retail verticals via a modular/plugin architecture.

## Core Goal

Deliver:

* A **Flutter** POS app that runs smoothly on **iPad (top priority)**, tablets, and phones (iOS/Android).
* A **professional backend** (choose the best stack and justify: NestJS / Django DRF / Go), with **PostgreSQL**.
* True **offline-first** operation on the POS (sell, print, shift ops without internet), with robust sync.
* A **QR table self-order experience**: customers scan a QR/Barcode on the table, see the menu instantly, order, and optionally pay.

## 1) Product Scope (Modules)

Design the system as **modular** (modules can be enabled/disabled per tenant) and **plugin-ready**.

### A) POS (Point of Sale)

* Ultra-fast selling screen (large touch targets, category grid, search, barcode scan).
* Modes: Dine-in, Takeaway, Delivery, Drive-thru.
* Multiple carts, suspended orders, reopen closed bills (with permissions).
* Discounts: per-item, per-bill, customer-level, coupons, time-based offers (Happy Hour), promo codes.
* Taxes: VAT + multi-tax rules, inclusive/exclusive pricing, rounding rules.
* Modifiers: sizes, add-ons, removals, cooking notes, multi-step customization flows.
* Combos/meals + smart upsell suggestions.
* Returns/refunds/voids with approval workflows.
* Cash drawer open, cash in/out, daily close (Z-report), drawer reconciliation.
* Multi-payment split (cash/card/wallet), tips, change handling.
* Multi-currency (optional), exchange rates.
* Receipt printing (thermal) + digital receipt (WhatsApp/SMS/Email) + invoice QR.

### B) Tables + Kitchen (Restaurant Features)

* Floor plan designer (drag/drop tables, sections).
* Table states: free/occupied/served/billed/reserved.
* Move/merge/split tables and bills.
* KDS (Kitchen Display System): stages, timers, prioritization, bundling, station filters.
* Kitchen printing routing by station (bar/grill/dessert).
* Course management (starter/main/dessert) and “fire course”.

### C) Delivery + External Ordering

* Driver module (optional): zones, fees, status tracking.
* Integration points (plugins) for delivery aggregators.
* Optional kiosk mode.

### D) Inventory + Recipes

* Ingredient-based recipes (BOM) with automatic consumption per sale.
* Multi-warehouse, transfers, stock moves, min/max alerts.
* Stock counts, adjustments, waste/spoilage.
* Units & conversions.

### E) Purchasing + Suppliers

* Suppliers, purchase invoices, returns, payments, aging.

### F) Customers + Loyalty

* Customer profiles, order history, preferences.
* Loyalty points/tiers, wallets, coupons.

### G) Staff + Shifts + Permissions

* RBAC permissions down to screen/action/button.
* Shift open/close, handover, cash variance.
* Full audit log.

### H) Reports + Analytics

* Real-time dashboards.
* Sales by time/branch/cashier/item/category/table/driver.
* Tax/VAT reporting.
* COGS estimation and margin snapshots.
* Exports to PDF/Excel.

### I) Admin + Settings

* Branch/device/printer/payment setup.
* Menu builder (drag/drop categories, items, images, availability windows).
* Multi-language (Arabic/English) with perfect RTL.
* White-label theming.

## 2) Key Feature: QR Table Self-Ordering (Customer Scans QR)

Build a **customer-facing web experience** that opens instantly after scanning the QR code on the table.

### Recommendation

Use **Web/PWA** for customer self-order (no app install) + Flutter for POS/KDS. Optionally support Flutter Web if desired.

### Flow

1. Each table has a **QR code** encoding a URL:

   * `https://YOUR_DOMAIN.com/t/{table_token}`
2. Customer scans the QR.
3. A mobile web/PWA opens showing:

   * Branch name + Table number
   * Menu (categories, search, images, prices, availability)
4. Customer selects items + modifiers + notes.
5. Customer submits the order:

   * Guest checkout (no login) OR optional phone/WhatsApp
6. Order is created server-side and routed:

   * Appears in POS as “Self Order - Table X”
   * Appears in KDS by station
7. Customer can track status:

   * Received → Preparing → Ready → Served
8. Optional payment options:

   * Pay at cashier
   * Pay online (Apple Pay/Google Pay/cards)
   * Request bill (notify waiter/cashier)
9. Customer can add items later using the same table session.

### Security / Anti-Tamper

* **Never** encode only the table number. Use a **random table_token** (long, unguessable).
* Token is mapped to (tenant, branch, table) and can be rotated.
* Server-side pricing and tax calculation (client never “decides” totals).
* Rate limiting + abuse detection (IP/device throttling).
* Lightweight captcha only if suspicious.

### Multi-customer per table

* Allow multiple devices to order into the same table check.
* Support “Join Table” session via:

  * Same QR, or
  * Short join code displayed on page.

## 3) Non-Functional Requirements

* Performance:

  * POS startup < 2s.
  * Add item < 150ms locally.
* Offline-first POS:

  * Full selling/printing/shift ops without internet.
  * Sync queue with retries/backoff.
  * Idempotency keys.
* Scalability:

  * Multi-tenant + multi-branch.
  * Start as a modular monolith; migrate to services later.
* Security:

  * OAuth2/JWT + refresh tokens.
  * Secure local storage for sensitive data.
  * RBAC, optional 2FA for admins.
  * Tamper-resistant audit logs.
* Observability:

  * Structured logs, metrics, tracing.

## 4) Architecture (Propose and Justify)

### Client

* Flutter app (POS + optional KDS) using Clean Architecture (Presentation/Domain/Data).
* State management: choose (Riverpod/BLoC) and justify.
* Local DB: choose (Drift/Isar) and justify.
* Printing abstraction:

  * ESC/POS network/Bluetooth
  * AirPrint (iOS)
  * Printer routing by station

### Backend

Choose and justify one:

* NestJS (Node) OR Django DRF OR Go.
  Use:
* PostgreSQL
* Redis (cache + rate limiting)
* Queue (RabbitMQ or Redis Streams) for async tasks (printing jobs, notifications, exports)
* Realtime (WebSockets) for KDS updates and live dashboards
* Object storage (S3-compatible) for images

## 5) Data Model (ERD Required)

Design a complete ERD including (minimum):

* Tenant, Branch, Device
* User, Role, Permission
* Table, FloorPlan
* Product, Category, ModifierGroup, ModifierItem
* RecipeIngredient, InventoryItem, Warehouse, StockMove
* Customer, LoyaltyAccount, Coupon
* Order, OrderItem, Payment, Refund, Tip
* Shift, CashMovement, ZReport
* Supplier, PurchaseInvoice
* AuditLog
* SyncEvent, IdempotencyKey

Use UUIDs, indexes, and strong constraints.

## 6) API Specification (OpenAPI-friendly)

Provide endpoints and example payloads for:

* Auth: login/refresh/device registration
* Menu/Catalog: public + internal
* Orders: create/update/close/split/merge
* KDS: ticket lifecycle
* Payments: intents/capture/refund
* Inventory: moves/counts/alerts
* Reports: dashboards/exports
* QR Self-Order Public API:

  * `GET /public/menu?t={table_token}`
  * `POST /public/orders`
  * `GET /public/orders/{public_id}`
  * `POST /public/orders/{public_id}/add-items`
  * `POST /public/request-bill`

Include:

* Pagination/filter/sort
* Error schema
* Versioning `/v1`
* Idempotency header
* Rate limiting policy

## 7) UI/UX Deliverables

Describe premium UI flows for:

* POS selling screen
* Cart & modifiers
* Payments screen
* Tables (floor plan)
* KDS
* Manager dashboard
* Settings wizard
* Customer PWA (QR order) screens: menu, item details, cart, checkout, status tracking

Rules:

* Touch-first, large targets, minimal steps.
* Perfect RTL support.
* Elegant animations (lightweight).
* Accessibility.

## 8) Printing + Kitchen Operations

* Receipt templates (logo, VAT details, QR)
* Station routing rules
* Auto-print rules for kitchen
* Offline print queue

## 9) Plugins / Integrations

Design a plugin system for:

* Payment providers
* Delivery aggregators
* WhatsApp/SMS
* Accounting exports
* E-invoicing (future)

## 10) DevOps + Deployment

Provide:

* Docker Compose for dev
* CI/CD (GitHub Actions)
* Environments (dev/stage/prod)
* Migrations
* Backups + restore drills
* Scaling strategy
* Secrets management

## 11) Testing + QA

* Unit tests for domain
* Integration tests for API
* E2E tests for Flutter
* Load tests (k6)
* Security tests (OWASP)
* Real-world POS QA checklist

## 12) Output Required Now

In your response, produce:

1. PRD summary + user stories + acceptance criteria
2. Architecture diagram (textual) + justification
3. ERD + initial PostgreSQL DDL
4. API endpoint list + sample requests/responses
5. Flutter app structure + offline sync strategy
6. Printing/KDS strategy
7. Security/RBAC plan
8. DevOps plan
9. Roadmap (MVP → v1 → v2)
10. Risk list + mitigations

**Important:** The solution must be realistic, fast, scalable, and optimized for iPad touch workflows.
