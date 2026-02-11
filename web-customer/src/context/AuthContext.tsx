import React, { createContext, useContext, useState, ReactNode, useEffect } from 'react';
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

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [customer, setCustomer] = useState<Customer | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check localStorage
    const saved = localStorage.getItem('customer');
    if (saved) {
      setCustomer(JSON.parse(saved));
    }
    setIsLoading(false);
  }, []);

  const login = async (phoneNumber: string) => {
    try {
      const res = await api.post('/customers/login', { phoneNumber });
      if (res.data.customer) {
        setCustomer(res.data.customer);
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
        setCustomer(res.data);
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
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
