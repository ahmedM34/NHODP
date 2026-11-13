// NHODP MongoDB Initialization Script
// Runs once on first container startup (as root/admin)

// Switch to the application database
db = db.getSiblingDB('nhodp_datasets');

// ── datasets collection ──────────────────────────────────────────────────────
db.createCollection('datasets');
db.datasets.createIndex({ "category": 1 });
db.datasets.createIndex({ "downloads": -1 });
db.datasets.createIndex({ "created_at": -1 });
db.datasets.createIndex({ "title": "text", "description": "text", "tags": "text" });

// ── ocr_jobs collection ──────────────────────────────────────────────────────
db.createCollection('ocr_jobs');
db.ocr_jobs.createIndex({ "job_id": 1 }, { unique: true });
db.ocr_jobs.createIndex({ "created_at": -1 });
db.ocr_jobs.createIndex({ "status": 1 });

// ── qatar_datasets collection ────────────────────────────────────────────────
db.createCollection('qatar_datasets');
db.qatar_datasets.createIndex({ "dataset_id": 1 }, { unique: true });
db.qatar_datasets.createIndex({ "category": 1 });
db.qatar_datasets.createIndex({ "downloads": -1 });
db.qatar_datasets.createIndex({ "title": "text", "description": "text" });

// ── analytics collection ─────────────────────────────────────────────────────
db.createCollection('analytics_events');
db.analytics_events.createIndex({ "timestamp": -1 });
db.analytics_events.createIndex({ "event_type": 1 });

print('NHODP MongoDB initialization complete — all indexes created');
