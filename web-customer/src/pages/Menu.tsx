import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../api';
import type { Category, Product } from '../models';
import { useCart } from '../context/CartContext';
import { ShoppingCart, Plus } from 'lucide-react';
import ProductDetails from '../components/ProductDetails';

export default function Menu() {
  const { tableId } = useParams<{ tableId: string }>();
  const navigate = useNavigate();
  const { addToCart, total, items } = useCart();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState<string>('');
  const [tableNumber, setTableNumber] = useState<string>('');
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  useEffect(() => {
    if (tableId) {
      localStorage.setItem('tableId', tableId);
    }
    const fetchMenu = async () => {
      try {
        const res = await api.get<{
          tableNumber: string;
          categories: Category[];
        }>('/public-api/menu', {
          params: { t: tableId },
        });

        const fetchedCategories = res.data.categories ?? [];
        setTableNumber(res.data.tableNumber ?? '');
        setCategories(fetchedCategories);
        if (fetchedCategories.length > 0) {
          setActiveCategory(fetchedCategories[0].id);
        }
      } catch (err) {
        console.error('Failed to fetch menu', err);
      } finally {
        setLoading(false);
      }
    };
    fetchMenu();
  }, [tableId]);

  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);

  const handleProductClick = (product: Product) => {
    if ((product.modifierGroups && product.modifierGroups.length > 0)) {
      setSelectedProduct(product);
    } else {
      addToCart(product);
    }
  };

  if (loading) return <div className="flex justify-center items-center h-screen">Loading menu...</div>;

  return (
    <div className="pb-24">
      {selectedProduct && (
        <ProductDetails 
          product={selectedProduct} 
          onClose={() => setSelectedProduct(null)} 
        />
      )}
      {/* Header */}
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="px-4 py-3 flex justify-between items-center">
          <div>
            <h1 className="font-bold text-lg">
              Table {tableNumber || tableId}
            </h1>
            <p className="text-xs text-gray-500">Welcome back</p>
          </div>
          <button 
            onClick={() => navigate(`/t/${tableId}/cart`)}
            className="relative p-2 bg-blue-50 rounded-full text-blue-600"
          >
            <ShoppingCart size={24} />
            {totalItems > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold w-5 h-5 flex items-center justify-center rounded-full">
                {totalItems}
              </span>
            )}
          </button>
        </div>

        {/* Category Tabs */}
        <div className="flex overflow-x-auto px-4 py-2 space-x-4 no-scrollbar">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id)}
              className={`whitespace-nowrap px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                activeCategory === cat.id
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {cat.name.en}
            </button>
          ))}
        </div>
      </div>

      {/* Product List */}
      <div className="p-4 space-y-6">
        {categories.map((cat) => (
          <div key={cat.id} id={cat.id} className={activeCategory === cat.id ? 'block' : 'hidden'}>
            <h2 className="font-bold text-xl mb-4">{cat.name.en}</h2>
            <div className="grid grid-cols-1 gap-4">
              {(cat.products ?? []).map((product: Product) => (
                <div key={product.id} className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center">
                  <div className="flex-1">
                    <h3 className="font-semibold">{product.name.en}</h3>
                    <p className="text-gray-500 text-sm mt-1">${Number(product.price).toFixed(2)}</p>
                  </div>
                  <button
                    onClick={() => handleProductClick(product)}
                    className="w-10 h-10 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center hover:bg-blue-200 transition"
                  >
                    <Plus size={20} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Floating Cart Button */}
      {totalItems > 0 && (
        <div className="fixed bottom-6 left-4 right-4">
          <button
            onClick={() => navigate(`/t/${tableId}/cart`)}
            className="w-full bg-blue-600 text-white py-4 rounded-xl shadow-lg flex justify-between items-center px-6 font-semibold hover:bg-blue-700 transition"
          >
            <span className="flex items-center">
              <span className="bg-blue-800 w-8 h-8 rounded-full flex items-center justify-center text-sm mr-3">
                {totalItems}
              </span>
              View Cart
            </span>
            <span>${total.toFixed(2)}</span>
          </button>
        </div>
      )}
    </div>
  );
}
