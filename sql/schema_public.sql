-- Crypto Market Intelligence Automation
-- Public schema for portfolio documentation.
-- No credentials, secrets, or private data included.

CREATE TABLE IF NOT EXISTS crypto_market_snapshots (
    id SERIAL PRIMARY KEY,
    coin_id TEXT NOT NULL,
    symbol TEXT NOT NULL,
    name TEXT NOT NULL,
    price_usd NUMERIC,
    market_cap NUMERIC,
    volume_24h NUMERIC,
    price_change_24h NUMERIC,
    price_change_7d NUMERIC,
    snapshot_time TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS crypto_market_analytics (
    id SERIAL PRIMARY KEY,
    coin TEXT NOT NULL,
    name TEXT NOT NULL,
    price_usd NUMERIC,
    price_change_24h NUMERIC,
    price_change_7d NUMERIC,
    volume_24h NUMERIC,
    avg_volume_7_snapshots NUMERIC,
    volume_spike NUMERIC,
    momentum_score NUMERIC,
    volume_score NUMERIC,
    trend_score NUMERIC,
    volatility_score NUMERIC,
    risk_score NUMERIC,
    risk_level TEXT,
    forecast_scenario TEXT,
    confidence_score NUMERIC,
    trigger_reasons TEXT,
    source_snapshot_time TIMESTAMP,
    calculated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS crypto_ai_reports (
    id SERIAL PRIMARY KEY,
    report_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS crypto_risk_alerts (
    id SERIAL PRIMARY KEY,
    coin TEXT NOT NULL,
    name TEXT NOT NULL,
    price_usd NUMERIC,
    price_change_24h NUMERIC,
    price_change_7d NUMERIC,
    volume_spike NUMERIC,
    risk_score NUMERIC,
    forecast_scenario TEXT,
    alert_reason TEXT,
    alert_text TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Latest analytics view

CREATE OR REPLACE VIEW v_crypto_latest_analytics AS
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY coin
            ORDER BY calculated_at DESC, id DESC
        ) AS rn
    FROM crypto_market_analytics
)
SELECT
    coin,
    name,
    price_usd,
    price_change_24h,
    price_change_7d,
    volume_24h,
    avg_volume_7_snapshots,
    volume_spike,
    momentum_score,
    volume_score,
    trend_score,
    volatility_score,
    risk_score,
    risk_level,
    forecast_scenario,
    confidence_score,
    trigger_reasons,
    source_snapshot_time,
    calculated_at
FROM ranked
WHERE rn = 1;

-- Market overview view

CREATE OR REPLACE VIEW v_crypto_market_overview AS
SELECT
    COUNT(*) AS coins_count,
    COUNT(*) FILTER (WHERE price_change_24h > 0) AS positive_24h_count,
    COUNT(*) FILTER (WHERE price_change_24h < 0) AS negative_24h_count,
    COUNT(*) FILTER (WHERE price_change_7d > 0) AS positive_7d_count,
    COUNT(*) FILTER (WHERE price_change_7d < 0) AS negative_7d_count,
    ROUND(AVG(risk_score), 2) AS avg_risk_score,
    MAX(risk_score) AS max_risk_score,
    MAX(volume_spike) AS max_volume_spike,
    MAX(calculated_at) AS last_calculated_at
FROM v_crypto_latest_analytics;

-- Recent risk alerts view

CREATE OR REPLACE VIEW v_crypto_recent_risk_alerts AS
SELECT
    id,
    coin,
    name,
    price_usd,
    price_change_24h,
    price_change_7d,
    volume_spike,
    risk_score,
    forecast_scenario,
    alert_reason,
    alert_text,
    created_at
FROM crypto_risk_alerts
ORDER BY created_at DESC;

-- Recent AI reports view

CREATE OR REPLACE VIEW v_crypto_ai_reports_recent AS
SELECT
    id,
    report_text,
    created_at
FROM crypto_ai_reports
ORDER BY created_at DESC;
