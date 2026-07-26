import Link from 'next/link';
import { XCircle } from 'lucide-react';

export default function CheckoutCancelPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FFF8F5] px-6">
      <div className="text-center max-w-sm">
        <XCircle className="mx-auto mb-4 text-gray-400" size={48} />
        <h1 className="text-xl font-semibold text-gray-800 mb-2">No charge was made</h1>
        <p className="text-gray-500 mb-6">You cancelled checkout before completing payment.</p>
        <Link
          href="/checkout"
          className="inline-block py-3 px-6 rounded-full text-sm font-semibold text-white"
          style={{ backgroundColor: '#D8909A' }}
        >
          Try again
        </Link>
      </div>
    </div>
  );
}
