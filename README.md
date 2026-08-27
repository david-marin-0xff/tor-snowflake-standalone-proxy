## 🚧 Project Update — GUI & Release Preparation

**tor-snowflake-standalone-proxy** is currently undergoing active development and release preparation.

Development is currently focused on completing and polishing the new **Tauri-based desktop GUI**, improving Windows integration, testing the proxy lifecycle and controller, validating runtime statistics and observability, and preparing the project's first proper binary release alongside the source code.

The current development workflow is intentionally incremental:

**Local development → local testing → validation → Git commit → GitHub update**

This allows changes to be tested against a real running Snowflake proxy before being incorporated into the public repository.

The current target is to have the project in a clean, shareable state by **Tuesday, August 25, 2026**.

The GUI and release components are still being actively improved, so some functionality, documentation, and packaging details may continue to change during this preparation period.

---

## 🖥️ Initial Terminal Version

Before the desktop GUI, the project was developed and operated entirely through the terminal.

The original version introduced the core management and observability functionality through the `snowctl` controller, providing commands for starting and stopping the Snowflake proxy, checking its status, monitoring logs, viewing runtime statistics, and exporting logs.

<img width="1426" height="897" alt="Snowflake standalone proxy terminal dashboard" src="https://github.com/user-attachments/assets/d71ee16f-a9b5-456d-9568-1b22ecb2c4df" />

This terminal implementation became the foundation for the current GUI. Rather than replacing the controller, the desktop application builds on top of the same underlying proxy management and telemetry functionality.

The development process therefore evolved as:

**Terminal controller → validated proxy management & observability → Tauri desktop GUI**

The terminal version remains functional and available for users who prefer a lightweight command-line workflow.