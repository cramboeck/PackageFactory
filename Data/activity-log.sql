-- PackageFactory Activity Log Database
-- Tracks all actions performed in the application

CREATE TABLE IF NOT EXISTS activity_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    action_type TEXT NOT NULL,  -- 'app_upload', 'app_assign', 'group_create', 'group_delete', 'member_add', 'member_remove'
    app_id TEXT,                -- Intune app ID (if applicable)
    app_name TEXT,              -- App display name
    group_id TEXT,              -- Group ID (if applicable)
    group_name TEXT,            -- Group name
    user_id TEXT,               -- User ID (if applicable)
    user_name TEXT,             -- User name
    intent TEXT,                -- Assignment intent (required/available/uninstall)
    details TEXT,               -- JSON with additional details
    success INTEGER NOT NULL DEFAULT 1,  -- 1 = success, 0 = failed
    error_message TEXT,         -- Error message if failed
    ip_address TEXT,            -- Client IP (for audit)
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_timestamp ON activity_log(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_action_type ON activity_log(action_type);
CREATE INDEX IF NOT EXISTS idx_app_id ON activity_log(app_id);
CREATE INDEX IF NOT EXISTS idx_group_id ON activity_log(group_id);
CREATE INDEX IF NOT EXISTS idx_created_at ON activity_log(created_at DESC);

-- Sample data
INSERT INTO activity_log (action_type, app_name, details, success)
VALUES ('system', 'PackageFactory Activity Log Initialized', '{"version": "1.0"}', 1);
