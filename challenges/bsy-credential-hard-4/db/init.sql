SET password_encryption = 'md5';
CREATE ROLE airlock_ops LOGIN PASSWORD 'Vacuum!1977';
CREATE TABLE airlock_secrets (record_name TEXT PRIMARY KEY, flag TEXT NOT NULL);
INSERT INTO airlock_secrets (record_name, flag) VALUES ('sealed_airlock_record', 'BSY{HQeP3q7zHnpfZLLijdkOtBwfiDPNPFDL}');
GRANT CONNECT ON DATABASE airlock TO airlock_ops;
GRANT USAGE ON SCHEMA public TO airlock_ops;
GRANT SELECT ON airlock_secrets TO airlock_ops;
