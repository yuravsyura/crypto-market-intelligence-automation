# Architecture

## High-Level System

```text
CoinGecko API
    ↓
n8n Workflow
    ↓
Normalize Crypto Data
    ↓
Supabase / PostgreSQL
    ├── crypto_market_snapshots
    ├── crypto_market_analytics
    ├── crypto_ai_reports
    └── crypto_risk_alerts
    ↓
Calculate Analytics v2
    ├── AI Market Brief → Telegram
    ├── Risk Alert → Cooldown → Telegram
    └── Telegram Commands
```

## Main Workflow

The main workflow is responsible for scheduled data collection, analytics calculation, AI reporting, and risk alerts.

```text
Schedule Trigger / Manual Trigger
↓
HTTP Request — CoinGecko API
↓
Normalize Crypto Data
↓
Insert rows into crypto_market_snapshots
↓
Run SQL Once
↓
Execute SQL query to fetch latest data and average volume baseline
↓
Calculate Analytics v2
├── Save Market Analytics
├── Build AI Report Input → AI Agent → Save AI Report → Telegram Market Brief
└── If Risk Alert → Build Risk Alert Message → Cooldown check → Save Risk Alert → Telegram Risk Alert
```

## Telegram Commands Workflow

A separate workflow handles interactive Telegram commands.

```text
Telegram Trigger
↓
Build SQL Command
↓
Execute Command SQL
↓
Build Telegram Reply
↓
Send Command Reply
```

Supported commands:

- `/status`
- `/risk`
- `/top`
- `/alerts`
- `/report`
- `/help`

## Database Tables

### `crypto_market_snapshots`

Stores raw normalized data from CoinGecko.

### `crypto_market_analytics`

Stores calculated analytics and internal scoring data.

### `crypto_ai_reports`

Stores AI-generated market briefs.

### `crypto_risk_alerts`

Stores risk alert history and alert reasons.

## Security

The repository does not include:

- API keys;
- Telegram bot token;
- Supabase credentials;
- OpenAI credentials;
- webhook IDs;
- private chat IDs;
- full n8n export containing sensitive metadata.
