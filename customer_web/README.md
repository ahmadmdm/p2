# Customer Web (Flutter)

Customer-facing QR ordering app built with Flutter Web.

## Purpose

- Scan/open a table token (`?t=<token>`)
- Browse menu
- Create order or add items to active order
- Track order status
- Request bill

## Run Locally

```bash
cd customer_web
flutter pub get
flutter run -d chrome
```

## Backend URL

This app reads the public API base URL from compile-time define:

- `PUBLIC_API_BASE_URL` (default: `http://localhost:3000/public-api`)

Example:

```bash
flutter run -d chrome --dart-define=PUBLIC_API_BASE_URL=http://localhost:3000/public-api
```

## Notes

- This is the production customer web implementation in this repository.
- Legacy React app is archived at `../archive/web-customer-legacy`.
