-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS pastes (
    id BIGSERIAL PRIMARY KEY,
    sha256 TEXT UNIQUE NOT NULL,
    ext TEXT NOT NULL,
    mime TEXT NOT NULL,
    addr TEXT,
    ua TEXT,
    removed BOOLEAN NOT NULL DEFAULT FALSE,
    nsfw_score REAL,
    expiration BIGINT,
    mgmt_token TEXT,
    secret TEXT,
    last_vscan TIMESTAMP,
    size BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS pastes;