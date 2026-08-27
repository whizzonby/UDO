import { Header } from '@/components/landing/Header';
import { Hero } from '@/components/landing/Hero';

export default function HomePage() {
  return (
    <div className="min-h-screen" style={{ backgroundColor: '#FBF2EE' }}>
      <Header />
      <Hero />
    </div>
  );
}
