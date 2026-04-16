import Navbar from './Navbar.jsx';
import MobileTopbar from './MobileTopbar.jsx';
import BottomNav from './BottomNav.jsx';
import Footer from './Footer.jsx';

export default function AppLayout({ children }) {
  return (
    <>
      <Navbar />
      <MobileTopbar />
      <main className="container-fluid py-3">
        {children}
      </main>
      <Footer />
      <BottomNav />
    </>
  );
}
