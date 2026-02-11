import React, { createContext, useContext, useState } from 'react';
import type { ReactNode } from 'react';
import type { Product } from '../models';

interface CartItem {
  product: Product;
  quantity: number;
  notes?: string;
  modifiers?: any[];
}  notes?: string;
interface CartContextType {
  items: CartItem[];
  addToCart: (product: Product, quantity?: number, notes?: string, modifiers?: any[]) => void;
  removeFromCart: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  updateNotes: (productId: string, notes: string) => void;
  total: number;
}notes: string) => void;
  clearCart: () => void;
  total: number;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export const CartProvider = ({ children }: { children: ReactNode }) => {
  const [items, setItems] = useState<CartItem[]>(() => {
    const saved = localStorage.getItem('cart');
    return saved ? JSON.parse(saved) : [];
  });

  React.useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(items));
  }, [items]);

  const addToCart = (product: Product, quantity = 1, notes = '', modifiers: any[] = []) => {
    setItems((prev) => {
      // Simple check: if modifiers exist, we always add as new item for now to avoid complex comparison
      // or we can try to match modifiers.
      const existing = prev.find((item) => 
        item.product.id === product.id && 
        JSON.stringify(item.modifiers) === JSON.stringify(modifiers) &&
        item.notes === notes
      );
      
      if (existing) {
        return prev.map((item) =>
          (item === existing)
            ? { ...item, quantity: item.quantity + quantity }
            : item
        );
      }
      return [...prev, { product, quantity, notes, modifiers }];
    });
  };

  const removeFromCart = (productId: string) => {
    setItems((prev) => prev.filter((item) => item.product.id !== productId));
  };

  const updateQuantity = (productId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    setItems((prev) =>
      prev.map((item) =>
        item.product.id === productId ? { ...item, quantity } : item
      )
    );
  };

  const updateNotes = (productId: string, notes: string) => {
    setItems((prev) =>
      prev.map((item) =>
        item.product.id === productId ? { ...item, notes } : item
      )
    );
  };

  const clearCart = () => setItems([]);

  const total = items.reduce(
    (sum, item) => {
      let itemPrice = Number(item.product.price);
      if (item.modifiers) {
        item.modifiers.forEach(mod => {
          itemPrice += Number(mod.price || 0);
        });
      }
      return sum + itemPrice * item.quantity;
    },
    0
  );

  return (
    <CartContext.Provider
      value={{ items, addToCart, removeFromCart, updateQuantity, updateNotes, clearCart, total }}
    >
      {children}
    </CartContext.Provider>
  );
};

export const useCart = () => {
  const context = useContext(CartContext);
  if (!context) throw new Error('useCart must be used within a CartProvider');
  return context;
};
