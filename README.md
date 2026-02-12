# POS System

A premium, scalable Restaurant/Coffee Shop POS system built with Flutter and NestJS.

## Project Structure

*   `backend/`: NestJS API (PostgreSQL, Redis)
*   `mobile/`: Flutter App (iPad/Tablet focus, Offline-first)
*   `customer_web/`: Flutter Web App for QR Table Ordering (production customer app)
*   `archive/web-customer-legacy/`: React + Vite legacy customer app (archived)
*   `docker-compose.yml`: Infrastructure services

## Prerequisites

*   Node.js v18+
*   Flutter 3.10+
*   Docker & Docker Compose

## Getting Started

### 1. Start Infrastructure

Start PostgreSQL and Redis:

```bash
docker-compose up -d
```

### 2. Backend

```bash
cd backend
npm install
# Configure .env (copy from .env.example if exists, or use defaults)
npm run start:dev
```

### 3. Mobile App (POS)

```bash
cd mobile
flutter pub get
flutter run -d windows # or ipad/android
```

### 4. Customer Web App (QR Ordering)

```bash
cd customer_web
flutter pub get
flutter run -d chrome
```

Archived legacy React customer app:

```bash
cd archive/web-customer-legacy
npm install
npm run dev
```

After launch, open the app with a table token from the QR code, for example:

```text
http://localhost:8081/?t=<table_qr_token>
```

To generate demo menu/tables/users for local testing:

```bash
cd backend
npm run seed
```

## Architecture

*   **Backend**: Modular Monolith (NestJS), TypeORM, PostgreSQL.
*   **Mobile**: Clean Architecture, Riverpod (State), Drift (Local DB), Offline Sync.
*   **Customer Web**: Flutter Web, Riverpod.

## Status Checklist

- [x] **Backend Infrastructure**: NestJS, TypeORM, PostgreSQL setup.
- [x] **Authentication**: JWT, Roles, Guards.
- [x] **Inventory**: Ingredients, Stock Tracking, Waste/Spoilage Logging.
- [x] **POS**: Orders, Cart, Discounts, Tax.
- [x] **KDS**: Kitchen Display, WebSocket Updates.
- [x] **Mobile Offline**: Drift Database, Sync Service.
- [x] **Customer Web**:
    - [x] Menu Display
    - [x] Modifiers Selection
    - [x] Cart & Ordering (New & Add to Existing)
    - [x] Request Bill
    - [x] Localization (Ar/En)
- [ ] **Reports**:
    - [x] Mobile UI
    - [x] Backend Endpoints
    - [ ] Export to PDF/Excel
- [ ] **Delivery**: Driver Module (Basic UI implemented).

## Next Steps

1.  Enhance Report Exports (PDF/Excel).
2.  Finalize Delivery/Driver flow.
3.  Implement Lightweight Captcha for Public API.

## Migration / Deprecation

- **Archived on February 12, 2026**: `web-customer/` was moved to `archive/web-customer-legacy/`.
- **Active path**: `customer_web/` is the only production customer web app.
- **Removal plan**:
  1. Keep `archive/web-customer-legacy/` read-only for reference during transition.
  2. Do not add new features or fixes to the archived app.
  3. Remove `archive/web-customer-legacy/` after the transition window and historical review are complete.
