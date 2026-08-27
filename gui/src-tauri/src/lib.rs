use std::process::Command;
use tauri::async_runtime::spawn_blocking;

const CONTROLLER: &str = r"C:\Users\David\snowflake\snowctl.ps1";

#[tauri::command]
async fn proxy_stats() -> Result<String, String> {
    spawn_blocking(|| run_controller("json"))
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_start() -> Result<String, String> {
    spawn_blocking(|| {
        Command::new("powershell")
            .args([
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                CONTROLLER,
                "start",
            ])
            .spawn()
            .map_err(|e| format!("Failed to launch controller: {e}"))?;

        Ok("start command dispatched".to_string())
    })
    .await
    .map_err(|e| e.to_string())?
}

#[tauri::command]
async fn proxy_stop() -> Result<String, String> {
    spawn_blocking(|| {
        Command::new("powershell")
            .args([
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                CONTROLLER,
                "stop",
            ])
            .spawn()
            .map_err(|e| format!("Failed to launch controller: {e}"))?;

        Ok("stop command dispatched".to_string())
    })
    .await
    .map_err(|e| e.to_string())?
}

fn run_controller(action: &str) -> Result<String, String> {
    let output = Command::new("powershell")
        .args([
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            CONTROLLER,
            action,
        ])
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

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            proxy_stats,
            proxy_start,
            proxy_stop
        ])
        .run(tauri::generate_context!())
        .expect("error while running application");
}