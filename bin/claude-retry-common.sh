#!/bin/bash

# Shared retry logic for Claude commands
# Source this file in scripts that need retry functionality

# Retry configuration (can be overridden by setting these before sourcing)
: ${MAX_RETRIES:=3}
: ${INITIAL_BACKOFF:=5}  # seconds
: ${MAX_BACKOFF:=60}     # seconds

# Function to log errors (define if not already defined)
if ! type log_error &>/dev/null; then
    log_error() {
        echo "$@" >&2
    }
fi

# Function to execute Claude command with retry logic
execute_claude_with_retry() {
    local retry_count=0
    local backoff=$INITIAL_BACKOFF
    local output=""
    local exit_code=0
    
    while [ $retry_count -le $MAX_RETRIES ]; do
        # Execute the command directly with all arguments
        output=$("$@" 2>&1)
        exit_code=$?
        
        # Check if it's a network error or rate limit
        if echo "$output" | grep -qE "(network|connection|timeout|cannot connect|unreachable|rate limit|too many requests|429|slow down|making requests too quickly)" && [ $exit_code -ne 0 ]; then
            if [ $retry_count -lt $MAX_RETRIES ]; then
                retry_count=$((retry_count + 1))
                # Determine error type for message
                if echo "$output" | grep -qE "(rate limit|too many requests|429|slow down|making requests too quickly)"; then
                    log_error "\n\033[93m⚠️  Rate limit detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                else
                    log_error "\n\033[93m⚠️  Network error detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                fi
                sleep $backoff
                # Exponential backoff with jitter
                backoff=$((backoff * 2))
                if [ $backoff -gt $MAX_BACKOFF ]; then
                    backoff=$MAX_BACKOFF
                fi
                # Add small random jitter (0-2 seconds)
                jitter=$((RANDOM % 3))
                sleep $jitter
                continue
            else
                # Final retry failed, return the error
                echo "$output"
                return $exit_code
            fi
        else
            # Not a network error, or successful
            echo "$output"
            return $exit_code
        fi
    done
    
    echo "$output"
    return $exit_code
}

# Function to execute Claude with retry using prompt file
# Usage: execute_claude_with_retry_from_file logfile command prompt_file
execute_claude_with_retry_from_file() {
    local logfile="$1"
    local command="$2"
    local prompt_file="$3"
    local retry_count=0
    local backoff=$INITIAL_BACKOFF
    local output=""
    local exit_code=0
    
    # Validate prompt file exists
    if [ ! -f "$prompt_file" ]; then
        log_error "Error: Prompt file not found: $prompt_file"
        return 1
    fi
    
    while [ $retry_count -le $MAX_RETRIES ]; do
        # Execute command with prompt file - avoids shell interpretation issues
        if [[ "$command" =~ ^docker[[:space:]]exec ]]; then
            # For docker exec, we need to split the command properly
            local docker_parts=($command)
            output=$("${docker_parts[@]}" --dangerously-skip-permissions -p "@$prompt_file" 2>&1 | tee "$logfile")
            exit_code=${PIPESTATUS[0]}
        else
            # Direct command execution
            output=$("$command" --dangerously-skip-permissions -p "@$prompt_file" 2>&1 | tee "$logfile")
            exit_code=${PIPESTATUS[0]}
        fi
        
        # Check for ACTUAL network errors or rate limits
        if [ $exit_code -ne 0 ] && echo "$output" | grep -qE "(curl:.*Could not resolve|curl:.*Connection refused|curl:.*Operation timed out|HTTP 429|rate limit exceeded|You are being rate limited|too many requests|slow down)"; then
            if [ $retry_count -lt $MAX_RETRIES ]; then
                retry_count=$((retry_count + 1))
                if echo "$output" | grep -qE "(rate limit|too many requests|429|slow down)"; then
                    log_error "\n\033[93m⚠️  Rate limit detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                else
                    log_error "\n\033[93m⚠️  Network error detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                fi
                sleep $backoff
                backoff=$((backoff * 2))
                if [ $backoff -gt $MAX_BACKOFF ]; then
                    backoff=$MAX_BACKOFF
                fi
                jitter=$((RANDOM % 3))
                sleep $jitter
                continue
            fi
        fi
        break
    done
    
    echo "$output"
    return $exit_code
}

# Function to execute Claude with retry and tee to logfile
# Usage: execute_claude_with_retry_and_log logfile command [args...]
execute_claude_with_retry_and_log() {
    local logfile="$1"
    shift  # Remove logfile from arguments
    local retry_count=0
    local backoff=$INITIAL_BACKOFF
    local output=""
    local exit_code=0
    
    while [ $retry_count -le $MAX_RETRIES ]; do
        # Execute the command directly with proper argument handling
        # This avoids eval and shell interpretation issues
        output=$("$@" 2>&1 | tee "$logfile")
        exit_code=${PIPESTATUS[0]}
        
        # Check for ACTUAL network errors or rate limits in the output
        # Be more specific to avoid false positives
        if [ $exit_code -ne 0 ] && echo "$output" | grep -qE "(curl:.*Could not resolve|curl:.*Connection refused|curl:.*Operation timed out|HTTP 429|rate limit exceeded|You are being rate limited|too many requests|slow down)"; then
            if [ $retry_count -lt $MAX_RETRIES ]; then
                retry_count=$((retry_count + 1))
                # Determine error type for message
                if echo "$output" | grep -qE "(rate limit|too many requests|429|slow down|making requests too quickly)"; then
                    log_error "\n\033[93m⚠️  Rate limit detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                else
                    log_error "\n\033[93m⚠️  Network error detected. Retry $retry_count/$MAX_RETRIES in ${backoff}s...\033[0m"
                fi
                sleep $backoff
                # Exponential backoff
                backoff=$((backoff * 2))
                if [ $backoff -gt $MAX_BACKOFF ]; then
                    backoff=$MAX_BACKOFF
                fi
                # Add small random jitter (0-2 seconds)
                jitter=$((RANDOM % 3))
                sleep $jitter
                continue
            fi
        fi
        # Break out of loop if not a network error or if max retries reached
        break
    done
    
    echo "$output"
    return $exit_code
}