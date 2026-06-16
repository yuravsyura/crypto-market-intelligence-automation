# Risk Score Logic

The project uses an internal scoring model to identify assets that may require attention.

The score is not an objective risk rating and should not be treated as financial advice.

## Input Metrics

The analytics engine uses:

- 24h price change;
- 7d price change;
- 24h trading volume;
- average volume from previous snapshots;
- calculated volume spike.

## Volume Spike

```text
volume_spike = current_volume_24h / average_volume_previous_snapshots
```

If there is not enough historical volume data, the workflow uses the current volume as fallback, resulting in a baseline spike close to `1.0x`.

## Component Scores

### Momentum Score

Measures the strength of price movement using 24h and 7d changes.

```text
momentum_score = abs(24h_change) * 3 + abs(7d_change) * 1.2
```

The score is capped internally.

### Volume Score

Measures abnormal trading activity.

Example logic:

```text
volume_spike >= 2.0  → strong volume score
volume_spike >= 1.5  → medium volume score
volume_spike >= 1.2  → mild volume score
```

### Trend Score

Checks whether 24h and 7d movement point in the same direction.

Examples:

```text
24h positive + 7d positive → upward trend component
24h negative + 7d negative → downward trend component
```

### Volatility Score

Measures the size of 24h movement.

Examples:

```text
abs(24h_change) >= 8 → high volatility component
abs(24h_change) >= 5 → medium volatility component
abs(24h_change) >= 3 → mild volatility component
```

## Final Risk Score

```text
risk_score = momentum_score + volume_score + trend_score + volatility_score
```

The final score is capped between `0` and `100`.

## Risk Levels

```text
risk_score >= 75 → High
risk_score >= 50 → Elevated
risk_score >= 30 → Moderate
risk_score < 30  → Low
```

## Alert Conditions

A Telegram Risk Alert is triggered when at least one condition is met:

```text
risk_score >= 60
OR volume_spike >= 2
OR price_change_24h >= 8
OR price_change_24h <= -8
```

## Cooldown Logic

Before sending a risk alert, the system checks whether the same coin already received an alert in the last 12 hours.

If yes, the alert is not sent again.

This prevents repeated Telegram spam.

## Disclaimer

This is an internal analytics model for educational and portfolio purposes only. It is not a trading signal, investment advice, or financial recommendation.
