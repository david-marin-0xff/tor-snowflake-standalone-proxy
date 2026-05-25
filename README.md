# ❄️ tor-snowflake-standalone-proxy ❄️

❄️ Cross-platform management and observability toolkit for the Tor Snowflake standalone proxy.

This project provides a lightweight command-line environment for running, monitoring, and managing dedicated Tor Snowflake standalone proxies across Windows, macOS, and Linux.

Unlike the browser extension version of Snowflake, this toolkit is designed around the idea of persistent volunteer infrastructure — providing improved uptime, operational visibility, and a more service-oriented deployment model.

<img width="1426" height="897" alt="image" src="https://github.com/user-attachments/assets/d71ee16f-a9b5-456d-9568-1b22ecb2c4df" />


---

# 🌐 What Is This Project?

`tor-snowflake-standalone-proxy` acts as a lightweight management and observability layer around the official Tor Snowflake standalone proxy.

The project focuses on:

- Proxy lifecycle management
- Runtime observability
- Relay activity monitoring
- Telemetry visibility
- Cross-platform operation
- Dedicated long-running deployments

The goal is to make operating a standalone Snowflake proxy feel more like running lightweight volunteer infrastructure rather than simply enabling a browser extension.

---

# 🚨 Why Use the Standalone Proxy Instead of the Browser Extension? 🚨

The browser extension version of Snowflake is intentionally designed for simplicity and casual participation.

This project targets a different use case:

> Persistent, dedicated Snowflake proxy operation with improved observability and operational control.

## Benefits of the standalone approach

- Persistent background operation
- No browser dependency
- Reduced browser throttling and sleeping
- Improved relay availability and uptime
- Better telemetry and debugging visibility
- Direct access to verbose operational logs
- Runtime analytics and monitoring
- More infrastructure-oriented deployment model

In practice, standalone proxies often appear more active because they:

- Stay online longer
- Continuously poll the broker
- Avoid browser power-saving interruptions
- Behave more like stable relay endpoints

---

# ✨ Features ✨

- Cross-platform architecture
- Windows PowerShell support
- macOS/Linux shell support
- Start / stop proxy management
- Live log monitoring
- Runtime statistics and telemetry
- NAT type detection
- Relay connection analytics
- WebRTC observability
- Log exporting
- Background process management

---

# 🖥️ Supported Platforms

| Platform | Status |
|---|---|
| Windows | Supported |
| macOS (Apple Silicon) | Supported |
| Linux | Supported via Unix shell tooling |

---

# 📦 Project Structure

```text
tor-snowflake-standalone-proxy/
│
├── bin/
│   └── macos/
│       └── proxy
│
├── binaries/
│   └── proxy.exe
│
├── exports/
├── logs/
│
├── config.json
├── config.macos.json
│
├── snowctl.ps1
├── snowctl.sh
│
└── README.md
```

---

# ⚡ Commands

## Windows (PowerShell)

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

## macOS / Linux

### Start proxy

```bash
./snowctl.sh start
```

### Stop proxy

```bash
./snowctl.sh stop
```

### Check status

```bash
./snowctl.sh status
```

### Live logs

```bash
./snowctl.sh logs
```

### Runtime statistics

```bash
./snowctl.sh stats
```

### Export logs

```bash
./snowctl.sh export
```

---

# 🛠️ macOS Build Instructions

The macOS version uses the official Tor Snowflake source code.

## Install Go

```bash
brew install go
```

## Clone Snowflake Source

```bash
git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake.git
```

## Build Proxy

```bash
cd snowflake/proxy
go build
```

## Copy Binary Into Project

```bash
cp ./proxy ~/Documents/tor-snowflake-standalone-proxy/bin/macos/
```

---

# 📊 Observability & Telemetry

This project exposes operational information that is normally hidden behind the browser extension abstraction.

Examples include:

- NAT type detection
- Relay connection tracking
- Session activity
- Runtime memory usage
- WebRTC connection state visibility
- Verbose proxy telemetry
- Relay connection history

The goal is to provide better insight into how Snowflake behaves operationally in real-world environments.

---

# 📖 Educational Purpose 📖

This project was also built as a networking and infrastructure learning exercise focused on:

- WebRTC
- NAT traversal
- Relay infrastructure
- Telemetry parsing
- Process lifecycle management
- PowerShell automation
- Unix shell scripting
- Distributed networking systems
- Runtime observability

---

# 🌐 About Snowflake

Snowflake is a Tor Project pluggable transport that helps censored users access the open internet through temporary volunteer proxy relays.

Official Project:

https://snowflake.torproject.org/

Tor Project:

https://www.torproject.org/
