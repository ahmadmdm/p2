import { useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { QrCode } from 'lucide-react';

export default function Landing() {
  const [tableId, setTableId] = useState('');
  const navigate = useNavigate();

  const handleScan = (e: FormEvent) => {
    e.preventDefault();
    if (tableId) {
      navigate(`/t/${tableId}/menu`);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-4">
      <div className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md text-center">
        <div className="bg-blue-100 p-4 rounded-full inline-block mb-4">
          <QrCode className="w-12 h-12 text-blue-600" />
        </div>
        <h1 className="text-2xl font-bold mb-2">Welcome</h1>
        <p className="text-gray-500 mb-6">Scan the QR code on your table or enter the table number below.</p>
        
        <form onSubmit={handleScan} className="space-y-4">
          <input
            type="text"
            placeholder="Enter Table ID (e.g., T1)"
            value={tableId}
            onChange={(e) => setTableId(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
          />
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition"
          >
            Start Ordering
          </button>
        </form>
      </div>
    </div>
  );
}
