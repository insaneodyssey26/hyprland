#!/usr/bin/env bash

STATE_FILE="/tmp/waybar_timer.state"

# State File Format:
# MODE: stopwatch | timer | stopped
# STATUS: running | paused | stopped | finished
# END_TIME: epoch timestamp (for timer)
# ELAPSED: accumulated elapsed seconds (for stopwatch / paused timer)
# DURATION: initial timer duration in seconds
# LAST_UPDATE: epoch timestamp

read_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        MODE="stopped"
        STATUS="stopped"
        END_TIME=0
        ELAPSED=0
        DURATION=0
        LAST_UPDATE=$(date +%s)
    fi
}

save_state() {
    cat <<EOF > "$STATE_FILE"
MODE="$MODE"
STATUS="$STATUS"
END_TIME="$END_TIME"
ELAPSED="$ELAPSED"
DURATION="$DURATION"
LAST_UPDATE="$LAST_UPDATE"
EOF
}

format_time() {
    local t=$1
    if [ $t -lt 0 ]; then t=0; fi
    local h=$((t / 3600))
    local m=$(((t % 3600) / 60))
    local s=$((t % 60))
    if [ $h -gt 0 ]; then
        printf "%02d:%02d:%02d" $h $m $s
    else
        printf "%02d:%02d" $m $s
    fi
}

update_waybar() {
    pkill -RTMIN+8 waybar 2>/dev/null
}

case "$1" in
    print)
        read_state
        NOW=$(date +%s)

        if [ "$STATUS" = "running" ]; then
            if [ "$MODE" = "stopwatch" ]; then
                DIFF=$((NOW - LAST_UPDATE + ELAPSED))
                DISP=$(format_time $DIFF)
                echo "{\"text\": \"󰥔  $DISP\", \"tooltip\": \"Stopwatch: $DISP\nLeft-click: Pause | Right-click: Reset\", \"class\": \"running\"}"
            elif [ "$MODE" = "timer" ]; then
                REMAINING=$((END_TIME - NOW))
                if [ $REMAINING -le 0 ]; then
                    STATUS="finished"
                    save_state
                    notify-send -u critical -t 8000 "Timer Finished" "Your countdown has reached zero."
                    echo "{\"text\": \"󰔛  00:00\", \"tooltip\": \"Timer Finished!\nLeft/Right-click: Reset\", \"class\": \"finished\"}"
                else
                    DISP=$(format_time $REMAINING)
                    echo "{\"text\": \"󱎫  $DISP\", \"tooltip\": \"Timer: $DISP remaining\nLeft-click: Pause | Right-click: Reset | Scroll: +/- 1m\", \"class\": \"running\"}"
                fi
            fi
        elif [ "$STATUS" = "paused" ]; then
            DISP=$(format_time $ELAPSED)
            echo "{\"text\": \"󰏤  $DISP\", \"tooltip\": \"Paused: $DISP\nLeft-click: Resume | Right-click: Reset\", \"class\": \"paused\"}"
        elif [ "$STATUS" = "finished" ]; then
            echo "{\"text\": \"󰔛  00:00\", \"tooltip\": \"Timer Finished!\nLeft/Right-click: Reset\", \"class\": \"finished\"}"
        else
            echo "{\"text\": \"󱎫\", \"tooltip\": \"Timer / Stopwatch\nLeft-click: Menu | Right-click: Stopwatch\", \"class\": \"stopped\"}"
        fi
        ;;

    toggle)
        read_state
        NOW=$(date +%s)
        if [ "$STATUS" = "running" ]; then
            # Pause
            if [ "$MODE" = "stopwatch" ]; then
                ELAPSED=$((NOW - LAST_UPDATE + ELAPSED))
            elif [ "$MODE" = "timer" ]; then
                ELAPSED=$((END_TIME - NOW))
            fi
            STATUS="paused"
            LAST_UPDATE=$NOW
            save_state
        elif [ "$STATUS" = "paused" ]; then
            # Resume
            if [ "$MODE" = "stopwatch" ]; then
                LAST_UPDATE=$NOW
            elif [ "$MODE" = "timer" ]; then
                END_TIME=$((NOW + ELAPSED))
            fi
            STATUS="running"
            save_state
        elif [ "$STATUS" = "finished" ]; then
            MODE="stopped"
            STATUS="stopped"
            ELAPSED=0
            save_state
        else
            # Open menu if stopped
            exec "$0" menu
        fi
        update_waybar
        ;;

    reset)
        MODE="stopped"
        STATUS="stopped"
        END_TIME=0
        ELAPSED=0
        DURATION=0
        LAST_UPDATE=$(date +%s)
        save_state
        update_waybar
        ;;

    adjust)
        read_state
        DELTA=${2:-60}
        NOW=$(date +%s)
        if [ "$STATUS" = "running" ] && [ "$MODE" = "timer" ]; then
            END_TIME=$((END_TIME + DELTA))
            if [ $END_TIME -lt $NOW ]; then END_TIME=$NOW; fi
            save_state
            update_waybar
        elif [ "$STATUS" = "paused" ] && [ "$MODE" = "timer" ]; then
            ELAPSED=$((ELAPSED + DELTA))
            if [ $ELAPSED -lt 0 ]; then ELAPSED=0; fi
            save_state
            update_waybar
        fi
        ;;

    start_timer)
        SECS=$2
        NOW=$(date +%s)
        MODE="timer"
        STATUS="running"
        DURATION=$SECS
        END_TIME=$((NOW + SECS))
        ELAPSED=0
        LAST_UPDATE=$NOW
        save_state
        update_waybar
        ;;

    start_stopwatch)
        NOW=$(date +%s)
        MODE="stopwatch"
        STATUS="running"
        DURATION=0
        END_TIME=0
        ELAPSED=0
        LAST_UPDATE=$NOW
        save_state
        update_waybar
        ;;

    menu)
        OPTS="25m   │  Pomodoro Focus\n15m   │  Short Break\n 5m   │  Quick Break\n45m   │  Deep Work\n60m   │  1 Hour\n 0m   │  Start Stopwatch (Count Up)\nstop  │  Reset / Clear Timer"

        CHOICE=$(echo -e "$OPTS" | fuzzel --config "$HOME/.config/fuzzel/fuzzel.ini" --dmenu -p "Timer  " --lines=7 --width=32)

        if [ -n "$CHOICE" ]; then
            case "$CHOICE" in
                *"25m"*)
                    "$0" start_timer 1500
                    ;;
                *"15m"*)
                    "$0" start_timer 900
                    ;;
                *"5m"*)
                    "$0" start_timer 300
                    ;;
                *"45m"*)
                    "$0" start_timer 2700
                    ;;
                *"60m"*)
                    "$0" start_timer 3600
                    ;;
                *"Stopwatch"*)
                    "$0" start_stopwatch
                    ;;
                *"stop"*|*"Reset"*)
                    "$0" reset
                    ;;
                *)
                    # Custom input parsing (e.g., "12m", "45s", "1h 30m", "10")
                    RAW=$(echo "$CHOICE" | tr -d ' ')
                    TOTAL_SECS=0
                    if [[ "$RAW" =~ ([0-9]+)h ]]; then
                        TOTAL_SECS=$((TOTAL_SECS + ${BASH_REMATCH[1]} * 3600))
                    fi
                    if [[ "$RAW" =~ ([0-9]+)m ]]; then
                        TOTAL_SECS=$((TOTAL_SECS + ${BASH_REMATCH[1]} * 60))
                    fi
                    if [[ "$RAW" =~ ([0-9]+)s ]]; then
                        TOTAL_SECS=$((TOTAL_SECS + ${BASH_REMATCH[1]}))
                    fi
                    # If just a plain number was typed (e.g. "12"), treat as minutes
                    if [[ "$RAW" =~ ^[0-9]+$ ]]; then
                        TOTAL_SECS=$((RAW * 60))
                    fi

                    if [ $TOTAL_SECS -gt 0 ]; then
                        "$0" start_timer $TOTAL_SECS
                    fi
                    ;;
            esac
        fi
        ;;
esac
