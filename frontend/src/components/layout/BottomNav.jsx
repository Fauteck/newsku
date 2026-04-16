import { Link, useLocation } from 'react-router-dom';

export default function BottomNav() {
  const location = useLocation();

  const isActive = (path) => location.pathname.startsWith(path);

  return (
    <nav className="bottom-nav">
      <Link
        className={`bottom-nav-item${isActive('/feed') ? ' active' : ''}`}
        to="/feed"
      >
        <i className="fas fa-newspaper" />
        <span>Feeds</span>
      </Link>
      <Link
        className={`bottom-nav-item${isActive('/einstellungen') ? ' active' : ''}`}
        to="/einstellungen"
      >
        <i className="fas fa-cog" />
        <span>Einstellungen</span>
      </Link>
      <button
        className="bottom-nav-item"
        data-bs-toggle="offcanvas"
        data-bs-target="#mobileMenuSheet"
      >
        <i className="fas fa-bars" />
        <span>Menü</span>
      </button>
    </nav>
  );
}
