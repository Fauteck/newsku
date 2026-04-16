import { Link, useLocation } from 'react-router-dom';
import useAuthStore from '../../store/authStore.js';

export default function Navbar() {
  const location = useLocation();
  const { user, logout } = useAuthStore();
  const displayName = user?.username ?? user?.email ?? 'Benutzer';

  const isActive = (path) => location.pathname.startsWith(path) ? 'navbar-link active' : 'navbar-link';

  return (
    <nav className="navbar navbar-expand navbar-dark">
      <div className="container-fluid">
        <Link className="navbar-brand" to="/">
          <i className="fas fa-rss me-2" />Newsku
        </Link>
        <div className="navbar-collapse">
          <ul className="navbar-nav me-auto">
            <li className="nav-item">
              <Link className={isActive('/feed')} to="/feed">
                <i className="fas fa-newspaper me-1" />Feeds
              </Link>
            </li>
            <li className="nav-item">
              <Link className={isActive('/einstellungen')} to="/einstellungen">
                <i className="fas fa-cog me-1" />Einstellungen
              </Link>
            </li>
          </ul>
          <ul className="navbar-nav ms-auto">
            <li className="nav-item dropdown">
              <a
                className="navbar-link dropdown-toggle"
                href="#"
                role="button"
                data-bs-toggle="dropdown"
                aria-expanded="false"
              >
                <i className="fas fa-user-circle me-1" />{displayName}
              </a>
              <ul className="dropdown-menu dropdown-menu-end">
                <li>
                  <Link className="dropdown-item" to="/einstellungen">
                    <i className="fas fa-cog me-2" />Einstellungen
                  </Link>
                </li>
                <li><hr className="dropdown-divider" /></li>
                <li>
                  <button className="dropdown-item" onClick={logout}>
                    <i className="fas fa-sign-out-alt me-2" />Abmelden
                  </button>
                </li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  );
}
