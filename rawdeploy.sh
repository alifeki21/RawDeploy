#!/bin/bash
set -euo pipefail
LOG_FILE="./deploy.log"
RELEASE_DIR="./releases"
REPO_URL="https://github.com/alifeki21/rawdeploy-target-app.git"
RELEASE_NAME="$(date '+%Y%m%d_%H%M%S')"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
deploy() {
    log "Starting deployment..."
    git clone -q "$REPO_URL" "$RELEASE_DIR"/"$RELEASE_NAME"
    pip install -q -r "$RELEASE_DIR/$RELEASE_NAME/requirements.txt"
    python3 "$RELEASE_DIR/$RELEASE_NAME/app.py" > "$RELEASE_DIR/$RELEASE_NAME/app.log" 2>&1  &
    echo "$!" > "$RELEASE_DIR/$RELEASE_NAME/app.pid"
    log "App started with PID $(cat $RELEASE_DIR/$RELEASE_NAME/app.pid)"
    
}

rollback() {
    log "Rolling back..."
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
