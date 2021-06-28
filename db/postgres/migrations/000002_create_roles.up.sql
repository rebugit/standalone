REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE rebugit FROM PUBLIC;

-- Read/write role
CREATE ROLE readwrite;
GRANT CONNECT ON DATABASE rebugit TO readwrite;
GRANT USAGE, CREATE ON SCHEMA public TO readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO readwrite;

-- Users creation
-- this is only a temporary password, the migrator will get the password from SSM
CREATE USER app WITH LOGIN;
ALTER USER app WITH PASSWORD 'postgres';

-- Grant privileges to users
GRANT readwrite TO app;
