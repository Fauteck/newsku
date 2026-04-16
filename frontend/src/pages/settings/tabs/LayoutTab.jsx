import { useEffect, useState } from 'react';
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import {
  SortableContext,
  verticalListSortingStrategy,
  useSortable,
  arrayMove,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import useSettingsStore, { BLOCK_TYPE_META, FIXED_SIZE_TYPES } from '../../../store/settingsStore.js';

export default function LayoutTab() {
  const { layoutBlocks, layoutLoading, layoutValid, loadLayout, setLayoutBlocks, saveLayout, categories } =
    useSettingsStore();

  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  useEffect(() => { loadLayout(); }, []);

  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 5 } }));

  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 3000); };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const oldIdx = layoutBlocks.findIndex((b) => b.id === active.id);
    const newIdx = layoutBlocks.findIndex((b) => b.id === over.id);
    setLayoutBlocks(arrayMove(layoutBlocks, oldIdx, newIdx));
  };

  const handleAddBlock = (type) => {
    const newBlock = {
      id: crypto.randomUUID(),
      type,
      settings: { title: '', categoryId: null },
    };
    setLayoutBlocks([...layoutBlocks, newBlock]);
  };

  const handleRemoveBlock = (id) => {
    if (layoutBlocks.length <= 1) return;
    setLayoutBlocks(layoutBlocks.filter((b) => b.id !== id));
  };

  const handleUpdateBlock = (id, patch) => {
    setLayoutBlocks(layoutBlocks.map((b) => (b.id === id ? { ...b, settings: { ...b.settings, ...patch } } : b)));
  };

  const handleSave = async () => {
    if (!layoutValid) return;
    setSaving(true);
    try {
      await saveLayout();
      showToast('Layout gespeichert');
    } finally {
      setSaving(false);
    }
  };

  if (layoutLoading) {
    return (
      <div className="text-center py-5">
        <div className="spinner-border spinner-border-primary" role="status">
          <span className="visually-hidden">Lade…</span>
        </div>
      </div>
    );
  }

  const fixedBlocks = Object.entries(BLOCK_TYPE_META).filter(([, m]) => m.fixed);
  const dynamicBlocks = Object.entries(BLOCK_TYPE_META).filter(([, m]) => !m.fixed);

  return (
    <div>
      <p className="text-muted" style={{ fontSize: '0.875rem' }}>
        Hier kannst du anpassen, wie deine RSS-Artikel angezeigt werden. Ordne die Block-Typen per Drag & Drop an.
        Artikel werden von wichtig nach unwichtig von oben nach unten eingefügt.
      </p>

      <div className="row g-3">
        {/* Left: palette */}
        <div className="col-12 col-lg-4">
          <div className="card h-100">
            <div className="card-header">
              <i className="fas fa-cubes me-2" />Verfügbare Blöcke
              <div className="text-muted mt-1" style={{ fontSize: '0.75rem' }}>
                Auf einen Block klicken, um ihn hinzuzufügen
              </div>
            </div>
            <div className="card-body">
              <p className="section-title mb-1">Fixer Artikelanzahl</p>
              {fixedBlocks.map(([type, meta]) => (
                <button
                  key={type}
                  className="block-palette-item w-100 text-start"
                  onClick={() => handleAddBlock(type)}
                >
                  <i className={`fas ${meta.icon}`} />
                  {meta.label}
                  <span className="badge bg-secondary ms-auto" style={{ fontSize: '0.65rem' }}>fix</span>
                </button>
              ))}
              <p className="section-title mt-3 mb-1">Dynamische Artikelanzahl</p>
              {dynamicBlocks.map(([type, meta]) => (
                <button
                  key={type}
                  className="block-palette-item w-100 text-start"
                  onClick={() => handleAddBlock(type)}
                >
                  <i className={`fas ${meta.icon}`} />
                  {meta.label}
                  <span className="badge bg-primary ms-auto" style={{ fontSize: '0.65rem' }}>dyn</span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Right: current layout */}
        <div className="col-12 col-lg-8">
          <div className="card">
            <div className="card-header d-flex align-items-center justify-content-between">
              <span><i className="fas fa-layer-group me-2" />Aktuelles Layout</span>
              <button
                className="btn btn-primary btn-sm"
                onClick={handleSave}
                disabled={saving || !layoutValid}
              >
                {saving
                  ? <span className="spinner-border spinner-border-sm me-1" />
                  : <i className="fas fa-save me-1" />}
                Speichern
              </button>
            </div>
            <div className="card-body">
              {!layoutValid && (
                <div className="alert alert-danger py-2 mb-2" style={{ fontSize: '0.8rem' }}>
                  <i className="fas fa-exclamation-triangle me-2" />
                  Das Layout muss mit einem dynamischen Block enden.
                </div>
              )}

              {layoutBlocks.length === 0 ? (
                <p className="text-muted text-center py-4" style={{ fontSize: '0.875rem' }}>
                  Noch keine Blöcke. Klicke links auf einen Typ, um ihn hinzuzufügen.
                </p>
              ) : (
                <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
                  <SortableContext items={layoutBlocks.map((b) => b.id)} strategy={verticalListSortingStrategy}>
                    {layoutBlocks.map((block, idx) => (
                      <SortableBlock
                        key={block.id}
                        block={block}
                        isLast={idx === layoutBlocks.length - 1}
                        canDelete={layoutBlocks.length > 1}
                        onRemove={() => handleRemoveBlock(block.id)}
                        onUpdate={(patch) => handleUpdateBlock(block.id, patch)}
                        categories={categories}
                      />
                    ))}
                  </SortableContext>
                </DndContext>
              )}
            </div>
          </div>
        </div>
      </div>

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

function SortableBlock({ block, isLast, canDelete, onRemove, onUpdate, categories }) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: block.id });
  const style = { transform: CSS.Transform.toString(transform), transition };
  const meta = BLOCK_TYPE_META[block.type] ?? { label: block.type, icon: 'fa-square', fixed: false };
  const isFixed = FIXED_SIZE_TYPES.includes(block.type);

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`layout-block-card${isDragging ? ' layout-block-dragging' : ''}`}
    >
      {/* Drag handle */}
      <span className="layout-block-drag-handle" {...listeners} {...attributes}>
        <i className="fas fa-grip-vertical" />
      </span>

      <div className="flex-grow-1">
        {/* Block type badge */}
        <div className="d-flex align-items-center gap-2 mb-2">
          <i className={`fas ${meta.icon} text-muted`} />
          <span className="fw-semibold" style={{ fontSize: '0.875rem' }}>{meta.label}</span>
          <span className={`badge ${isFixed ? 'bg-secondary' : 'bg-primary'} ms-1`} style={{ fontSize: '0.65rem' }}>
            {isFixed ? 'fix' : 'dyn'}
          </span>
          {isLast && !isFixed && (
            <span className="badge bg-success ms-1" style={{ fontSize: '0.65rem' }}>
              <i className="fas fa-star me-1" />letzter Block
            </span>
          )}
        </div>

        {/* Optional section title */}
        <div className="mb-2">
          <input
            type="text"
            className="form-control form-control-sm"
            placeholder="Abschnittstitel (optional)"
            value={block.settings?.title ?? ''}
            onChange={(e) => onUpdate({ title: e.target.value })}
          />
        </div>

        {/* Category selector */}
        <div>
          <select
            className="form-select form-select-sm"
            value={block.settings?.categoryId ?? ''}
            onChange={(e) => onUpdate({ categoryId: e.target.value || null })}
          >
            <option value="">Alle Kategorien</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Delete */}
      {canDelete && (
        <button
          className="btn btn-outline-danger btn-sm align-self-start"
          onClick={onRemove}
          title="Block entfernen"
        >
          <i className="fas fa-trash" />
        </button>
      )}
    </div>
  );
}
