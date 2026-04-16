import { useState, useEffect } from 'react';
import useSettingsStore from '../../../store/settingsStore.js';

const READ_ITEM_OPTIONS = [
  { value: 'none',              label: 'Normal anzeigen' },
  { value: 'dim',               label: 'Ausblenden' },
  { value: 'hide',              label: 'Verstecken' },
  { value: 'unreadFirstThenDim', label: 'Ungelesen zuerst, dann ausblenden' },
];

const COLOR_SWATCHES = [
  { name: 'Blau',        hex: '#3498db' },
  { name: 'Dunkelblau',  hex: '#2980b9' },
  { name: 'Grün',        hex: '#27ae60' },
  { name: 'Lila',        hex: '#8e44ad' },
  { name: 'Orange',      hex: '#e67e22' },
  { name: 'Rot',         hex: '#e74c3c' },
  { name: 'Pink',        hex: '#e91e8c' },
  { name: 'Türkis',      hex: '#1abc9c' },
  { name: 'Grau',        hex: '#7f8c8d' },
];

const THEME_OPTIONS = [
  { value: 'system', label: 'Systemstandard' },
  { value: 'light',  label: 'Hell' },
  { value: 'dark',   label: 'Dunkel' },
];

export default function GeneralTab() {
  const { user, loadUser, saveUser } = useSettingsStore();

  const [preference, setPreference] = useState('');
  const [minScore, setMinScore] = useState(0);
  const [readHandling, setReadHandling] = useState('none');
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  // Local-only (device) settings stored in localStorage
  const [theme, setThemeState] = useState(() => localStorage.getItem('theme') ?? 'system');
  const [truncate, setTruncate] = useState(() => localStorage.getItem('truncateText') === 'true');
  const [accentColor, setAccentColor] = useState(
    () => localStorage.getItem('accentColor') ?? '#3498db',
  );

  useEffect(() => {
    if (!user) { loadUser(); return; }
    setPreference(user.articlePreference ?? '');
    setMinScore(user.minimumImportance ?? 0);
    setReadHandling(user.readItemHandling ?? 'none');
  }, [user]);

  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 3000); };

  const handleSavePreference = async () => {
    setSaving(true);
    try {
      await saveUser({ articlePreference: preference });
      showToast('Präferenzen aktualisiert');
    } finally {
      setSaving(false);
    }
  };

  const handleScoreChange = async (val) => {
    setMinScore(val);
    await saveUser({ minimumImportance: val });
  };

  const handleReadHandlingChange = async (val) => {
    setReadHandling(val);
    await saveUser({ readItemHandling: val });
  };

  const handleThemeChange = (val) => {
    setThemeState(val);
    localStorage.setItem('theme', val);
    document.documentElement.setAttribute('data-bs-theme', val === 'system' ? '' : val);
  };

  const handleTruncateChange = (checked) => {
    setTruncate(checked);
    localStorage.setItem('truncateText', String(checked));
  };

  const handleColorChange = (hex) => {
    setAccentColor(hex);
    localStorage.setItem('accentColor', hex);
    document.documentElement.style.setProperty('--primary-color', hex);
  };

  const handleClearCache = () => {
    // Browser-side: clear any cached items from sessionStorage / caches API
    if ('caches' in window) {
      caches.keys().then((names) => names.forEach((n) => caches.delete(n)));
    }
    showToast('Cache geleert');
  };

  return (
    <div>
      {/* AI Preferences */}
      <section className="mb-4">
        <p className="section-title">Artikel-Präferenzen</p>
        <textarea
          className="form-control mb-2"
          rows={5}
          placeholder="Anweisung für das KI-Modell: Beschreibe, welche Arten von Artikeln du bevorzugst…"
          value={preference}
          onChange={(e) => setPreference(e.target.value)}
        />
        <p className="section-subtitle">
          Änderungen gelten nur für zukünftige Artikel.
        </p>
        <div className="text-end">
          <button className="btn btn-primary btn-sm" onClick={handleSavePreference} disabled={saving}>
            {saving ? <span className="spinner-border spinner-border-sm me-1" /> : <i className="fas fa-save me-1" />}
            Aktualisieren
          </button>
        </div>
      </section>

      <hr />

      {/* Minimum importance score */}
      <section className="mb-4">
        <p className="section-title">Minimaler Nachrichten-Score</p>
        <p className="section-subtitle">
          Artikel mit einem Score unterhalb dieses Wertes werden herausgefiltert.
        </p>
        <div className="d-flex align-items-center gap-3">
          <input
            type="range"
            className="form-range score-slider flex-grow-1"
            min={0} max={100} step={5}
            value={minScore}
            onChange={(e) => handleScoreChange(Number(e.target.value))}
          />
          <span className="badge bg-primary" style={{ minWidth: 36 }}>{minScore}</span>
        </div>
      </section>

      {/* Read item handling */}
      <section className="mb-4">
        <div className="d-flex align-items-start gap-3">
          <div className="flex-grow-1">
            <p className="section-title mb-0">Gelesene Artikel</p>
            <p className="section-subtitle mb-0">
              Beim Scrollen werden Artikel als gelesen markiert. Wähle, wie sie angezeigt werden.
            </p>
          </div>
          <select
            className="form-select form-select-sm"
            style={{ maxWidth: 260 }}
            value={readHandling}
            onChange={(e) => handleReadHandlingChange(e.target.value)}
          >
            {READ_ITEM_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>
        </div>
      </section>

      <hr />

      {/* Device-only settings */}
      <div className="device-only-box mb-3">
        <i className="fas fa-mobile-alt" />
        <span>Diese Einstellungen werden nur auf diesem Gerät gespeichert</span>
      </div>

      {/* Truncate text */}
      <section className="mb-3">
        <div className="form-check form-switch">
          <input
            className="form-check-input"
            type="checkbox"
            id="truncateSwitch"
            checked={truncate}
            onChange={(e) => handleTruncateChange(e.target.checked)}
          />
          <label className="form-check-label" htmlFor="truncateSwitch">
            <span className="section-title d-block mb-0">Textkürzung</span>
            <span className="section-subtitle">
              KI generiert automatisch Titel- und Teaser-Varianten je Darstellungsform.
            </span>
          </label>
        </div>
      </section>

      {/* Theme */}
      <section className="mb-3">
        <div className="d-flex align-items-center gap-3">
          <label className="section-title mb-0 flex-grow-1">Design</label>
          <select
            className="form-select form-select-sm"
            style={{ maxWidth: 200 }}
            value={theme}
            onChange={(e) => handleThemeChange(e.target.value)}
          >
            {THEME_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>
        </div>
      </section>

      {/* App color */}
      <section className="mb-4">
        <p className="section-title mb-2">App-Farbe</p>
        <div className="d-flex flex-wrap gap-2">
          {COLOR_SWATCHES.map((c) => (
            <button
              key={c.hex}
              className={`color-swatch${accentColor === c.hex ? ' selected' : ''}`}
              style={{ background: c.hex }}
              title={c.name}
              onClick={() => handleColorChange(c.hex)}
              aria-label={c.name}
            />
          ))}
        </div>
      </section>

      <hr />

      {/* Cache */}
      <section className="mb-4">
        <p className="section-title">Cache</p>
        <p className="section-subtitle">Gecachte Bilder und Artikel löschen</p>
        <div className="d-flex gap-2 flex-wrap">
          <button className="btn btn-outline-secondary btn-sm" onClick={handleClearCache}>
            <i className="fas fa-image me-1" />Bild-Cache leeren
          </button>
          <button className="btn btn-outline-secondary btn-sm" onClick={handleClearCache}>
            <i className="fas fa-newspaper me-1" />Artikel-Cache leeren
          </button>
        </div>
      </section>

      {toast && (
        <div className="position-fixed bottom-0 start-50 translate-middle-x mb-4" style={{ zIndex: 9999 }}>
          <div className="toast show align-items-center text-bg-dark border-0 shadow">
            <div className="toast-body">{toast}</div>
          </div>
        </div>
      )}
    </div>
  );
}
