# Web Customer (React + Vite)

Alternative customer-facing QR ordering app built with React.

## Purpose

- Enter table token
- Browse menu
- Create order or append items to active table order
- Track order status

## Run Locally

```bash
cd web-customer
npm install
npm run dev
```

## Environment

Set backend base URL with:

- `VITE_API_BASE_URL` (default: `http://localhost:3000`)

Example `.env.local`:

```bash
VITE_API_BASE_URL=http://localhost:3000
```

The app calls:

- `/public-api/*` for table ordering
- `/customers/*` for optional customer login/register

## Notes

- This app is an alternative to `../customer_web` (Flutter).
