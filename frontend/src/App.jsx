import { Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from './components/layout/AppLayout.jsx';
import SettingsPage from './pages/settings/SettingsPage.jsx';
import useAuthStore from './store/authStore.js';

function ProtectedRoute({ children }) {
  const token = useAuthStore((s) => s.token);
  if (!token) return <Navigate to="/login" replace />;
  return children;
}

export default function App() {
  return (
    <Routes>
      <Route
        path="/einstellungen"
        element={
          <ProtectedRoute>
            <AppLayout>
              <SettingsPage />
            </AppLayout>
          </ProtectedRoute>
        }
      />
      {/* Redirect root and unknown paths to settings for now */}
      <Route path="/" element={<Navigate to="/einstellungen" replace />} />
      <Route path="*" element={<Navigate to="/einstellungen" replace />} />
    </Routes>
  );
}
