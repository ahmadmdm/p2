import { useState } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, Minus, Plus, Trash2, User, Gift } from 'lucide-react';
import api from '../api';

export default function Cart() {
  const navigate = useNavigate();
  const { tableId } = useParams<{ tableId: string }>();
  const { items, removeFromCart, updateQuantity, total, clearCart } = useCart();
  const { customer } = useAuth();
  const [placingOrder, setPlacingOrder] = useState(false);

  const handlePlaceOrder = async () => {
    if (!tableId) {
      alert('Table ID not found. Please scan QR again.');
      return;
    }
    setPlacingOrder(true);
    try {
      const orderData = {
        tableId, 
        paymentMethod: 'ONLINE',
        customerId: customer?.id,
        items: items.map(item => ({
          productId: item.product.id,
          quantity: item.quantity,
          notes: item.notes || '',
          modifiers: item.modifiers || [],
        }))
      };

      const res = await api.post('/orders', orderData);
      clearCart();
      navigate(`/t/${tableId}/order/${res.data.id}`);
    } catch (err) {
      console.error('Order failed', err);
      alert('Failed to place order. Please try again.');
    } finally {
      setPlacingOrder(false);
    }
  };

  if (items.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen p-4 text-center">
        <h2 className="text-xl font-bold mb-2">Your cart is empty</h2>
        <p className="text-gray-500 mb-6">Add some delicious items from the menu!</p>
        <button
          onClick={() => navigate(-1)}
          className="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold"
        >
          Back to Menu
        </button>
      </div>
    );
  }

  // Calculate points to earn (10 points per $1)
  const pointsToEarn = Math.floor(total * 10);

  return (
    <div className="min-h-screen bg-gray-50 pb-40">
      <div className="bg-white p-4 shadow-sm sticky top-0 z-10 flex items-center justify-between">
        <div className="flex items-center">
            <button onClick={() => navigate(-1)} className="mr-4 text-gray-600">
            <ArrowLeft />
            </button>
            <h1 className="font-bold text-lg">Your Cart</h1>
        </div>
        
        {customer ? (
            <div className="flex items-center text-sm text-green-700 bg-green-50 px-3 py-1 rounded-full">
                <Gift size={16} className="mr-1" />
                <span>{customer.loyaltyPoints} pts</span>
            </div>
        ) : (
            <Link 
                to={`/login?returnUrl=/t/${tableId}/cart`}
                className="text-sm text-blue-600 font-medium flex items-center"
            >
                <User size={16} className="mr-1" />
                Sign In
            </Link>
        )}
      </div>

      <div className="p-4 space-y-4">
        {items.map((item) => (
          <div key={item.product.id} className="bg-white p-4 rounded-xl shadow-sm flex items-center justify-between">
            <div className="flex-1">
              <h3 className="font-semibold">{item.product.name.en}</h3>
              <p className="text-blue-600 font-medium">
                ${(Number(item.product.price) + (item.modifiers?.reduce((sum, m) => sum + Number(m.price), 0) || 0)).toFixed(2)}
              </p>
              {item.modifiers && item.modifiers.length > 0 && (
                <div className="text-xs text-gray-500 mt-1">
                  {item.modifiers.map(m => m.name.en).join(', ')}
                </div>
              )}
              {item.notes && (
                <div className="text-xs text-gray-400 italic mt-1">"{item.notes}"</div>
              )}
            </div>
            <div className="flex items-center space-x-3">
              <button 
                onClick={() => updateQuantity(item.id, item.quantity - 1)}
                className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200"
              >
                <Minus size={16} />
              </button>
              <span className="font-medium w-4 text-center">{item.quantity}</span>
              <button 
                onClick={() => updateQuantity(item.id, item.quantity + 1)}
                className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200"
              >
                <Plus size={16} />
              </button>
              <button 
                onClick={() => removeFromCart(item.id)}
                className="w-8 h-8 rounded-full bg-red-50 text-red-500 flex items-center justify-center hover:bg-red-100 ml-2"
              >
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Loyalty Banner */}
      <div className="px-4 py-2">
         {customer ? (
             <div className="bg-blue-50 border border-blue-100 p-3 rounded-lg flex items-center text-blue-800 text-sm">
                 <Gift size={18} className="mr-2 text-blue-600" />
                 You will earn <span className="font-bold mx-1">+{pointsToEarn}</span> points with this order!
             </div>
         ) : (
             <Link to={`/login?returnUrl=/t/${tableId}/cart`} className="block bg-gray-100 border border-gray-200 p-3 rounded-lg flex items-center justify-between text-gray-700 text-sm hover:bg-gray-200 transition">
                 <div className="flex items-center">
                    <Gift size={18} className="mr-2 text-gray-500" />
                    <span>Sign in to earn <b>{pointsToEarn} points</b></span>
                 </div>
                 <span className="text-blue-600 font-semibold">Login &rarr;</span>
             </Link>
         )}
      </div>

      <div className="fixed bottom-0 left-0 right-0 bg-white border-t p-4">
        <div className="flex justify-between items-center mb-4">
          <span className="text-gray-500">Total</span>
          <span className="text-2xl font-bold">${total.toFixed(2)}</span>
        </div>
        <button
          onClick={handlePlaceOrder}
          disabled={placingOrder}
          className={`w-full py-4 rounded-xl font-bold text-white shadow-lg transition ${
            placingOrder ? 'bg-gray-400 cursor-not-allowed' : 'bg-green-600 hover:bg-green-700'
          }`}
        >
          {placingOrder ? 'Placing Order...' : 'Place Order'}
        </button>
      </div>
    </div>
  );
}
