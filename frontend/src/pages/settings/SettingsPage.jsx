import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import useSettingsStore from '../../store/settingsStore.js';
import useAuthStore from '../../store/authStore.js';
import FeedsTab from './tabs/FeedsTab.jsx';
import LayoutTab from './tabs/LayoutTab.jsx';
import GeneralTab from './tabs/GeneralTab.jsx';
import UserTab from './tabs/UserTab.jsx';
import InfoTab from './tabs/InfoTab.jsx';

const TABS = [
  { id: 'feeds',       label: 'Feeds',        icon: 'fa-rss' },
  { id: 'darstellung', label: 'Darstellung',  icon: 'fa-th-large' },
  { id: 'profil',      label: 'Profil',       icon: 'fa-user' },
  { id: 'info',        label: 'Info',         icon: 'fa-info-circle' },
];

export default function SettingsPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const initialTab = searchParams.get('tab') ?? 'feeds';
  const [activeTab, setActiveTab] = useState(
    TABS.some((t) => t.id === initialTab) ? initialTab : 'feeds',
  );
  const { loadConfig, loadUser } = useSettingsStore();
  const { logout } = useAuthStore();

  useEffect(() => {
    loadConfig();
    loadUser();
  }, []);

  const switchTab = (id) => {
    setActiveTab(id);
    setSearchParams({ tab: id }, { replace: true });
  };

  return (
    <div className="settings-container">
      {/* Page header */}
      <div className="d-flex align-items-center justify-content-between mb-3">
        <h4 className="mb-0">
          <i className="fas fa-cog me-2 text-muted" />Einstellungen
        </h4>
        <button className="btn btn-outline-danger btn-sm" onClick={logout}>
          <i className="fas fa-sign-out-alt me-1" />Abmelden
        </button>
      </div>

      {/* Tab navigation */}
      <ul className="nav settings-tabs mb-3">
        {TABS.map((tab) => (
          <li className="nav-item" key={tab.id}>
            <button
              className={`nav-link${activeTab === tab.id ? ' active' : ''}`}
              onClick={() => switchTab(tab.id)}
            >
              <i className={`fas ${tab.icon}`} />
              {tab.label}
            </button>
          </li>
        ))}
      </ul>

      {/* Tab content */}
      <div className="tab-content">
        {activeTab === 'feeds'       && <FeedsTab />}
        {activeTab === 'darstellung' && <DarstellungTab />}
        {activeTab === 'profil'      && <UserTab />}
        {activeTab === 'info'        && <InfoTab />}
      </div>
    </div>
  );
}

function DarstellungTab() {
  return (
    <div>
      <GeneralTab />
      <hr />
      <LayoutTab />
    </div>
  );
}
