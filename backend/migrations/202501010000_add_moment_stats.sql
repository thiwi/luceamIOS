CREATE TABLE IF NOT EXISTS moment_stats (
  moment_id       UUID NOT NULL REFERENCES moments(id) ON DELETE CASCADE,
  window_start    TIMESTAMPTZ NOT NULL,
  window_end      TIMESTAMPTZ NOT NULL,
  peak_concurrent INTEGER NOT NULL DEFAULT 0,
  unique_participants INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (moment_id, window_start, window_end)
);

CREATE VIEW IF NOT EXISTS moment_stats_latest AS
SELECT DISTINCT ON (moment_id)
  moment_id, window_start, window_end, peak_concurrent, unique_participants, created_at
FROM moment_stats
ORDER BY moment_id, window_end DESC;
