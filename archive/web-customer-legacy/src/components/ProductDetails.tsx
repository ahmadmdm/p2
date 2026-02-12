import { useState } from 'react';
import { X, Minus, Plus } from 'lucide-react';
import type { Product, ModifierGroup, ModifierItem } from '../models';
import { useCart } from '../context/CartContext';

interface ProductDetailsProps {
  product: Product;
  onClose: () => void;
}

export default function ProductDetails({ product, onClose }: ProductDetailsProps) {
  const { addToCart } = useCart();
  const [quantity, setQuantity] = useState(1);
  const [notes, setNotes] = useState('');
  
  // Track selected modifiers: { groupId: [itemId, itemId] }
  const [selections, setSelections] = useState<Record<string, string[]>>({});

  const handleModifierToggle = (group: ModifierGroup, item: ModifierItem) => {
    const current = selections[group.id] || [];
    const isSelected = current.includes(item.id);

    if (group.selectionType === 'SINGLE') {
      // Toggle off if already selected (optional, usually single means radio)
      // For Single, we just replace
      setSelections({ ...selections, [group.id]: [item.id] });
    } else {
      // Multiple
      if (isSelected) {
        setSelections({ ...selections, [group.id]: current.filter(id => id !== item.id) });
      } else {
        if (current.length < group.maxSelection) {
          setSelections({ ...selections, [group.id]: [...current, item.id] });
        }
      }
    }
  };

  const calculateTotal = () => {
    let total = Number(product.price);
    product.modifierGroups?.forEach(group => {
      const selectedIds = selections[group.id] || [];
      selectedIds.forEach(id => {
        const item = group.items.find(i => i.id === id);
        if (item) total += Number(item.price);
      });
    });
    return total * quantity;
  };

  const handleAddToCart = () => {
    // Validate required selections
    for (const group of product.modifierGroups || []) {
      const selectedCount = (selections[group.id] || []).length;
      if (selectedCount < group.minSelection) {
        alert(`Please select at least ${group.minSelection} option(s) for ${group.name.en}`);
        return;
      }
    }

    // Collect modifiers
    const selectedModifiers: ModifierItem[] = [];
    product.modifierGroups?.forEach(group => {
      const selectedIds = selections[group.id] || [];
      selectedIds.forEach(id => {
        const item = group.items.find(i => i.id === id);
        if (item) selectedModifiers.push(item);
      });
    });

    addToCart({
      ...product,
      // We pass modifiers separately or attached? 
      // The addToCart expects a Product. 
      // Our CartContext handles modifiers in the CartItem, not Product structure directly usually.
      // But we modified CartItem to have modifiers. 
      // We need to pass them to addToCart.
    }, quantity, notes, selectedModifiers);
    
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-4">
      <div className="bg-white w-full max-w-md rounded-xl max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="p-4 border-b flex justify-between items-center">
          <h2 className="font-bold text-lg">{product.name.en}</h2>
          <button onClick={onClose} className="p-2 bg-gray-100 rounded-full hover:bg-gray-200">
            <X size={20} />
          </button>
        </div>

        {/* Scrollable Content */}
        <div className="flex-1 overflow-y-auto p-4 space-y-6">
          <div className="flex justify-between items-center">
             <span className="text-xl font-bold text-blue-600">${Number(product.price).toFixed(2)}</span>
          </div>

          {product.modifierGroups?.map(group => (
            <div key={group.id}>
              <h3 className="font-semibold mb-2 flex justify-between">
                {group.name.en}
                <span className="text-xs text-gray-500 font-normal">
                  {group.selectionType === 'SINGLE' ? 'Select 1' : `Select up to ${group.maxSelection}`}
                </span>
              </h3>
              <div className="space-y-2">
                {group.items.map(item => {
                  const isSelected = (selections[group.id] || []).includes(item.id);
                  return (
                    <div 
                      key={item.id}
                      onClick={() => handleModifierToggle(group, item)}
                      className={`p-3 rounded-lg border flex justify-between items-center cursor-pointer transition ${
                        isSelected ? 'border-blue-500 bg-blue-50' : 'border-gray-200 hover:border-blue-300'
                      }`}
                    >
                      <span className={isSelected ? 'font-medium text-blue-700' : ''}>{item.name.en}</span>
                      <div className="flex items-center space-x-2">
                        {Number(item.price) > 0 && (
                          <span className="text-sm text-gray-500">+${Number(item.price).toFixed(2)}</span>
                        )}
                        <div className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                          isSelected ? 'bg-blue-600 border-blue-600' : 'border-gray-300'
                        }`}>
                          {isSelected && <div className="w-2 h-2 bg-white rounded-full" />}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}

          {/* Notes */}
          <div>
            <h3 className="font-semibold mb-2">Special Instructions</h3>
            <textarea
              className="w-full border rounded-lg p-3 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
              rows={3}
              placeholder="E.g. No onions, extra sauce..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t bg-gray-50 rounded-b-xl">
          <div className="flex items-center justify-between mb-4">
            <span className="font-semibold">Quantity</span>
            <div className="flex items-center space-x-4">
              <button 
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
                className="w-10 h-10 rounded-full bg-white border flex items-center justify-center hover:bg-gray-100"
              >
                <Minus size={18} />
              </button>
              <span className="font-bold w-6 text-center">{quantity}</span>
              <button 
                onClick={() => setQuantity(quantity + 1)}
                className="w-10 h-10 rounded-full bg-white border flex items-center justify-center hover:bg-gray-100"
              >
                <Plus size={18} />
              </button>
            </div>
          </div>
          <button
            onClick={handleAddToCart}
            className="w-full bg-blue-600 text-white py-4 rounded-xl font-bold shadow-lg hover:bg-blue-700 transition flex justify-between px-6"
          >
            <span>Add to Cart</span>
            <span>${calculateTotal().toFixed(2)}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
