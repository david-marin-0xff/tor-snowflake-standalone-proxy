param(
    [string]$Action
)

$config = Get-Content "config.json" | ConvertFrom-Json

switch ($Action) {

    "start" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if ($running) {
            Write-Host "Snowflake proxy is already running."
            break
        }

        Write-Host "Starting Snowflake proxy..."

        Start-Process `
            -FilePath $config.proxyPath `
            -ArgumentList `
            "-verbose",
            "-metrics",
            "-metrics-address", "127.0.0.1",
            "-metrics-port", "9999" `
            -NoNewWindow `
            -RedirectStandardError $config.logPath

        Write-Host "Snowflake proxy started."
    }

    "stop" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if (-not $running) {

            Write-Host "Snowflake proxy is not running."
            break
        }

        Stop-Process -Name proxy

        Write-Host "Snowflake proxy stopped."
    }

    "status" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if ($running) {

            Write-Host "Snowflake proxy is RUNNING."
        }
        else {

            Write-Host "Snowflake proxy is NOT running."
        }
    }

    "logs" {

        Get-Content $config.logPath -Wait
    }

    "stats" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if (-not $running) {

            Write-Host "Snowflake proxy is NOT running."
            break
        }

        Write-Host ""
        Write-Host "========== snowctl stats =========="
        Write-Host ""

        Write-Host "Status: RUNNING"

        Write-Host "PID:" $running.Id

        $memory = [math]::Round($running.WorkingSet64 / 1MB, 2)

        Write-Host "Memory Usage:" $memory "MB"

        try {

            $startTime = $running.StartTime

            $uptime = (Get-Date) - $startTime

            Write-Host "Uptime:" $uptime.ToString().Split('.')[0]

        } catch {

            Write-Host "Uptime: unavailable"
        }

        Write-Host ""

        $nat = Select-String "NAT type:" $config.logPath | Select-Object -Last 1

        if ($nat) {

            $natLine = $nat.Line.Split("NAT type:")[1].Trim()

            Write-Host "NAT Type:" $natLine
        }

        Write-Host ""

        $offers = (Select-String "Received Offer From Broker" $config.logPath).Count

        $answers = (Select-String "Generating answer" $config.logPath).Count

        $relays = (Select-String "Connected to relay" $config.logPath).Count

        Write-Host "Client Offers:" $offers

        Write-Host "Answers Generated:" $answers

        Write-Host "Relay Connections:" $relays

        Write-Host ""

        $lastRelay = Select-String "Connected to relay" $config.logPath | Select-Object -Last 1

        if ($lastRelay) {

            $relayLine = $lastRelay.Line.Split("Connected to relay:")[1].Trim()

            Write-Host "Last Relay:"
            Write-Host $relayLine
        }

        Write-Host ""

        $recentActivity = Get-Content $config.logPath | Select-Object -Last 5

        Write-Host "Recent Activity:"
        Write-Host ""

        $recentActivity

        Write-Host ""
    }

    "export" {

        if (-not (Test-Path "exports")) {

            New-Item -ItemType Directory -Path "exports" | Out-Null
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

        $exportFile = "exports\snowflake-log-$timestamp.txt"

        Copy-Item $config.logPath $exportFile

        Write-Host ""
        Write-Host "Logs exported successfully:"
        Write-Host $exportFile
        Write-Host ""
    }

    default {

        Write-Host ""
        Write-Host "snowctl commands:"
        Write-Host ""

        Write-Host "  .\snowctl.ps1 start"
        Write-Host "  .\snowctl.ps1 stop"
        Write-Host "  .\snowctl.ps1 status"
        Write-Host "  .\snowctl.ps1 logs"
        Write-Host "  .\snowctl.ps1 stats"
        Write-Host "  .\snowctl.ps1 export"

        Write-Host ""
    }
}