use std::process::Command;
use tauri::async_runtime::spawn_blocking;

#[tauri::command]
async fn proxy_status() -> Result<bool, String> {
    spawn_blocking(|| {
        let output = Command::new("powershell")
            .args([
                "-NoProfile",
                "-Command",
                "if (Get-Process proxy -ErrorAction SilentlyContinue) { 'running' } else { 'stopped' }",
            ])
            .output()
            .map_err(|e| e.to_string())?;

        Ok::<bool, String>(
            String::from_utf8_lossy(&output.stdout).trim() == "running",
        )
    })
    .await
    .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_pid() -> Result<Option<u32>, String> {
    spawn_blocking(|| {
        let output = Command::new("powershell")
            .args([
                "-NoProfile",
                "-Command",
                "$p = Get-Process proxy -ErrorAction SilentlyContinue; if ($p) { $p.Id }",
            ])
            .output()
            .map_err(|e| e.to_string())?;

        let stdout = String::from_utf8_lossy(&output.stdout).trim().to_string();

        if stdout.is_empty() {
            Ok(None)
        } else {
            stdout
                .parse::<u32>()
                .map(Some)
                .map_err(|e| e.to_string())
        }
    })
    .await
    .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_start() -> Result<String, String> {
    spawn_blocking(|| run_controller("start"))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_stop() -> Result<String, String> {
    spawn_blocking(|| run_controller("stop"))
        .await
        .map_err(|e| e.to_string())?
}

fn run_controller(action: &str) -> Result<String, String> {
    let script = r"C:\Users\David\snowflake\snowctl.ps1";

    let output = Command::new("powershell")
        .args([
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            script,
            action,
        ])
        .output()
        .map_err(|e| e.to_string())?;

    if !output.status.success() {
        return Err(
            String::from_utf8_lossy(&output.stderr)
                .trim()
                .to_string(),
        );
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            proxy_status,
            proxy_start,
            proxy_stop,
            proxy_pid
        ])
        .run(tauri::generate_context!())
        .expect("error while running application");
}