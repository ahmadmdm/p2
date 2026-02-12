import { createContext, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import type { ModifierItem, Product } from '../models';

export interface CartItem {
  id: string;
  product: Product;
  quantity: number;
  notes?: string;
  modifiers: ModifierItem[];
}

interface CartContextType {
  items: CartItem[];
  addToCart: (
    product: Product,
    quantity?: number,
    notes?: string,
    modifiers?: ModifierItem[],
  ) => void;
  removeFromCart: (itemId: string) => void;
  updateQuantity: (itemId: string, quantity: number) => void;
  updateNotes: (itemId: string, notes: string) => void;
  clearCart: () => void;
  total: number;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

function buildCartItemId(
  productId: string,
  notes: string,
  modifiers: ModifierItem[],
): string {
  const modifierIds = modifiers
    .map((modifier) => modifier.id)
    .sort()
    .join(',');
  return `${productId}|${notes.trim()}|${modifierIds}`;
}

function readInitialCart(): CartItem[] {
  const saved = localStorage.getItem('cart');
  if (!saved) {
    return [];
  }

  try {
    const parsed = JSON.parse(saved) as CartItem[];
    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed.map((item) => {
      const modifiers = Array.isArray(item.modifiers) ? item.modifiers : [];
      const notes = item.notes ?? '';
      const id =
        item.id || buildCartItemId(item.product.id, notes, modifiers);

      return {
        ...item,
        id,
        modifiers,
        notes,
      };
    });
  } catch {
    return [];
  }
}

export function CartProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<CartItem[]>(readInitialCart);

  useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(items));
  }, [items]);

  const addToCart = (
    product: Product,
    quantity = 1,
    notes = '',
    modifiers: ModifierItem[] = [],
  ) => {
    const itemId = buildCartItemId(product.id, notes, modifiers);

    setItems((prev) => {
      const existing = prev.find((item) => item.id === itemId);
      if (existing) {
        return prev.map((item) =>
          item.id === itemId
            ? { ...item, quantity: item.quantity + quantity }
            : item,
        );
      }

      return [...prev, { id: itemId, product, quantity, notes, modifiers }];
    });
  };

  const removeFromCart = (itemId: string) => {
    setItems((prev) => prev.filter((item) => item.id !== itemId));
  };

  const updateQuantity = (itemId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    setItems((prev) =>
      prev.map((item) => (item.id === itemId ? { ...item, quantity } : item)),
    );
  };

  const updateNotes = (itemId: string, notes: string) => {
    setItems((prev) =>
      prev.map((item) => (item.id === itemId ? { ...item, notes } : item)),
    );
  };

  const clearCart = () => setItems([]);

  const total = items.reduce((sum, item) => {
    const modifiersTotal = item.modifiers.reduce(
      (modifierSum, modifier) => modifierSum + Number(modifier.price || 0),
      0,
    );
    const itemPrice = Number(item.product.price) + modifiersTotal;
    return sum + itemPrice * item.quantity;
  }, 0);

  return (
    <CartContext.Provider
      value={{
        items,
        addToCart,
        removeFromCart,
        updateQuantity,
        updateNotes,
        clearCart,
        total,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
