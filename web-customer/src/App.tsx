import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { CartProvider } from './context/CartContext';
import { AuthProvider } from './context/AuthContext';
import Menu from './pages/Menu';
import Cart from './pages/Cart';
import Landing from './pages/Landing';
import OrderStatus from './pages/OrderStatus';
import Login from './pages/Login';

function App() {
  return (
    <AuthProvider>
      <CartProvider>
        <Router>
          <div className="min-h-screen bg-gray-50 text-gray-900">
            <Routes>
              <Route path="/" element={<Landing />} />
              <Route path="/login" element={<Login />} />
              <Route path="/t/:tableId" element={<Menu />} />
              <Route path="/t/:tableId/menu" element={<Menu />} />
              <Route path="/t/:tableId/cart" element={<Cart />} />
              <Route path="/t/:tableId/order/:orderId" element={<OrderStatus />} />
            </Routes>
          </div>
        </Router>
      </CartProvider>
    </AuthProvider>
  );
}

export default App;
