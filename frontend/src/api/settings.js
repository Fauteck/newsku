import client from './client.js';

// ---- Config ----
export const fetchConfig = () => client.get('/config').then((r) => r.data);

// ---- User ----
export const fetchUser = () => client.get('/api/users').then((r) => r.data);
export const updateUser = (payload) => client.post('/api/users', payload).then((r) => r.data);

// ---- Feeds ----
export const fetchFeeds = () => client.get('/api/feeds').then((r) => r.data);
export const addFeed = (url) => client.put('/api/feeds', { url }).then((r) => r.data);
export const updateFeed = (feed) => client.post('/api/feeds', feed).then((r) => r.data);
export const deleteFeed = (id) => client.delete(`/api/feeds/${id}`);
export const exportOpml = () =>
  client.get('/api/feeds/export', { responseType: 'blob' }).then((r) => r.data);
export const importOpml = (bytes) => {
  const formData = new FormData();
  formData.append('file', new Blob([bytes], { type: 'text/xml' }), 'feeds.opml');
  return client
    .post('/api/feeds/import', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    .then((r) => r.data);
};

// ---- Feed Categories ----
export const fetchCategories = () => client.get('/api/feed-categories').then((r) => r.data);
export const addCategory = (name) =>
  client.post('/api/feed-categories', { name }).then((r) => r.data);
export const deleteCategory = (id) => client.delete(`/api/feed-categories/${id}`);
export const renameCategory = (id, name) =>
  client.put(`/api/feed-categories/${id}`, { name }).then((r) => r.data);

// ---- Layout ----
export const fetchLayout = () => client.get('/api/layout').then((r) => r.data);
export const saveLayout = (blocks) => client.put('/api/layout', blocks).then((r) => r.data);
