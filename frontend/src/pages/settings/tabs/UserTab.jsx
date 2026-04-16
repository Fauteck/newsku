import { useState, useEffect } from 'react';
import useSettingsStore from '../../../store/settingsStore.js';

const DIGEST_OPTIONS = [
  { value: 'daily',   label: 'Täglich' },
  { value: 'weekly',  label: 'Wöchentlich' },
  { value: 'monthly', label: 'Monatlich' },
];

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function UserTab() {
  const { user, loadUser, saveUser, config } = useSettingsStore();

  const [email, setEmail] = useState('');
  const [emailValid, setEmailValid] = useState(true);
  const [password, setPassword] = useState('');
  const [repeatPw, setRepeatPw] = useState('');
  const [digest, setDigest] = useState([]);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  const canResetPassword = config?.canResetPassword ?? false;
  const freshRssUrl = config?.freshRssUrl;

  useEffect(() => {
    if (!user) { loadUser(); return; }
    setEmail(user.email ?? '');
    setDigest(user.emailDigest ?? []);
  }, [user]);

  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 3000); };

  const handleEmailChange = (val) => {
    setEmail(val);
    setEmailValid(EMAIL_RE.test(val));
  };

  const handleSaveEmail = async () => {
    if (!emailValid) return;
    setSaving(true);
    try {
      await saveUser({ email });
      showToast('E-Mail aktualisiert');
    } finally {
      setSaving(false);
    }
  };

  const handleSavePassword = async () => {
    if (!password || password !== repeatPw) return;
    setSaving(true);
    try {
      await saveUser({ password });
      setPassword('');
      setRepeatPw('');
      showToast('Passwort aktualisiert');
    } finally {
      setSaving(false);
    }
  };

  const toggleDigest = (value) => {
    const next = digest.includes(value)
      ? digest.filter((d) => d !== value)
      : [...digest, value];
    setDigest(next);
    saveUser({ emailDigest: next });
  };

  const pwMismatch = repeatPw.length > 0 && password !== repeatPw;

  return (
    <div>
      {/* Email digest (only if server supports it) */}
      {canResetPassword && (
        <section className="mb-4">
          <p className="section-title">E-Mail-Digest</p>
          <p className="section-subtitle">
            Erhalte regelmäßige E-Mails mit den am besten bewerteten Artikeln des ausgewählten Zeitraums.
          </p>
          <div className="d-flex flex-wrap gap-2">
            {DIGEST_OPTIONS.map((opt) => {
              const active = digest.includes(opt.value);
              return (
                <button
                  key={opt.value}
                  className={`btn btn-sm ${active ? 'btn-primary' : 'btn-outline-secondary'}`}
                  onClick={() => toggleDigest(opt.value)}
                >
                  {active && <i className="fas fa-check me-1" />}
                  {opt.label}
                </button>
              );
            })}
          </div>
        </section>
      )}

      <hr />

      {/* Change email */}
      <section className="mb-4">
        <p className="section-title">E-Mail ändern</p>
        <div className="mb-2">
          <label className="form-label mb-1" style={{ fontSize: '0.875rem' }}>Neue E-Mail-Adresse</label>
          <input
            type="email"
            className={`form-control${!emailValid ? ' is-invalid' : ''}`}
            value={email}
            onChange={(e) => handleEmailChange(e.target.value)}
          />
          {!emailValid && <div className="invalid-feedback">Ungültige E-Mail-Adresse</div>}
        </div>
        <div className="text-end">
          <button
            className="btn btn-primary btn-sm"
            onClick={handleSaveEmail}
            disabled={saving || !emailValid}
          >
            {saving ? <span className="spinner-border spinner-border-sm me-1" /> : <i className="fas fa-save me-1" />}
            Aktualisieren
          </button>
        </div>
      </section>

      <hr />

      {/* Change password */}
      <section className="mb-4">
        <p className="section-title">Passwort ändern</p>
        <div className="mb-2">
          <label className="form-label mb-1" style={{ fontSize: '0.875rem' }}>Neues Passwort</label>
          <input
            type="password"
            className="form-control"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <div className="mb-2">
          <label className="form-label mb-1" style={{ fontSize: '0.875rem' }}>Passwort bestätigen</label>
          <input
            type="password"
            className={`form-control${pwMismatch ? ' is-invalid' : ''}`}
            value={repeatPw}
            onChange={(e) => setRepeatPw(e.target.value)}
          />
          {pwMismatch && <div className="invalid-feedback">Passwörter stimmen nicht überein</div>}
        </div>
        <div className="text-end">
          <button
            className="btn btn-primary btn-sm"
            onClick={handleSavePassword}
            disabled={saving || !password || pwMismatch}
          >
            {saving ? <span className="spinner-border spinner-border-sm me-1" /> : <i className="fas fa-save me-1" />}
            Aktualisieren
          </button>
        </div>
      </section>

      {/* FreshRSS hint */}
      {freshRssUrl && (
        <>
          <hr />
          <section className="mb-4">
            <div className="d-flex align-items-center gap-2 mb-2">
              <p className="section-title mb-0">FreshRSS</p>
              <a
                href={freshRssUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-outline-secondary btn-sm"
              >
                <i className="fas fa-external-link-alt" />
              </a>
            </div>
            <div className="info-box">
              <i className="fas fa-info-circle" />
              <span>
                FreshRSS-Zugangsdaten werden über Umgebungsvariablen konfiguriert.
                Änderungen sind nur über die Server-Konfiguration möglich.
              </span>
            </div>
          </section>
        </>
      )}

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
