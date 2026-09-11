use std::process::Command;

#[cfg(windows)]
use std::os::windows::process::CommandExt;

use tauri::async_runtime::spawn_blocking;
use tauri::path::BaseDirectory;
use tauri::Manager;

// Windows flag: CREATE_NO_WINDOW
// Prevents PowerShell from opening a visible console window.
#[cfg(windows)]
const CREATE_NO_WINDOW: u32 = 0x08000000;

#[tauri::command]
async fn proxy_stats(app: tauri::AppHandle) -> Result<String, String> {
    spawn_blocking(move || run_controller(&app, "json"))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_start(app: tauri::AppHandle) -> Result<String, String> {
    spawn_blocking(move || run_controller_async(&app, "start"))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_stop(app: tauri::AppHandle) -> Result<String, String> {
    spawn_blocking(move || run_controller_async(&app, "stop"))
        .await
        .map_err(|e| e.to_string())?
}

// View the Snowflake log.
#[tauri::command]
async fn proxy_logs(app: tauri::AppHandle) -> Result<String, String> {
    spawn_blocking(move || run_controller(&app, "logs"))
        .await
        .map_err(|e| e.to_string())?
}

fn controller_path(app: &tauri::AppHandle) -> Result<std::path::PathBuf, String> {
    app.path()
        .resolve("snowctl.ps1", BaseDirectory::Resource)
        .map_err(|e| format!("Failed to locate bundled snowctl.ps1: {e}"))
}

fn run_controller(
    app: &tauri::AppHandle,
    action: &str,
) -> Result<String, String> {
    let controller = controller_path(app)?;

    let mut command = Command::new("powershell");

    command.args([
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
    ]);

    command.arg(&controller);
    command.arg(action);

    #[cfg(windows)]
    command.creation_flags(CREATE_NO_WINDOW);

    let output = command
        .output()
        .map_err(|e| format!("Failed to execute controller: {e}"))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr)
            .trim()
            .to_string();

        return Err(if stderr.is_empty() {
            format!(
                "snowctl.ps1 exited with status {}",
                output.status
            )
        } else {
            stderr
        });
    }

    Ok(String::from_utf8_lossy(&output.stdout)
        .trim()
        .to_string())
}

fn run_controller_async(
    app: &tauri::AppHandle,
    action: &str,
) -> Result<String, String> {
    let controller = controller_path(app)?;

    let mut command = Command::new("powershell");

    command.args([
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
    ]);

    command.arg(&controller);
    command.arg(action);

    #[cfg(windows)]
    command.creation_flags(CREATE_NO_WINDOW);

    command
        .spawn()
        .map_err(|e| format!("Failed to launch controller: {e}"))?;

    Ok(format!("{action} command dispatched"))
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            proxy_stats,
            proxy_start,
            proxy_stop,
            proxy_logs
        ])
        .run(tauri::generate_context!())
        .expect("error while running application");
}