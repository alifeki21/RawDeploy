#!/bin/bash
set -euo pipefail
LOG_FILE="./deploy.log"
RELEASE_DIR="./releases"
REPO_URL="https://github.com/alifeki21/raw-deploy-testapp.git"
RELEASE_NAME="$(date '+%Y%m%d_%H%M%S')"
APP_PORT="5000"
CURRENT_LINK="./current"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
deploy() {
    log "Starting deployment..."
    if [ -L "$CURRENT_LINK" ]; then
    OLD_RELEASE=$(readlink "$CURRENT_LINK")
    OLD_PID_FILE="$RELEASE_DIR/$OLD_RELEASE/app.pid"
    if [ -f "$OLD_PID_FILE" ]; then
        OLD_PID=$(cat "$OLD_PID_FILE")
        log "Stopping previous release ($OLD_RELEASE, PID $OLD_PID)"
        kill "$OLD_PID" 2>/dev/null || true
    fi
    fi
    git clone -q "$REPO_URL" "$RELEASE_DIR"/"$RELEASE_NAME"
    pip install -q -r "$RELEASE_DIR/$RELEASE_NAME/requirements.txt"
    python3 "$RELEASE_DIR/$RELEASE_NAME/run.py" > "$RELEASE_DIR/$RELEASE_NAME/app.log" 2>&1  &
    echo "$!" > "$RELEASE_DIR/$RELEASE_NAME/app.pid"
    log "App started with PID $(cat $RELEASE_DIR/$RELEASE_NAME/app.pid)"
    sleep 2
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:"$APP_PORT"/health)    
    if [ "$HTTP_STATUS" -eq 200 ]; then
    log "Health check passed"
    else
    log "Health check failed — rolling back"
    kill $(cat "$RELEASE_DIR/$RELEASE_NAME/app.pid")
    rm -rf "$RELEASE_DIR/$RELEASE_NAME"
    exit 1
    fi
    ln -sfn "$RELEASE_NAME" "$CURRENT_LINK"
    log "Current release is now $RELEASE_NAME"    
}

rollback() {
    log "Rolling back..."
    RELEASE_COUNT=$(ls "$RELEASE_DIR" 2>/dev/null | wc -l)
    if [ "$RELEASE_COUNT" -lt 2 ]; then
        log "Not enough releases to roll back (need at least 2, found $RELEASE_COUNT)"
        exit 1
    fi

    PREVIOUS_RELEASE=$(ls "$RELEASE_DIR" | sort -r | sed -n '2p')
    CURRENT_RELEASE=$(readlink "$CURRENT_LINK")
    log "Rolling back from $CURRENT_RELEASE to $PREVIOUS_RELEASE"

    if [ -f "$RELEASE_DIR/$CURRENT_RELEASE/app.pid" ]; then
        kill "$(cat $RELEASE_DIR/$CURRENT_RELEASE/app.pid)" 2>/dev/null || true
    fi

    python3 "$RELEASE_DIR/$PREVIOUS_RELEASE/run.py" > "$RELEASE_DIR/$PREVIOUS_RELEASE/app.log" 2>&1 &
    sleep 2
    echo "$!" > "$RELEASE_DIR/$PREVIOUS_RELEASE/app.pid"
    log "Started previous release with PID $(cat $RELEASE_DIR/$PREVIOUS_RELEASE/app.pid)"

    ln -sfn "$PREVIOUS_RELEASE" "$CURRENT_LINK"
    log "Rollback complete — current is now $PREVIOUS_RELEASE"
}

status() {
    echo "Not implemented yet"
}

history() {
    echo "Not implemented yet"
}


case "${1:-}" in
    deploy)   deploy ;;
    rollback) rollback ;;
    status)   status ;;
    history)  history ;;
    *) echo "Usage: ./rawdeploy.sh [deploy|rollback|status|history]" ;;
esac
