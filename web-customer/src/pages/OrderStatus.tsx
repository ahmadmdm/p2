import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../api';
import type { Order } from '../models';
import { CheckCircle, Clock, ChefHat, Utensils, XCircle } from 'lucide-react';

export default function OrderStatus() {
  const { tableId, orderId } = useParams<{ tableId: string, orderId: string }>();
  const navigate = useNavigate();
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!orderId) return;

    const fetchOrder = async () => {
      try {
        const res = await api.get<Order>(`/orders/${orderId}`);
        setOrder(res.data);
      } catch (err) {
        console.error('Failed to fetch order', err);
      } finally {
        setLoading(false);
      }
    };

    fetchOrder();
    
    // Poll for updates every 5 seconds
    const interval = setInterval(fetchOrder, 5000);
    return () => clearInterval(interval);
  }, [orderId]);

  if (loading) return <div className="flex justify-center items-center h-screen">Loading status...</div>;
  if (!order) return <div className="flex justify-center items-center h-screen">Order not found</div>;

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'PENDING': return <Clock className="w-16 h-16 text-yellow-500" />;
      case 'PREPARING': return <ChefHat className="w-16 h-16 text-orange-500" />;
      case 'READY': return <CheckCircle className="w-16 h-16 text-green-500" />;
      case 'SERVED': return <Utensils className="w-16 h-16 text-blue-500" />;
      case 'CANCELLED': return <XCircle className="w-16 h-16 text-red-500" />;
      default: return <Clock className="w-16 h-16 text-gray-500" />;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'PENDING': return 'Order Received';
      case 'PREPARING': return 'Preparing Your Food';
      case 'READY': return 'Ready to Serve';
      case 'SERVED': return 'Enjoy your meal!';
      case 'CANCELLED': return 'Order Cancelled';
      default: return status;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6 flex flex-col items-center">
      <div className="bg-white p-8 rounded-2xl shadow-lg w-full max-w-md text-center">
        <div className="flex justify-center mb-6">
          {getStatusIcon(order.status)}
        </div>
        
        <h1 className="text-2xl font-bold mb-2">{getStatusText(order.status)}</h1>
        <p className="text-gray-500 mb-8">Order #{order.id.slice(0, 8)}</p>

        <div className="space-y-4 text-left border-t pt-6">
          <h3 className="font-semibold text-gray-700">Order Summary</h3>
          {order.items.map((item: any) => (
            <div key={item.id} className="flex justify-between text-sm">
              <span>{item.quantity}x {item.product.name.en}</span>
              <span className="font-medium">${Number(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
          <div className="flex justify-between font-bold text-lg pt-4 border-t">
            <span>Total</span>
            <span>${Number(order.totalAmount).toFixed(2)}</span>
          </div>
        </div>

        <button
          onClick={() => navigate(`/t/${tableId}`)}
          className="mt-8 w-full bg-gray-100 text-gray-700 py-3 rounded-lg font-semibold hover:bg-gray-200 transition"
        >
          Back to Menu
        </button>
      </div>
    </div>
  );
}
