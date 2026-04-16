import { useState, useEffect, useRef } from 'react';
import useSettingsStore from '../../../store/settingsStore.js';

const URL_RE = /[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)/i;

export default function FeedsTab() {
  const {
    feeds, categories, feedsLoading, feedsError,
    loadFeeds, addFeed, deleteFeed,
    addCategory, deleteCategory, renameCategory,
    exportOpml, importOpml,
    config,
  } = useSettingsStore();

  const [newUrl, setNewUrl] = useState('');
  const [urlError, setUrlError] = useState('');
  const [adding, setAdding] = useState(false);
  const [toast, setToast] = useState(null);
  const [newCatName, setNewCatName] = useState('');
  const [showCatInput, setShowCatInput] = useState(false);
  const [renamingCat, setRenamingCat] = useState(null);
  const [renameValue, setRenameValue] = useState('');
  const fileRef = useRef(null);

  const freshRssActive = !!config?.freshRssUrl;

  useEffect(() => { loadFeeds(); }, []);

  const showToast = (msg) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const handleAddFeed = async (e) => {
    e.preventDefault();
    if (!URL_RE.test(newUrl)) {
      setUrlError('Ungültige URL');
      return;
    }
    setUrlError('');
    setAdding(true);
    try {
      await addFeed(newUrl);
      setNewUrl('');
      showToast('Feed hinzugefügt');
    } catch {
      setUrlError('Feed konnte nicht hinzugefügt werden');
    } finally {
      setAdding(false);
    }
  };

  const handleDelete = async (id, name) => {
    if (!window.confirm(`Feed „${name}" und alle Artikel löschen?`)) return;
    await deleteFeed(id);
    showToast('Feed gelöscht');
  };

  const handleAddCategory = async () => {
    if (!newCatName.trim()) return;
    await addCategory(newCatName.trim());
    setNewCatName('');
    setShowCatInput(false);
    showToast('Kategorie hinzugefügt');
  };

  const handleDeleteCategory = async (id, name) => {
    if (!window.confirm(`Kategorie „${name}" und alle Feeds darin löschen?`)) return;
    await deleteCategory(id);
    showToast('Kategorie gelöscht');
  };

  const handleRename = async (id) => {
    if (!renameValue.trim()) return;
    await renameCategory(id, renameValue.trim());
    setRenamingCat(null);
    setRenameValue('');
    showToast('Kategorie umbenannt');
  };

  const handleExport = async () => {
    await exportOpml();
  };

  const handleImport = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const bytes = await file.arrayBuffer();
    const feeds = await importOpml(bytes);
    showToast(`${feeds.length} Feed(s) importiert`);
    e.target.value = '';
  };

  if (feedsLoading) {
    return (
      <div className="text-center py-5">
        <div className="spinner-border spinner-border-primary" role="status">
          <span className="visually-hidden">Lade…</span>
        </div>
      </div>
    );
  }

  if (feedsError) {
    return (
      <div className="alert alert-danger">
        <i className="fas fa-exclamation-circle me-2" />{feedsError}
      </div>
    );
  }

  return (
    <div>
      {/* FreshRSS info banner */}
      {freshRssActive && (
        <div className="info-box mb-3">
          <i className="fas fa-info-circle" />
          <span>
            Feeds werden über FreshRSS verwaltet.{' '}
            <a href={config.freshRssUrl} target="_blank" rel="noopener noreferrer">
              In FreshRSS öffnen <i className="fas fa-external-link-alt ms-1" />
            </a>
          </span>
        </div>
      )}

      {/* Add feed form (only without FreshRSS) */}
      {!freshRssActive && (
        <>
          <form onSubmit={handleAddFeed} className="d-flex gap-2 mb-2 align-items-start">
            <div className="flex-grow-1">
              <input
                type="url"
                className={`form-control${urlError ? ' is-invalid' : ''}`}
                placeholder="Neue Feed-URL"
                value={newUrl}
                onChange={(e) => setNewUrl(e.target.value)}
              />
              {urlError && <div className="invalid-feedback">{urlError}</div>}
            </div>
            <button className="btn btn-primary" type="submit" disabled={adding}>
              {adding
                ? <span className="spinner-border spinner-border-sm me-1" />
                : <i className="fas fa-plus me-1" />}
              Feed hinzufügen
            </button>
          </form>

          {/* Toolbar */}
          <div className="d-flex gap-2 flex-wrap mb-3">
            <button className="btn btn-outline-secondary btn-sm" onClick={() => setShowCatInput(!showCatInput)}>
              <i className="fas fa-folder-plus me-1" />Kategorie hinzufügen
            </button>
            <button className="btn btn-outline-secondary btn-sm" onClick={handleExport}>
              <i className="fas fa-download me-1" />Exportieren
            </button>
            <button className="btn btn-outline-secondary btn-sm" onClick={() => fileRef.current?.click()}>
              <i className="fas fa-upload me-1" />Importieren
            </button>
            <input
              type="file"
              accept=".opml"
              ref={fileRef}
              className="d-none"
              onChange={handleImport}
            />
          </div>

          {/* New category inline input */}
          {showCatInput && (
            <div className="d-flex gap-2 mb-3">
              <input
                type="text"
                className="form-control form-control-sm"
                placeholder="Kategoriename"
                value={newCatName}
                onChange={(e) => setNewCatName(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleAddCategory()}
                autoFocus
              />
              <button className="btn btn-sm btn-primary" onClick={handleAddCategory}>
                Hinzufügen
              </button>
              <button className="btn btn-sm btn-outline-secondary" onClick={() => setShowCatInput(false)}>
                Abbrechen
              </button>
            </div>
          )}
        </>
      )}

      {/* Feed list by categories */}
      {categories.length === 0 && feeds.length === 0 ? (
        <div className="text-center py-5 text-muted">
          <i className="fas fa-face-meh fa-3x mb-3 d-block" />
          <p>Noch keine Feeds vorhanden.<br />Feed-URL oben eingeben oder OPML importieren.</p>
        </div>
      ) : (
        categories.map((cat) => {
          const catFeeds = feeds.filter((f) => f.category?.id === cat.id);
          return (
            <div key={cat.id} className="mb-4">
              <div className="d-flex align-items-center gap-2 mb-2">
                {renamingCat === cat.id ? (
                  <>
                    <input
                      type="text"
                      className="form-control form-control-sm"
                      value={renameValue}
                      onChange={(e) => setRenameValue(e.target.value)}
                      onKeyDown={(e) => e.key === 'Enter' && handleRename(cat.id)}
                      autoFocus
                      style={{ maxWidth: 200 }}
                    />
                    <button className="btn btn-sm btn-primary" onClick={() => handleRename(cat.id)}>
                      Speichern
                    </button>
                    <button className="btn btn-sm btn-outline-secondary" onClick={() => setRenamingCat(null)}>
                      Abbrechen
                    </button>
                  </>
                ) : (
                  <>
                    <span className="fw-semibold text-muted" style={{ fontSize: '0.8rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                      <i className="fas fa-folder me-1" />{cat.name}
                    </span>
                    {!freshRssActive && (
                      <>
                        <button
                          className="btn btn-link btn-sm p-0 text-muted"
                          title="Umbenennen"
                          onClick={() => { setRenamingCat(cat.id); setRenameValue(cat.name); }}
                        >
                          <i className="fas fa-pencil-alt" style={{ fontSize: '0.75rem' }} />
                        </button>
                        <button
                          className="btn btn-link btn-sm p-0 text-danger"
                          title="Kategorie löschen"
                          onClick={() => handleDeleteCategory(cat.id, cat.name)}
                        >
                          <i className="fas fa-trash" style={{ fontSize: '0.75rem' }} />
                        </button>
                      </>
                    )}
                  </>
                )}
              </div>
              {catFeeds.length === 0 ? (
                <p className="text-muted ms-2" style={{ fontSize: '0.8rem' }}>Keine Feeds in dieser Kategorie</p>
              ) : (
                catFeeds.map((feed) => (
                  <FeedItem
                    key={feed.id}
                    feed={feed}
                    onDelete={() => handleDelete(feed.id, feed.title ?? feed.url)}
                    readonly={freshRssActive}
                  />
                ))
              )}
            </div>
          );
        })
      )}

      {/* Toast */}
      {toast && (
        <div
          className="position-fixed bottom-0 start-50 translate-middle-x mb-4"
          style={{ zIndex: 9999 }}
        >
          <div className="toast show align-items-center text-bg-dark border-0 shadow">
            <div className="d-flex">
              <div className="toast-body">{toast}</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function FeedItem({ feed, onDelete, readonly }) {
  return (
    <div className="feed-item">
      {feed.imageUrl && (
        <img
          src={`/api/feeds/${feed.id}/image`}
          alt=""
          className="feed-item-favicon"
          onError={(e) => { e.target.style.display = 'none'; }}
        />
      )}
      <span className="feed-item-title" title={feed.url}>
        {feed.title ?? feed.url}
      </span>
      {feed.category && (
        <span className="badge bg-secondary" style={{ fontSize: '0.7rem' }}>
          {feed.category.name}
        </span>
      )}
      {!readonly && (
        <button
          className="btn btn-outline-danger btn-sm ms-auto"
          title="Feed löschen"
          onClick={onDelete}
          style={{ flexShrink: 0 }}
        >
          <i className="fas fa-trash" />
        </button>
      )}
    </div>
  );
}
