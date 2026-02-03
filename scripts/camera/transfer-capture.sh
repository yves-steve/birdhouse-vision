#!/bin/bash
#
# Birdhouse Vision - Capture Transfer Script
#
# This script runs on the CAMERA PI after each capture to:
# 1. Transfer the captured image to the NAS Pi via rsync/SSH
# 2. Delete the local copy after successful transfer
#
# Usage:
#   ./transfer-capture.sh /path/to/capture.jpg
#   ./transfer-capture.sh /path/to/capture.jpg --keep-local
#
# Called automatically by the capture service after each motion detection.
# Requires SSH key-based authentication to NAS Pi (no password prompts).

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# NAS Pi connection details
NAS_HOST="birdhouse-nas.local"
NAS_USER="birdhouse"
NAS_BASE_PATH="/mnt/birdhouse/captures"

# Local paths
LOG_FILE="/home/birdhouse/logs/transfer.log"

# Transfer settings
SSH_OPTIONS="-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o BatchMode=yes"
RSYNC_OPTIONS="-avz --timeout=30"

# Retry settings
MAX_RETRIES=3
RETRY_DELAY=5

# Keep local copy flag
KEEP_LOCAL=false

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <capture_file> [--keep-local]"
    echo "  <capture_file>  Path to the captured image file"
    echo "  --keep-local    Don't delete local file after transfer"
    exit 1
fi

CAPTURE_FILE="$1"

if [[ "${2:-}" == "--keep-local" ]]; then
    KEEP_LOCAL=true
fi

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[${timestamp}] [${level}] ${message}"
    
    # Append to log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
}

get_remote_path() {
    # Generate remote path based on current date: YYYY/MM/DD/
    local year month day
    year=$(date '+%Y')
    month=$(date '+%m')
    day=$(date '+%d')
    
    echo "${NAS_BASE_PATH}/${year}/${month}/${day}"
}

check_nas_reachable() {
    # Check if NAS Pi is reachable via SSH
    if ssh $SSH_OPTIONS "${NAS_USER}@${NAS_HOST}" "echo ok" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

create_remote_directory() {
    local remote_path="$1"
    ssh $SSH_OPTIONS "${NAS_USER}@${NAS_HOST}" "mkdir -p '${remote_path}'"
}

transfer_file() {
    local local_file="$1"
    local remote_path="$2"
    local filename
    filename=$(basename "$local_file")
    
    rsync $RSYNC_OPTIONS -e "ssh $SSH_OPTIONS" \
        "$local_file" \
        "${NAS_USER}@${NAS_HOST}:${remote_path}/${filename}"
}

verify_transfer() {
    local local_file="$1"
    local remote_path="$2"
    local filename
    filename=$(basename "$local_file")

    # Get local file size
    local local_size
    local_size=$(stat -f%z "$local_file" 2>/dev/null || stat -c%s "$local_file" 2>/dev/null)

    # Get remote file size
    local remote_size
    local remote_file="${remote_path}/${filename}"
    local remote_file_escaped
    remote_file_escaped=$(printf '%q' "$remote_file")
    remote_size=$(ssh $SSH_OPTIONS "${NAS_USER}@${NAS_HOST}" \
        "stat -f%z $remote_file_escaped 2>/dev/null || stat -c%s $remote_file_escaped 2>/dev/null")
    if [[ "$local_size" == "$remote_size" ]]; then
        return 0
    else
        return 1
    fi
}

transfer_with_metadata() {
    local capture_file="$1"
    local remote_path="$2"
    
    # Transfer the main capture file
    transfer_file "$capture_file" "$remote_path"
    
    # Check for associated metadata file (.json)
    local base_name="${capture_file%.*}"
    local metadata_file="${base_name}.json"
    
    if [[ -f "$metadata_file" ]]; then
        log "INFO" "Transferring metadata: $(basename "$metadata_file")"
        transfer_file "$metadata_file" "$remote_path"
    fi
}

cleanup_local() {
    local capture_file="$1"
    
    if [[ "$KEEP_LOCAL" == true ]]; then
        log "INFO" "Keeping local copy (--keep-local flag set)"
        return 0
    fi
    
    # Delete the capture file
    rm -f "$capture_file"
    log "INFO" "Deleted local: $(basename "$capture_file")"
    
    # Delete associated metadata file if exists
    local base_name="${capture_file%.*}"
    local metadata_file="${base_name}.json"
    
    if [[ -f "$metadata_file" ]]; then
        rm -f "$metadata_file"
        log "INFO" "Deleted local metadata: $(basename "$metadata_file")"
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local capture_file="$CAPTURE_FILE"
    
    # Validate input file
    if [[ ! -f "$capture_file" ]]; then
        log "ERROR" "Capture file not found: ${capture_file}"
        exit 1
    fi
    
    local filename
    filename=$(basename "$capture_file")
    local filesize
    filesize=$(stat -f%z "$capture_file" 2>/dev/null || stat -c%s "$capture_file" 2>/dev/null)
    local filesize_human
    filesize_human=$(numfmt --to=iec-i --suffix=B "$filesize" 2>/dev/null || echo "${filesize} bytes")
    
    log "INFO" "Starting transfer: ${filename} (${filesize_human})"
    
    # Get remote path based on date
    local remote_path
    remote_path=$(get_remote_path)
    
    # Retry loop
    local attempt=1
    local success=false
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        log "INFO" "Transfer attempt ${attempt}/${MAX_RETRIES}"
        
        # Check NAS is reachable
        if ! check_nas_reachable; then
            log "WARN" "NAS not reachable at ${NAS_HOST}"
            if [[ $attempt -lt $MAX_RETRIES ]]; then
                log "INFO" "Retrying in ${RETRY_DELAY} seconds..."
                sleep $RETRY_DELAY
                ((attempt++))
                continue
            else
                log "ERROR" "Failed to reach NAS after ${MAX_RETRIES} attempts"
                log "ERROR" "File retained locally: ${capture_file}"
                exit 1
            fi
        fi
        
        # Create remote directory
        if ! create_remote_directory "$remote_path"; then
            log "WARN" "Failed to create remote directory: ${remote_path}"
            ((attempt++))
            sleep $RETRY_DELAY
            continue
        fi
        
        # Transfer file(s)
        if transfer_with_metadata "$capture_file" "$remote_path"; then
            # Verify transfer
            if verify_transfer "$capture_file" "$remote_path"; then
                log "INFO" "Transfer verified: ${filename}"
                success=true
                break
            else
                log "WARN" "Transfer verification failed"
            fi
        else
            log "WARN" "Transfer failed"
        fi
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log "INFO" "Retrying in ${RETRY_DELAY} seconds..."
            sleep $RETRY_DELAY
        fi
        
        ((attempt++))
    done
    
    if [[ "$success" == true ]]; then
        # Clean up local file
        cleanup_local "$capture_file"
        log "INFO" "Transfer complete: ${filename} → ${NAS_HOST}:${remote_path}/"
        exit 0
    else
        log "ERROR" "Transfer failed after ${MAX_RETRIES} attempts"
        log "ERROR" "File retained locally: ${capture_file}"
        exit 1
    fi
}

main
