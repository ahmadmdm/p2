import { createContext, useContext, useState } from 'react';
import type { ReactNode } from 'react';
import api from '../api';

interface Customer {
  id: string;
  name: string;
  phoneNumber: string;
  loyaltyPoints: number;
}

interface AuthContextType {
  customer: Customer | null;
  login: (phoneNumber: string) => Promise<boolean>;
  register: (name: string, phoneNumber: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

function readStoredCustomer(): Customer | null {
  const saved = localStorage.getItem('customer');
  if (!saved) {
    return null;
  }

  try {
    return JSON.parse(saved) as Customer;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [customer, setCustomer] = useState<Customer | null>(readStoredCustomer);
  const [isLoading] = useState(false);

  const login = async (phoneNumber: string) => {
    try {
      const res = await api.post('/customers/login', { phoneNumber });
      if (res.data.customer) {
        setCustomer(res.data.customer as Customer);
        localStorage.setItem('customer', JSON.stringify(res.data.customer));
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login failed', error);
      return false;
    }
  };

  const register = async (name: string, phoneNumber: string) => {
    try {
      const res = await api.post('/customers', { name, phoneNumber });
      if (res.data) {
        setCustomer(res.data as Customer);
        localStorage.setItem('customer', JSON.stringify(res.data));
      }
    } catch (error) {
      console.error('Registration failed', error);
      throw error;
    }
  };

  const logout = () => {
    setCustomer(null);
    localStorage.removeItem('customer');
  };

  return (
    <AuthContext.Provider value={{ customer, login, register, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
