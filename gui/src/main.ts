import { invoke } from "@tauri-apps/api/core";

const app = `
  <div class="app-shell">

    <header class="topbar">
      <div class="brand">
        <div class="brand-mark">❄</div>
        <div>
          <div class="brand-title">SNOWFLAKE</div>
          <div class="brand-subtitle">STANDALONE PROXY</div>
        </div>
      </div>

      <div class="connection-state">
        <span class="status-dot"></span>
        <span id="header-status">OFFLINE</span>
      </div>
    </header>

    <main class="dashboard">

      <section class="hero-card">
        <div class="hero-content">
          <div class="eyebrow">TOR PLIABLE TRANSPORT</div>

          <h1>Snowflake Proxy</h1>

          <p>
            A lightweight control center for your standalone
            Snowflake proxy.
          </p>

          <div class="hero-actions">

            <button id="start-btn" class="primary-btn">
              START PROXY
            </button>

            <button id="stop-btn" class="secondary-btn">
              STOP
            </button>

          </div>
        </div>

        <div class="hero-status">

          <div class="status-ring">
            <span class="status-dot large"></span>
          </div>

          <div class="status-label">
            PROXY STATUS
          </div>

          <div id="main-status" class="status-value">
            STOPPED
          </div>

        </div>
      </section>

      <section class="stats-grid">

        <div class="stat-card">
          <div class="stat-label">PROCESS ID</div>
          <div id="pid" class="stat-value">—</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">UPTIME</div>
          <div id="uptime" class="stat-value">—</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">MEMORY</div>
          <div id="memory" class="stat-value">—</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">NAT TYPE</div>
          <div id="nat" class="stat-value">—</div>
        </div>

      </section>

      <section class="activity-grid">

        <div class="panel">

          <div class="panel-header">
            <div>
              <div class="panel-title">
                Proxy Activity
              </div>

              <div class="panel-subtitle">
                Current session statistics
              </div>
            </div>
          </div>

          <div class="metrics">

            <div class="metric">
              <span>Client Offers</span>
              <strong id="offers">0</strong>
            </div>

            <div class="metric">
              <span>Answers Generated</span>
              <strong id="answers">0</strong>
            </div>

            <div class="metric">
              <span>Relay Connections</span>
              <strong id="relays">0</strong>
            </div>

          </div>
        </div>

        <div class="panel">

          <div class="panel-header">

            <div>
              <div class="panel-title">
                Recent Activity
              </div>

              <div class="panel-subtitle">
                Latest proxy events
              </div>
            </div>

            <button id="refresh-btn" class="small-btn">
              REFRESH
            </button>

          </div>

          <div id="activity" class="activity-log">
            Waiting for proxy activity...
          </div>

        </div>

      </section>

      <section class="bottom-actions">

        <button id="logs-btn" class="outline-btn">
          VIEW LOGS
        </button>

        <button id="export-btn" class="outline-btn">
          EXPORT LOGS
        </button>

      </section>

    </main>

    <footer>

      <span>
        tor-snowflake-standalone-proxy
        <span class="footer-separator">·</span>
        Created by david-marin-0xff
      </span>

      <a
        class="github-link"
        href="https://github.com/david-marin-0xff/tor-snowflake-standalone-proxy"
        target="_blank"
        rel="noopener noreferrer"
        title="View project on GitHub"
      >

        <svg
          class="github-icon"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path
            fill="currentColor"
            d="M12 .5C5.65.5.5 5.65.5 12c0 5.08 3.29 9.39 7.86 10.91.58.11.79-.25.79-.56
            0-.28-.01-1.02-.02-2-3.2.7-3.88-1.54-3.88-1.54-.53-1.33-1.28-1.68-1.28-1.68
            -1.05-.72.08-.71.08-.71 1.16.08 1.77 1.19 1.77 1.19 1.03 1.76 2.7 1.25
            3.36.95.1-.74.4-1.25.73-1.54-2.56-.29-5.25-1.28-5.25-5.69 0-1.26.45-2.29
            1.19-3.1 0 0-.52-1.47.11-3.06 0 0 .97-.31 3.18 1.18a11.06 11.06 0 0 1
            5.79 0c2.21-1.49 3.18-1.18 3.18-1.18.63 1.59.23 2.77.11 3.06.74.81 1.19
            1.84 1.19 3.1 0 4.42-2.7 5.4-5.27 5.69.41.35.78 1.04.78 2.1 0 1.52-.01
            2.74-.01 3.11 0 .31.21.67.8.56C20.21 21.39 23.5 17.08 23.5 12
            23.5 5.65 18.35.5 12 .5Z"
          />
        </svg>

        <span>GitHub</span>

      </a>

    </footer>

  </div>
`;

document.querySelector<HTMLDivElement>("#app")!.innerHTML = app;


/* ---------------------------------------------------------
   DOM REFERENCES
--------------------------------------------------------- */

const startButton =
  document.querySelector<HTMLButtonElement>("#start-btn");

const stopButton =
  document.querySelector<HTMLButtonElement>("#stop-btn");

const refreshButton =
  document.querySelector<HTMLButtonElement>("#refresh-btn");

const pidElement =
  document.querySelector("#pid");

const uptimeElement =
  document.querySelector("#uptime");

const memoryElement =
  document.querySelector("#memory");

const natElement =
  document.querySelector("#nat");

const offersElement =
  document.querySelector("#offers");

const answersElement =
  document.querySelector("#answers");

const relaysElement =
  document.querySelector("#relays");

const activityElement =
  document.querySelector("#activity");


/* ---------------------------------------------------------
   STATUS
--------------------------------------------------------- */

function setStatus(
  running: boolean,
  pid?: number
) {

  const mainStatus =
    document.querySelector("#main-status");

  const headerStatus =
    document.querySelector("#header-status");

  if (!mainStatus || !headerStatus) {
    return;
  }

  if (running) {

    mainStatus.textContent = "RUNNING";
    headerStatus.textContent = "ONLINE";

    document.body.classList.add("running");

    if (
      pidElement &&
      pid !== undefined
    ) {
      pidElement.textContent =
        String(pid);
    }

  } else {

    mainStatus.textContent = "STOPPED";
    headerStatus.textContent = "OFFLINE";

    document.body.classList.remove("running");

    if (pidElement) {
      pidElement.textContent = "—";
    }

  }
}


/* ---------------------------------------------------------
   REFRESH STATUS
--------------------------------------------------------- */

let refreshInProgress = false;

async function refreshStatus() {

  /*
   * Prevent overlapping refresh requests.
   * This is important because refreshStatus() is
   * called automatically every second.
   */

  if (refreshInProgress) {
    return;
  }

  refreshInProgress = true;

  try {

    const rawStats =
      await invoke<string>("proxy_stats");

    const stats =
      JSON.parse(rawStats);

    const running =
      stats.status === "RUNNING";


    /* Status */

    setStatus(
      running,
      stats.pid ?? undefined
    );


    /* Uptime */

    if (uptimeElement) {

      uptimeElement.textContent =
        stats.uptime ?? "—";

    }


    /* Memory */

    if (memoryElement) {

      memoryElement.textContent =
        stats.memory !== null &&
        stats.memory !== undefined
          ? `${stats.memory} MB`
          : "—";

    }


    /* NAT */

    if (natElement) {

      natElement.textContent =
        stats.nat ?? "—";

    }


    /* Client offers */

    if (offersElement) {

      offersElement.textContent =
        String(stats.offers ?? 0);

    }


    /* Answers */

    if (answersElement) {

      answersElement.textContent =
        String(stats.answers ?? 0);

    }


    /* Relays */

    if (relaysElement) {

      relaysElement.textContent =
        String(stats.relays ?? 0);

    }


    /* Recent activity */

    if (activityElement) {

      if (
        Array.isArray(stats.recentActivity) &&
        stats.recentActivity.length > 0
      ) {

        activityElement.textContent =
          stats.recentActivity
            .map((entry: unknown) => {

              /*
               * snowctl currently returns
               * PowerShell objects for recentActivity.
               *
               * Extract "value" when available.
               */

              if (
                typeof entry === "object" &&
                entry !== null &&
                "value" in entry
              ) {

                return String(
                  (entry as { value: unknown }).value
                );

              }

              return String(entry);

            })
            .join("\n");

      } else {

        activityElement.textContent =
          "Waiting for proxy activity...";

      }

    }

  } catch (error) {

    console.error(
      "Failed to get proxy statistics:",
      error
    );

    setStatus(false);

  } finally {

    refreshInProgress = false;

  }
}


/* ---------------------------------------------------------
   START PROXY
--------------------------------------------------------- */

startButton?.addEventListener(
  "click",
  async () => {

    try {

      startButton.disabled = true;
      startButton.textContent =
        "STARTING...";

      await invoke("proxy_start");

      /*
       * Give the proxy a moment to initialize
       * before requesting the first statistics.
       */

      await new Promise(
        resolve => setTimeout(resolve, 500)
      );

      await refreshStatus();

    } catch (error) {

      console.error(
        "Failed to start proxy:",
        error
      );

      alert(
        `Failed to start Snowflake proxy:\n${error}`
      );

      await refreshStatus();

    } finally {

      startButton.disabled = false;
      startButton.textContent =
        "START PROXY";

    }

  }
);


/* ---------------------------------------------------------
   STOP PROXY
--------------------------------------------------------- */

stopButton?.addEventListener(
  "click",
  async () => {

    try {

      stopButton.disabled = true;
      stopButton.textContent =
        "STOPPING...";

      await invoke("proxy_stop");

      await refreshStatus();

    } catch (error) {

      console.error(
        "Failed to stop proxy:",
        error
      );

      alert(
        `Failed to stop Snowflake proxy:\n${error}`
      );

      await refreshStatus();

    } finally {

      stopButton.disabled = false;
      stopButton.textContent =
        "STOP";

    }

  }
);


/* ---------------------------------------------------------
   MANUAL REFRESH
--------------------------------------------------------- */

refreshButton?.addEventListener(
  "click",
  async () => {

    await refreshStatus();

  }
);


/* ---------------------------------------------------------
   AUTOMATIC REFRESH
--------------------------------------------------------- */

/*
 * Update the dashboard every second.
 *
 * snowctl calculates uptime when "json" is executed,
 * so polling it gives us a live uptime display.
 */

setInterval(
  refreshStatus,
  1000
);


/* ---------------------------------------------------------
   INITIAL STATUS
--------------------------------------------------------- */

refreshStatus();