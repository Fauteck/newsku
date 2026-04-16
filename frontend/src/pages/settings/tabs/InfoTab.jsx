import { useEffect, useState } from 'react';
import useSettingsStore from '../../../store/settingsStore.js';

const APP_VERSION = __APP_VERSION__;

export default function InfoTab() {
  const { config, loadConfig } = useSettingsStore();
  const [backendUrl] = useState(() => window.location.origin);

  useEffect(() => { if (!config) loadConfig(); }, []);

  const openGitHubIssue = () => {
    const body = [
      `**App-Version:** ${APP_VERSION}`,
      `**Backend-Version:** ${config?.backendVersion ?? '-'}`,
      `**Backend-URL:** ${backendUrl}`,
      '',
      '**Beschreibung:**',
      '',
    ].join('\n');
    const url = `https://github.com/lamarios/newsku/issues/new?body=${encodeURIComponent(body)}`;
    window.open(url, '_blank', 'noopener,noreferrer');
  };

  return (
    <div className="text-center py-4">
      <i className="fas fa-rss fa-3x mb-3" style={{ color: 'var(--primary-color)' }} />
      <h5 className="mb-4">Newsku</h5>

      <div className="d-inline-flex flex-column gap-2 text-start" style={{ minWidth: 280 }}>
        <InfoRow label="Version" value={APP_VERSION} />
        <InfoRow label="Backend-URL" value={backendUrl} mono />
        <InfoRow label="Backend-Version" value={config?.backendVersion ?? '—'} />
      </div>

      <div className="d-flex justify-content-center gap-2 mt-4 flex-wrap">
        <a
          href="https://github.com/lamarios/newsku"
          target="_blank"
          rel="noopener noreferrer"
          className="btn btn-outline-secondary btn-sm"
        >
          <i className="fab fa-github me-1" />GitHub
        </a>
        <button className="btn btn-outline-secondary btn-sm" onClick={openGitHubIssue}>
          <i className="fas fa-bug me-1" />Feedback / Bug melden
        </button>
        <a
          href="/licenses"
          target="_blank"
          rel="noopener noreferrer"
          className="btn btn-outline-secondary btn-sm"
        >
          <i className="fas fa-file-alt me-1" />Lizenzen
        </a>
      </div>
    </div>
  );
}

function InfoRow({ label, value, mono }) {
  return (
    <div className="d-flex gap-3 align-items-start">
      <span className="text-muted" style={{ fontSize: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.5px', minWidth: 130 }}>
        {label}
      </span>
      <span className={mono ? 'font-monospace' : ''} style={{ fontSize: '0.875rem', wordBreak: 'break-all' }}>
        {value}
      </span>
    </div>
  );
}
