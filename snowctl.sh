#!/bin/bash

CONFIG_FILE="config.macos.json"

PROXY_PATH=$(grep 'proxyPath' $CONFIG_FILE | cut -d '"' -f4)
LOG_PATH=$(grep 'logPath' $CONFIG_FILE | cut -d '"' -f4)

PID_FILE=".snowflake.pid"

case "$1" in

    start)

        if pgrep -f "$PROXY_PATH" > /dev/null; then
            echo "Snowflake proxy is already running."
            exit 0
        fi

        echo "Starting Snowflake proxy..."

        nohup "$PROXY_PATH" \
            -verbose \
            -metrics \
            -metrics-address 127.0.0.1 \
            -metrics-port 9999 \
            > "$LOG_PATH" 2>&1 &

        echo $! > "$PID_FILE"

        sleep 2

        echo "Snowflake proxy started."
        ;;

    stop)

        if [ ! -f "$PID_FILE" ]; then
            echo "Snowflake proxy is not running."
            exit 0
        fi

        PID=$(cat "$PID_FILE")

        kill "$PID" 2>/dev/null

        rm -f "$PID_FILE"

        echo "Snowflake proxy stopped."
        ;;

    status)

        if pgrep -f "$PROXY_PATH" > /dev/null; then
            echo "Snowflake proxy is RUNNING."
        else
            echo "Snowflake proxy is NOT running."
        fi
        ;;

    logs)

        tail -f "$LOG_PATH"
        ;;

    stats)

        if ! pgrep -f "$PROXY_PATH" > /dev/null; then
            echo "Snowflake proxy is NOT running."
            exit 0
        fi

        PID=$(pgrep -f "$PROXY_PATH" | head -n 1)

        echo ""
        echo "========== snowctl stats =========="
        echo ""

        echo "Status: RUNNING"
        echo "PID: $PID"

        MEMORY=$(ps -o rss= -p "$PID" | awk '{print $1/1024 " MB"}')

        echo "Memory Usage: $MEMORY"

        START_TIME=$(ps -o lstart= -p "$PID")

        echo "Started: $START_TIME"

        echo ""

        NAT=$(grep "NAT type:" "$LOG_PATH" | tail -n 1 | sed 's/.*NAT type: //')

        if [ ! -z "$NAT" ]; then
            echo "NAT Type: $NAT"
        fi

        echo ""

        OFFERS=$(grep -c "Received Offer From Broker" "$LOG_PATH")
        ANSWERS=$(grep -c "Generating answer" "$LOG_PATH")
        RELAYS=$(grep -c "Connected to relay" "$LOG_PATH")

        echo "Client Offers: $OFFERS"
        echo "Answers Generated: $ANSWERS"
        echo "Relay Connections: $RELAYS"

        echo ""

        LAST_RELAY=$(grep "Connected to relay" "$LOG_PATH" | tail -n 1 | sed 's/.*Connected to relay: //')

        if [ ! -z "$LAST_RELAY" ]; then
            echo "Last Relay:"
            echo "$LAST_RELAY"
        fi

        echo ""

        echo "Recent Activity:"
        echo ""

        tail -n 5 "$LOG_PATH"

        echo ""
        ;;

    export)

        mkdir -p exports

        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

        EXPORT_FILE="exports/snowflake-log-$TIMESTAMP.txt"

        cp "$LOG_PATH" "$EXPORT_FILE"

        echo ""
        echo "Logs exported successfully:"
        echo "$EXPORT_FILE"
        echo ""
        ;;

    *)

        echo ""
        echo "snowctl commands:"
        echo ""

        echo "./snowctl.sh start"
        echo "./snowctl.sh stop"
        echo "./snowctl.sh status"
        echo "./snowctl.sh logs"
        echo "./snowctl.sh stats"
        echo "./snowctl.sh export"

        echo ""
        ;;
esac