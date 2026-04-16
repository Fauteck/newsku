import { create } from 'zustand';
import {
  fetchFeeds,
  fetchCategories,
  addFeed as apiAddFeed,
  deleteFeed as apiDeleteFeed,
  addCategory as apiAddCategory,
  deleteCategory as apiDeleteCategory,
  renameCategory as apiRenameCategory,
  exportOpml as apiExportOpml,
  importOpml as apiImportOpml,
  fetchLayout as apiFetchLayout,
  saveLayout as apiSaveLayout,
  fetchUser as apiFetchUser,
  updateUser as apiUpdateUser,
  fetchConfig as apiFetchConfig,
} from '../api/settings.js';

const useSettingsStore = create((set, get) => ({
  // ---- Config ----
  config: null,
  loadConfig: async () => {
    const config = await apiFetchConfig();
    set({ config });
  },

  // ---- User ----
  user: null,
  loadUser: async () => {
    const user = await apiFetchUser();
    set({ user });
  },
  saveUser: async (payload) => {
    const user = await apiUpdateUser(payload);
    set({ user });
    return user;
  },

  // ---- Feeds ----
  feeds: [],
  categories: [],
  feedsLoading: false,
  feedsError: null,

  loadFeeds: async () => {
    set({ feedsLoading: true, feedsError: null });
    try {
      const [feeds, categories] = await Promise.all([fetchFeeds(), fetchCategories()]);
      set({ feeds, categories });
    } catch (err) {
      set({ feedsError: err.message });
    } finally {
      set({ feedsLoading: false });
    }
  },

  addFeed: async (url) => {
    const feed = await apiAddFeed(url);
    set((s) => ({ feeds: [...s.feeds, feed] }));
    return feed;
  },

  deleteFeed: async (id) => {
    await apiDeleteFeed(id);
    set((s) => ({ feeds: s.feeds.filter((f) => f.id !== id) }));
  },

  addCategory: async (name) => {
    const cat = await apiAddCategory(name);
    set((s) => ({ categories: [...s.categories, cat] }));
    return cat;
  },

  deleteCategory: async (id) => {
    await apiDeleteCategory(id);
    set((s) => ({ categories: s.categories.filter((c) => c.id !== id) }));
  },

  renameCategory: async (id, name) => {
    const cat = await apiRenameCategory(id, name);
    set((s) => ({
      categories: s.categories.map((c) => (c.id === id ? cat : c)),
    }));
  },

  exportOpml: async () => {
    const blob = await apiExportOpml();
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'feeds.opml';
    a.click();
    URL.revokeObjectURL(url);
  },

  importOpml: async (bytes) => {
    const feeds = await apiImportOpml(bytes);
    await get().loadFeeds();
    return feeds;
  },

  // ---- Layout ----
  layoutBlocks: [],
  layoutLoading: false,
  layoutValid: true,

  loadLayout: async () => {
    set({ layoutLoading: true });
    try {
      const blocks = await apiFetchLayout();
      set({ layoutBlocks: blocks, layoutValid: true });
    } finally {
      set({ layoutLoading: false });
    }
  },

  setLayoutBlocks: (blocks) => {
    const valid = blocks.length === 0 || !FIXED_SIZE_TYPES.includes(blocks[blocks.length - 1].type);
    set({ layoutBlocks: blocks, layoutValid: valid });
  },

  saveLayout: async () => {
    const { layoutBlocks } = get();
    await apiSaveLayout(layoutBlocks);
  },
}));

// Block types that have a fixed article count (cannot be last block)
export const FIXED_SIZE_TYPES = ['bigHeadline', 'bigHeadlinePicture', 'topStories'];

export const BLOCK_TYPE_META = {
  bigHeadline:        { label: 'Überschrift',          icon: 'fa-heading',         fixed: true },
  bigHeadlinePicture: { label: 'Überschrift mit Bild', icon: 'fa-image',           fixed: true },
  topStories:         { label: 'Top Stories',          icon: 'fa-star',            fixed: true },
  bigGrid:            { label: 'Großes Raster',        icon: 'fa-th-large',        fixed: false },
  bigGridPicture:     { label: 'Großes Bildraster',    icon: 'fa-th',              fixed: false },
  smallGrid:          { label: 'Kleines Raster',       icon: 'fa-grip-horizontal', fixed: false },
  searchResult:       { label: 'Suchergebnis',         icon: 'fa-search',          fixed: false },
};

export default useSettingsStore;
