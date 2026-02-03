#!/bin/bash
#
# Birdhouse Vision - Data Lifecycle Cleanup Script
# 
# This script manages the data lifecycle on the NAS Pi:
# - NORMAL MODE: Delete captures older than 365 days
# - EMERGENCY MODE: If disk >= 95%, delete oldest files until < 90%
#
# Usage:
#   ./lifecycle-cleanup.sh           # Run cleanup
#   ./lifecycle-cleanup.sh --dry-run # Preview what would be deleted
#
# Designed to run daily via systemd timer (birdhouse-lifecycle.timer)

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Paths
CAPTURES_DIR="/mnt/birdhouse/captures"
LOG_DIR="/mnt/birdhouse/logs"
LOG_FILE="${LOG_DIR}/lifecycle.log"

# Retention policy
RETENTION_DAYS=365

# Disk thresholds (percentage)
EMERGENCY_THRESHOLD=95  # Trigger emergency cleanup
TARGET_THRESHOLD=90     # Target after emergency cleanup

# Dry run mode
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output
    echo "[${timestamp}] [${level}] ${message}"
    
    # File output (skip if dry-run or log dir doesn't exist)
    if [[ "$DRY_RUN" == false ]] && [[ -d "$LOG_DIR" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    fi
}

get_disk_usage() {
    # Returns disk usage percentage as integer (e.g., 75)
    df "$CAPTURES_DIR" | awk 'NR==2 {gsub(/%/,""); print $5}'
}

get_disk_available_gb() {
    # Returns available space in GB
    df -BG "$CAPTURES_DIR" | awk 'NR==2 {gsub(/G/,""); print $4}'
}

count_files() {
    find "$CAPTURES_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.json" \) 2>/dev/null | wc -l
}

delete_old_files() {
    # Delete files older than RETENTION_DAYS
    local deleted_count=0
    local deleted_size=0
    
    log "INFO" "Scanning for files older than ${RETENTION_DAYS} days..."
    
    while IFS= read -r -d '' file; do
        local file_size
        file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        
        if [[ "$DRY_RUN" == true ]]; then
            log "DRY-RUN" "Would delete: $file ($(numfmt --to=iec-i --suffix=B $file_size 2>/dev/null || echo "${file_size}B"))"
        else
            rm -f -- "$file"
            log "INFO" "Deleted: $file"
        fi
        
        ((deleted_count++)) || true
        ((deleted_size += file_size)) || true
    done < <(find "$CAPTURES_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.json" \) -mtime +${RETENTION_DAYS} -print0 2>/dev/null)
    
    # Clean up empty directories
    if [[ "$DRY_RUN" == false ]]; then
        find "$CAPTURES_DIR" -type d -empty -delete 2>/dev/null || true
    fi
    
    local size_human
    size_human=$(numfmt --to=iec-i --suffix=B $deleted_size 2>/dev/null || echo "${deleted_size} bytes")
    
    if [[ $deleted_count -gt 0 ]]; then
        log "INFO" "Normal cleanup: ${deleted_count} files (${size_human}) deleted"
    else
        log "INFO" "Normal cleanup: No files older than ${RETENTION_DAYS} days found"
    fi
    
    echo "$deleted_count"
}

emergency_cleanup() {
    # Delete oldest files until disk usage drops below TARGET_THRESHOLD
    log "WARN" "EMERGENCY CLEANUP: Disk usage >= ${EMERGENCY_THRESHOLD}%"
    log "WARN" "Deleting oldest files until disk < ${TARGET_THRESHOLD}%..."
    
    local deleted_count=0
    local current_usage
    
    # Get list of files sorted by modification time (oldest first)
    while IFS= read -r file; do
        current_usage=$(get_disk_usage)
        
        if [[ $current_usage -lt $TARGET_THRESHOLD ]]; then
            log "INFO" "Target reached: Disk now at ${current_usage}%"
            break
        fi
        
        if [[ "$DRY_RUN" == true ]]; then
            log "DRY-RUN" "Would delete (emergency): $file"
        else
            rm -f -- "$file"
            # Also delete associated metadata file if it exists
            local json_file="${file%.*}.json"
            [[ -f "$json_file" ]] && rm -f -- "$json_file"
            log "WARN" "Emergency deleted: $file"
        fi
        
        ((deleted_count++)) || true
        
        # Safety limit: don't delete more than 10000 files in one run
        if [[ $deleted_count -ge 10000 ]]; then
            log "WARN" "Safety limit reached (10000 files). Will continue next run."
            break
        fi
    done < <(find "$CAPTURES_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -printf '%T+ %p\n' 2>/dev/null | sort | cut -d' ' -f2-)
    
    # Clean up empty directories
    if [[ "$DRY_RUN" == false ]]; then
        find "$CAPTURES_DIR" -type d -empty -delete 2>/dev/null || true
    fi
    
    log "WARN" "Emergency cleanup: ${deleted_count} files deleted"
    echo "$deleted_count"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    log "INFO" "=========================================="
    log "INFO" "Birdhouse Data Lifecycle Cleanup Starting"
    log "INFO" "=========================================="
    
    if [[ "$DRY_RUN" == true ]]; then
        log "INFO" "*** DRY RUN MODE - No files will be deleted ***"
    fi
    
    # Check if captures directory exists
    if [[ ! -d "$CAPTURES_DIR" ]]; then
        log "ERROR" "Captures directory not found: ${CAPTURES_DIR}"
        log "ERROR" "Is the SSD mounted?"
        exit 1
    fi
    
    # Create log directory if needed
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$LOG_DIR"
    fi
    
    # Get initial stats
    local disk_usage
    local disk_available
    local file_count
    
    disk_usage=$(get_disk_usage)
    disk_available=$(get_disk_available_gb)
    file_count=$(count_files)
    
    log "INFO" "Initial state:"
    log "INFO" "  - Disk usage: ${disk_usage}%"
    log "INFO" "  - Available: ${disk_available}GB"
    log "INFO" "  - Total capture files: ${file_count}"
    
    local total_deleted=0
    
    # Check for emergency mode first (disk space takes priority)
    if [[ $disk_usage -ge $EMERGENCY_THRESHOLD ]]; then
        local emergency_deleted
        emergency_deleted=$(emergency_cleanup)
        ((total_deleted += emergency_deleted)) || true
    fi
    
    # Normal retention cleanup (always runs)
    local normal_deleted
    normal_deleted=$(delete_old_files)
    ((total_deleted += normal_deleted)) || true
    
    # Final stats
    disk_usage=$(get_disk_usage)
    disk_available=$(get_disk_available_gb)
    file_count=$(count_files)
    
    log "INFO" "Final state:"
    log "INFO" "  - Disk usage: ${disk_usage}%"
    log "INFO" "  - Available: ${disk_available}GB"
    log "INFO" "  - Total capture files: ${file_count}"
    log "INFO" "  - Files cleaned: ${total_deleted}"
    log "INFO" "=========================================="
    log "INFO" "Lifecycle cleanup complete"
    log "INFO" "=========================================="
}

main "$@"
