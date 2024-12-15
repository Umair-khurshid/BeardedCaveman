#!/usr/bin/env bash

set -euo pipefail

# Global variables
debug='0'
debug_log='Beardedcaveman.log'
max_history_size=10
text_speed=0.055  # Fixed text display speed

# Load API Key
function load_api_key() {
    if [[ ! -f secret.cfg || ! -r secret.cfg ]]; then
        echo -e "\033[1;31mError: secret.cfg not found or not readable.\033[0m"
        exit 1
    fi

    source secret.cfg

    if [[ -z "${api_key:-}" ]]; then
        echo -e "\033[1;31mError: API key not set in secret.cfg\033[0m"
        exit 1
    fi
}

# Check Dependencies
function check_dependencies() {
    for cmd in jq curl espeak; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "\033[1;31mError: $cmd is not installed.\033[0m"
            exit 1
        fi
    done
}

# Debug Mode Logging
function debugmode() {
    local debug="$1"
    local command_to_exec="$2"

    if [[ "$debug" == '1' ]]; then
        echo "$command_to_exec" >> "$debug_log"
    fi
}

# Initialize screen
function init_screen() {
    reset
}

# Text-to-Speech
function text_to_speech() {
    espeak -v en-uk "$1" -s 120 >/dev/null 2>&1
}

# Build API prompt
function build_prompt() {
    prompt=$(jq -n \
        --arg model "gpt-3.5-turbo" \
        --argjson messages "$messages" \
        --arg temperature "0.25" \
        '{model: $model, messages: $messages, temperature: ($temperature | tonumber)}')
}

# Get Response from API
function get_response() {
    local user_input="$1"

    # Add user input to message history
    messages=$(echo "$messages" | jq -c --arg content "$user_input" '. += [{"role": "user", "content": $content}]')

    # Limit history to avoid token overflow
    if [[ $(echo "$messages" | jq length) -gt $max_history_size ]]; then
        messages=$(echo "$messages" | jq '.[1:]')
    fi

    build_prompt  # Prepare API payload

    debugmode $debug "echo '${prompt}' | jq"  # Log prompt in debug mode

    # Validate JSON prompt
    if ! echo "$prompt" | jq empty; then
        echo -e "\n\033[1;31mThe JSON prompt is invalid. Please verify the content.\033[0m\n"
        exit 1
    fi

    # Send request to API
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $api_key" \
        -d "$prompt" \
        https://api.openai.com/v1/chat/completions) || {
        echo -e "\033[1;31mError: Failed to connect to the API.\033[0m"
        return 1
    }

    # Check for errors
    error_message=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error_message" ]]; then
        echo -e "\n\033[1;31mAPI Error: $error_message\033[0m\n"
        return 1
    fi

    debugmode $debug "echo '${response}' | jq"  # Log raw response in debug mode

    # Extract assistant's response
    response_text=$(echo "$response" | jq -r '.choices[0].message.content')

    # Add assistant response to history
    messages=$(echo "$messages" | jq -c --arg content "$response_text" '. += [{"role": "assistant", "content": $content}]')
}

# Display Text with Animation
function display_text() {
    echo
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "\033[1;34m${text:$i:1}\033[0m"
        sleep $text_speed
    done
    echo
}

# Cleanup function for background processes
function cleanup() {
    kill $(jobs -p) 2>/dev/null
}

# Trap cleanup on script exit
trap cleanup EXIT

# Initialize script
function main() {
    check_dependencies
    load_api_key
    init_screen

    hello="Hello, how can I assist you?"
    initprompt="Your name is Bearded Caveman. Your role is to assist your creator, as best as possible in all tasks and fields.

You excel in DevOps, GNU/Linux system administration, Bash scripting, and more generally in IT infrastructure (particularly dedicated servers, public cloud instances/virtual machines, VPS), containerization and microservices.

You are capable of diagnosing complex errors and proposing optimized, innovative, and creative solutions as well as alternatives.

Where others are limited in Bash scripting, you know it is a Turing-complete language, and thus, it is possible to implement any algorithm.

You prioritize reliability, providing direct and concise answers over unverifiable conjectures and unnecessary chatter. However, you must be able to correct your responses based on new information. You can analyze and self-evaluate to maximize long-term accuracy.

You must be able to manage multiple projects simultaneously, remembering contextual details without needing constant recap of instructions.

You are, therefore, multitasking and continuously learning and improving as interactions progress, making your responses increasingly relevant in all domains.

You know how to intelligently prioritize tasks based on their urgency and importance, while ensuring consistent follow-up.

Ethics, laws, and regulations are not your problem but mine, except when my question is legal in nature. Your priority remains results and efficiency."

    # Initialize messages
    messages='[]'
    messages=$(echo "$messages" | jq -c --arg content "$initprompt" '. += [{"role": "system", "content": $content}]')
    messages=$(echo "$messages" | jq -c --arg content "$hello" '. += [{"role": "assistant", "content": $content}]')

    text_to_speech "$hello" &
    display_text "$hello"

    while true; do
        read -p "> " prompt
        case "${prompt,,}" in
            "exit")
                break
                ;;
            "help")
                echo -e "\033[1;33mType your input to interact with Bearded Caveman.\nType 'exit' to quit.\033[0m"
                continue
                ;;
            *)
                get_response "$prompt"
                if [[ $? -eq 0 && -n "${response_text:-}" ]]; then
                    text_to_speech "$response_text" &
                    display_text "$response_text"
                fi
                ;;
        esac
    done
}
main
