#!/bin/bash

while true; do
    # List all tmux sessions, extract session names, and use fzf to select one
    # The --print-query option allows for creating new sessions
    SESSION=$(tmux ls -F "#{session_name}" 2>/dev/null | fzf --print-query --prompt "Select a tmux session (or type a new name): " | tail -n1)

    if [[ -n "$SESSION" ]]; then
        # Check if the session exists
        if tmux has-session -t "$SESSION" 2>/dev/null; then
            # Prompt for action: Attach, Delete, or Cancel
            echo "Session '$SESSION' exists."
            read -p "Do you want to (a)ttach, (d)elete, or (c)ancel? [a/d/c]: " ACTION

            case "$ACTION" in
                a|A)
                    # Attach to the session
                    tmux attach-session -t "$SESSION"
                    exit 0
                    ;;
                d|D)
                    # Delete the session
                    read -p "Are you sure you want to delete session '$SESSION'? (y/n): " CONFIRM
                    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                        tmux kill-session -t "$SESSION"
                        echo "Session '$SESSION' deleted."
                    else
                        echo "Deletion canceled."
                    fi
                    ;;
                *)
                    echo "Action canceled."
                    ;;
            esac
        else
            # If the session doesn't exist, prompt to create it
            read -p "Session '$SESSION' does not exist. Create it? (y/n): " CONFIRM
            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                # Create and attach to the new session
                tmux new-session -d -s "$SESSION"
                tmux attach-session -t "$SESSION"
                exit 0
            else
                echo "Session creation canceled."
            fi
        fi
    else
        echo "No session selected. Exiting."
        exit 0
    fi

    echo -e "\nReturning to session list...\n"
done
