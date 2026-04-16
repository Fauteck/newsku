import { Link } from 'react-router-dom';

export default function MobileTopbar() {
  return (
    <>
      <div className="mobile-topbar">
        <button
          className="mobile-topbar-btn"
          data-bs-toggle="offcanvas"
          data-bs-target="#mobileMenuSheet"
          aria-label="Menü"
        >
          <i className="fas fa-bars" />
        </button>
        <Link className="mobile-topbar-brand text-decoration-none" to="/">
          <i className="fas fa-rss me-1" />Newsku
        </Link>
        <Link to="/suche" className="mobile-topbar-btn" aria-label="Suche">
          <i className="fas fa-search" />
        </Link>
      </div>

      {/* Mobile menu offcanvas (slides from bottom) */}
      <div
        className="offcanvas offcanvas-bottom more-sheet"
        tabIndex="-1"
        id="mobileMenuSheet"
        style={{ height: 'auto', maxHeight: '80vh', borderRadius: '16px 16px 0 0' }}
      >
        <div
          className="offcanvas-header"
          style={{ borderRadius: '16px 16px 0 0' }}
        >
          <h5 className="offcanvas-title">
            <i className="fas fa-rss me-2" />Newsku
          </h5>
          <button
            type="button"
            className="btn-close btn-close-white"
            data-bs-dismiss="offcanvas"
            aria-label="Schließen"
          />
        </div>
        <div className="offcanvas-body p-0">
          <div className="list-group list-group-flush">
            <a
              href="/feed"
              className="list-group-item list-group-item-action"
              data-bs-dismiss="offcanvas"
            >
              <i className="fas fa-newspaper me-2" />Feeds
            </a>
            <a
              href="/einstellungen"
              className="list-group-item list-group-item-action"
              data-bs-dismiss="offcanvas"
            >
              <i className="fas fa-cog me-2" />Einstellungen
            </a>
          </div>
        </div>
      </div>
    </>
  );
}
