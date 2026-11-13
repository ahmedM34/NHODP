-- NHODP PostgreSQL Initialization Script
-- Runs once on first container startup

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- The tables themselves are created by SQLAlchemy on service startup.
-- This script just ensures extensions and any manual indexes are in place.

-- Full-text search index will be added once tables exist (via services).
-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE nhodp TO nhodp;

-- Log
DO $$ BEGIN
  RAISE NOTICE 'NHODP PostgreSQL initialization complete';
END $$;
