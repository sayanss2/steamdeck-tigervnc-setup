#!/bin/bash
HOME_DIR="$HOME"
LOG_FILE="$HOME_DIR/vnc-start.log"
DISPLAY_FILE="$HOME_DIR/.vnc/last_display"

mkdir -p "$HOME_DIR/.vnc"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Ожидание запуска графической среды..."
while ! pgrep -f "gamescope" >/dev/null && ! pgrep -f "startplasma-steamos-oneshot" >/dev/null; do
    sleep 2
done
log "Графическая среда обнаружена."

# Чистим старые PID и логи VNC
rm -f "$HOME_DIR/.vnc/"*.pid
rm -f "$HOME_DIR/.vnc/"*.log

# Создаём xstartup для Plasma под X11
cat > "$HOME_DIR/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startplasma-x11
EOF
chmod +x "$HOME_DIR/.vnc/xstartup"

MAX_ATTEMPTS=3
for attempt in $(seq 1 $MAX_ATTEMPTS); do
    log "Попытка запуска VNC (#$attempt)..."
    display_found=0
    for display in {2..5}; do
        pidfile="$HOME_DIR/.vnc/:$display.pid"
        if [ ! -f "$pidfile" ]; then
            display_found=1
            echo "$display" > "$DISPLAY_FILE"
            log "Выбран свободный дисплей :$display"

            # Запуск VNC в фоне
            vncserver ":$display" &
            VNC_PID=$!
            port=$((5900 + display))

            # Проверка открытия порта
            PORT_OK=0
            for i in {1..10}; do
                sleep 1
                if ss -tln | awk '{print $4}' | grep -q ":$port$"; then
                    PORT_OK=1
                    break
                fi
            done

            if [ $PORT_OK -eq 1 ]; then
                IP=$(ip route get 1 | awk '{print $7}')
                log "УСПЕХ: VNC сервер запущен на дисплее :$display ($IP:$port), PID $VNC_PID"
                wait $VNC_PID
                exit 0
            else
                log "ОШИБКА: порт $port не открылся. Завершаем процесс PID $VNC_PID"
                kill $VNC_PID 2>/dev/null
            fi
        fi
    done

    if [ $display_found -eq 0 ]; then
        log "Нет свободных дисплеев для VNC"
        exit 1
    fi
done

log "НЕУСПЕХ: Не удалось запустить VNC после $MAX_ATTEMPTS попыток."
exit 1
