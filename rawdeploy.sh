#!/bin/bash
set -euo pipefail
LOG_FILE="./deploy.log"
RELEASE_DIR="./releases"
REPO_URL="https://github.com/alifeki21/RawDeploy.git"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
deploy() {
    log "Starting deployment..."
    mkdir "$RELEASE_DIR"/"$(date '%Y%m%d_%H%M%S')"
    git clone "$REPO_URL"
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
