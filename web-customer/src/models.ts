export interface Category {
  id: string;
  name: { en: string; ar: string };
  sortOrder: number;
}

export interface ModifierItem {
  id: string;
  name: { en: string; ar: string };
  price: number;
}

export interface ModifierGroup {
  id: string;
  name: { en: string; ar: string };
  selectionType: 'SINGLE' | 'MULTIPLE';
  minSelection: number;
  maxSelection: number;
  items: ModifierItem[];
}

export interface Product {
  id: string;
  name: { en: string; ar: string };
  price: number; // or string if decimal comes as string
  isAvailable: boolean;
  category?: Category;
  categoryId?: string;
  modifierGroups?: ModifierGroup[];
}

export interface Table {
  id: string;
  tableNumber: string;
  section: string;
  qrCode: string;
}

export interface OrderItem {
  productId: string;
  quantity: number;
  price: number;
  modifiers?: any[];
}

export interface CreateOrderDto {
  tableId: string;
  items: OrderItem[];
}

export interface Order {
  id: string;
  status: string;
  totalAmount: number;
  items: any[];
  createdAt: string;
}
