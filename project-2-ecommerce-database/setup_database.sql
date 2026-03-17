-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — DATABASE SETUP
-- ============================================================
-- Run this FIRST to create the database and enable extensions.
-- ============================================================

CREATE DATABASE ecommerce_platform;

-- After connecting to ecommerce_platform, run:
-- \c ecommerce_platform

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;       -- pgvector for AI embeddings
CREATE EXTENSION IF NOT EXISTS pg_trgm;      -- trigram similarity for fuzzy search