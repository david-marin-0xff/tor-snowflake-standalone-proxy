param(
    [string]$Action
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Resolve paths relative to this script.
# ------------------------------------------------------------

$ScriptPath = $MyInvocation.MyCommand.Definition
$ScriptDir = [System.IO.Path]::GetDirectoryName($ScriptPath)

if ([string]::IsNullOrWhiteSpace($ScriptDir)) {
    Write-Error "Unable to determine the controller directory."
    exit 1
}

# Configuration file.
$configPath = [System.IO.Path]::Combine(
    $ScriptDir,
    "config.json"
)

# ------------------------------------------------------------
# Load configuration.
# ------------------------------------------------------------

if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file not found: $configPath"
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json

# ------------------------------------------------------------
# Resolve configured paths.
# ------------------------------------------------------------

$proxyPath = [System.IO.Path]::Combine(
    $ScriptDir,
    $config.proxyPath
)

$logPath = [System.IO.Path]::Combine(
    $ScriptDir,
    $config.logPath
)

$errorPath = [System.IO.Path]::Combine(
    $ScriptDir,
    $config.errorPath
)

$logDirectory = [System.IO.Path]::GetDirectoryName($logPath)

$exportsDirectory = [System.IO.Path]::Combine(
    $ScriptDir,
    "exports"
)

# ------------------------------------------------------------
# Validate proxy.
# ------------------------------------------------------------

if (-not (Test-Path $proxyPath)) {
    Write-Error "Snowflake proxy not found: $proxyPath"
    exit 1
}

# ------------------------------------------------------------
# Ensure required directories exist.
# ------------------------------------------------------------

if (-not [string]::IsNullOrWhiteSpace($logDirectory)) {
    if (-not (Test-Path $logDirectory)) {
        New-Item `
            -ItemType Directory `
            -Path $logDirectory `
            -Force |
            Out-Null
    }
}

# ------------------------------------------------------------
# Controller commands.
# ------------------------------------------------------------

switch ($Action.ToLower()) {

    # --------------------------------------------------------
    # START
    # --------------------------------------------------------

    "start" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if ($running) {
            Write-Host "Snowflake proxy is already running."
            exit 0
        }

        Write-Host "Starting Snowflake proxy..."

        try {

            Start-Process `
                -FilePath $proxyPath `
                -ArgumentList `
                    "-verbose",
                    "-metrics",
                    "-metrics-address", "127.0.0.1",
                    "-metrics-port", "9999" `
                -NoNewWindow `
                -RedirectStandardError $logPath `
                -ErrorAction Stop

            Start-Sleep -Milliseconds 500

            $running = Get-Process proxy -ErrorAction SilentlyContinue

            if (-not $running) {
                Write-Error "Snowflake proxy failed to start. Check: $logPath"
                exit 1
            }

            Write-Host "Snowflake proxy started."
        }
        catch {
            Write-Error "Failed to start Snowflake proxy: $($_.Exception.Message)"
            exit 1
        }
    }

    # --------------------------------------------------------
    # STOP
    # --------------------------------------------------------

    "stop" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if (-not $running) {
            Write-Host "Snowflake proxy is not running."
            exit 0
        }

        foreach ($process in $running) {

            try {

                Stop-Process `
                    -Id $process.Id `
                    -Force `
                    -ErrorAction Stop

                Write-Host "Snowflake proxy stopped. PID: $($process.Id)"
            }
            catch {

                Write-Error `
                    "Failed to stop proxy PID $($process.Id): $($_.Exception.Message)"

                exit 1
            }
        }
    }

    # --------------------------------------------------------
    # STATUS
    # --------------------------------------------------------

    "status" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if ($running) {

            Write-Host "Snowflake proxy is RUNNING."
            Write-Host "PID: $($running.Id -join ', ')"
        }
        else {

            Write-Host "Snowflake proxy is NOT running."
        }
    }

    # --------------------------------------------------------
    # LOGS
    # --------------------------------------------------------

    "logs" {

        if (-not (Test-Path $logPath)) {

            Write-Host "Log file does not exist yet: $logPath"
            exit 0
        }

        Get-Content $logPath -Wait
    }

    # --------------------------------------------------------
    # STATS
    # --------------------------------------------------------

    "stats" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue

        if (-not $running) {

            Write-Host "Snowflake proxy is NOT running."
            exit 0
        }

        Write-Host ""
        Write-Host "========== snowctl stats =========="
        Write-Host ""

        Write-Host "Status: RUNNING"
        Write-Host "PID:" ($running.Id -join ', ')

        $memory = [math]::Round(
            (($running | Measure-Object WorkingSet64 -Sum).Sum) / 1MB,
            2
        )

        Write-Host "Memory Usage:" $memory "MB"

        try {

            $startTime = ($running | Select-Object -First 1).StartTime
            $uptime = (Get-Date) - $startTime

            Write-Host `
                "Uptime:" `
                $uptime.ToString().Split('.')[0]
        }
        catch {

            Write-Host "Uptime: unavailable"
        }

        if (Test-Path $logPath) {

            # NAT type.
            $nat = Select-String `
                "NAT type:" `
                $logPath |
                Select-Object -Last 1

            if ($nat) {

                $natLine = $nat.Line.Split("NAT type:")[1].Trim()

                Write-Host "NAT Type:" $natLine
            }

            # Snowflake activity counters.
            $offers = @(
                Select-String `
                    "Received Offer From Broker" `
                    $logPath
            ).Count

            $answers = @(
                Select-String `
                    "Generating answer" `
                    $logPath
            ).Count

            $relays = @(
                Select-String `
                    "Connected to relay" `
                    $logPath
            ).Count

            Write-Host "Client Offers:" $offers
            Write-Host "Answers Generated:" $answers
            Write-Host "Relay Connections:" $relays

            # Last relay.
            $lastRelay = Select-String `
                "Connected to relay" `
                $logPath |
                Select-Object -Last 1

            if ($lastRelay) {

                $relayLine = `
                    $lastRelay.Line.Split("Connected to relay:")[1].Trim()

                Write-Host ""
                Write-Host "Last Relay:"
                Write-Host $relayLine
            }

            Write-Host ""
            Write-Host "Recent Activity:"
            Write-Host ""

            Get-Content $logPath |
                Select-Object -Last 5
        }

        Write-Host ""
    }

    # --------------------------------------------------------
    # JSON
    # --------------------------------------------------------

    "json" {

        $running = Get-Process proxy -ErrorAction SilentlyContinue |
            Select-Object -First 1

        # ----------------------------------------------------
        # STOPPED
        # ----------------------------------------------------

        if (-not $running) {

            @{
                status = "STOPPED"
                pid = $null
                memory = $null
                uptime = $null
                nat = $null
                offers = 0
                answers = 0
                relays = 0
                lastRelay = $null
                recentActivity = @()
            } |
            ConvertTo-Json -Compress

            exit 0
        }

        # ----------------------------------------------------
        # RUNNING
        # ----------------------------------------------------

        $memory = [math]::Round(
            $running.WorkingSet64 / 1MB,
            2
        )

        try {

            $startTime = $running.StartTime

            $uptime = `
                ((Get-Date) - $startTime).ToString().Split('.')[0]
        }
        catch {

            $uptime = $null
        }

        $nat = $null
        $offers = 0
        $answers = 0
        $relays = 0
        $lastRelay = $null
        $recentActivity = @()

        if (Test-Path $logPath) {

            # NAT type.
            $natMatch = Select-String `
                "NAT type:" `
                $logPath |
                Select-Object -Last 1

            if ($natMatch) {

                $nat = `
                    $natMatch.Line.Split("NAT type:")[1].Trim()
            }

            # Activity counters.
            $offers = @(
                Select-String `
                    "Received Offer From Broker" `
                    $logPath
            ).Count

            $answers = @(
                Select-String `
                    "Generating answer" `
                    $logPath
            ).Count

            $relays = @(
                Select-String `
                    "Connected to relay" `
                    $logPath
            ).Count

            # Last relay.
            $lastRelayMatch = Select-String `
                "Connected to relay" `
                $logPath |
                Select-Object -Last 1

            if ($lastRelayMatch) {

                $lastRelay = `
                    $lastRelayMatch.Line.Split(
                        "Connected to relay:"
                    )[1].Trim()
            }

            # Always return an array of strings.
            $recentActivity = @(
                Get-Content $logPath |
                    Select-Object -Last 5 |
                    ForEach-Object {
                        [string]$_
                    }
            )
        }

        @{
            status = "RUNNING"
            pid = $running.Id
            memory = $memory
            uptime = $uptime
            nat = $nat
            offers = $offers
            answers = $answers
            relays = $relays
            lastRelay = $lastRelay
            recentActivity = $recentActivity
        } |
        ConvertTo-Json -Compress
    }

    # --------------------------------------------------------
    # EXPORT
    # --------------------------------------------------------

    "export" {

        if (-not (Test-Path $logPath)) {

            Write-Error "Log file does not exist: $logPath"
            exit 1
        }

        if (-not (Test-Path $exportsDirectory)) {

            New-Item `
                -ItemType Directory `
                -Path $exportsDirectory `
                -Force |
                Out-Null
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

        $exportFile = [System.IO.Path]::Combine(
            $exportsDirectory,
            "snowflake-log-$timestamp.txt"
        )

        Copy-Item `
            $logPath `
            $exportFile

        Write-Host ""
        Write-Host "Logs exported successfully:"
        Write-Host $exportFile
        Write-Host ""
    }

    # --------------------------------------------------------
    # UNKNOWN / NO COMMAND
    # --------------------------------------------------------

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
        Write-Host "  .\snowctl.ps1 json"

        Write-Host ""
    }
}