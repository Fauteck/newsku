-- Widen the GReader API password column to hold AES-GCM ciphertext
-- (Base64(iv || ciphertext || tag) + small prefix). Legacy plaintext rows
-- remain readable and get re-encrypted on the next write — see
-- StringCryptoConverter#convertToEntityAttribute.

ALTER TABLE users ALTER COLUMN freshrss_api_password TYPE TEXT;
