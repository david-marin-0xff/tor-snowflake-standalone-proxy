
# tor-snowflake-standalone-proxy

A PowerShell-based observability and management CLI for the Tor Snowflake standalone proxy.

<img width="250" height="250" alt="image" src="https://github.com/user-attachments/assets/fb60b4fc-300a-4ac4-874d-d7e1014e3043" />


This project provides a lightweight command-line environment for running and monitoring a standalone Tor Snowflake proxy on Windows using PowerShell.

#  Unlike the browser extension version of Snowflake, this setup behaves more like a persistent volunteer relay service:

Runs independently from the browser

Avoids browser throttling and sleeping tabs

Stays online continuously

Provides direct observability into relay activity

Exposes operational telemetry and runtime statistics

The result is a more infrastructure-oriented Snowflake deployment with significantly better visibility into how the proxy operates.

## Why Use the Standalone Proxy Instead of the Browser Extension?

The browser extension version of Snowflake is designed for casual volunteering and simplicity.

This standalone CLI approach is closer to running dedicated volunteer infrastructure.

Benefits of the standalone approach
Persistent background operation
No browser dependency
Reduced browser power-saving interference
Better relay availability and stability
Improved telemetry and debugging visibility
Direct access to verbose operational logs
Runtime analytics and monitoring

In practice, the standalone proxy often appears more active because:

It remains online longer
It polls the broker continuously
It is less likely to be suspended by the browser
It behaves more like a stable relay endpoint

---

## Features

- Start / stop Snowflake proxy
- Live log monitoring
- NAT type detection
- Relay connection analytics
- Session telemetry
- Runtime statistics
- Log exporting
- WebRTC observability

---

## Commands

### Start proxy

```powershell
.\snowctl.ps1 start
```

### Stop proxy

```powershell
.\snowctl.ps1 stop
```

### Check status

```powershell
.\snowctl.ps1 status
```

### Live logs

```powershell
.\snowctl.ps1 logs
```

### Runtime statistics

```powershell
.\snowctl.ps1 stats
```

### Export logs

```powershell
.\snowctl.ps1 export
```

---

## Project Structure

```text
tor-snowflake-standalone-proxy/
│
├── binaries/
│   └── proxy.exe
│
├── exports/
├── logs/
│
├── .gitignore
├── config.json
├── snowctl.ps1
└── README.md
```

---

## Requirements

- Windows PowerShell
- Tor Snowflake standalone proxy binary

---

## About Snowflake

Snowflake is a Tor Project pluggable transport that helps censored users access the open internet through temporary proxy relays.

Official Project:
https://snowflake.torproject.org/
