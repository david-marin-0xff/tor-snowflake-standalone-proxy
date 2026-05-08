# tor-snowflake-standalone-proxy

A PowerShell-based observability and management CLI for the Tor Snowflake standalone proxy.

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