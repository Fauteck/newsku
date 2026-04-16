import { create } from 'zustand';
import client from '../api/client.js';

const useAuthStore = create((set) => ({
  token: localStorage.getItem('token') ?? null,
  user: null,

  login: async (username, password) => {
    const res = await client.post('/auth/token', { username, password });
    const token = res.data.token;
    localStorage.setItem('token', token);
    set({ token });
  },

  logout: () => {
    localStorage.removeItem('token');
    set({ token: null, user: null });
    window.location.href = '/login';
  },

  setUser: (user) => set({ user }),
}));

export default useAuthStore;
