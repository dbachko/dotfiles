#!/usr/bin/env bash

# set -euxo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${1:-"${SCRIPT_DIR}/../.macos"}"
# ---------------------

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${RED}Error: Settings file not found at '$SETTINGS_FILE'${NC}"
    exit 1
fi

echo -e "🔍 Checking settings from '${YELLOW}${SETTINGS_FILE}${NC}'..."

# Process single-line 'defaults write' commands.
grep -E '^[[:space:]]*(sudo[[:space:]]+)?defaults[[:space:]]+(-currentHost[[:space:]]+)?write[[:space:]]+' "$SETTINGS_FILE" | while IFS= read -r line; do
    # Strip trailing comments and parse quoted keys like "Quit When Finished".
    line="${line%%#*}"
    line="${line%%2>*}"
    line="${line%%>*}"
    line="${line%%||*}"
    [[ "$line" == *\\ ]] && continue
    eval "cmd_parts=($line)"

    if [[ "${cmd_parts[0]}" == "sudo" ]]; then
        cmd_parts=("${cmd_parts[@]:1}")
    fi

    current_host=false
    if [[ "${cmd_parts[1]}" == "-currentHost" ]]; then
        current_host=true
        domain="${cmd_parts[3]}"
        key="${cmd_parts[4]}"
        value_from_file_raw=("${cmd_parts[@]:5}")
    else
        domain="${cmd_parts[2]}"
        key="${cmd_parts[3]}"
        value_from_file_raw=("${cmd_parts[@]:4}")
    fi

    # Normalize the value from the file for comparison
    val_type="${value_from_file_raw[0]}"
    val_data="${value_from_file_raw[1]}"
    expected_val=""

    case "$val_type" in
      "-bool")
        [[ "$val_data" == "false" ]] && expected_val="0" || expected_val="1"
        ;;
      "-string")
        expected_val="${value_from_file_raw[*]:1}"
        ;;
      "-int"|"-integer"|"-float")
        expected_val="$val_data"
        ;;
      *)
        # Handles cases with no type flag, e.g., "... AdminHostInfo HostName"
        expected_val="${value_from_file_raw[*]}"
        ;;
    esac

    # Construct and run the 'read' command
    if [[ "$current_host" == true ]]; then
        read_cmd=(defaults -currentHost read "$domain" "$key")
    else
        read_cmd=(defaults read "$domain" "$key")
    fi

    # Get the current setting, hiding "does not exist" errors
    command_output=$("${read_cmd[@]}" 2>&1)
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo -e "\nChecking key: ${YELLOW}${key}${NC} : ${read_cmd[*]}"
        echo "  .macos to set:  $expected_val"
        echo -e "  Failure:        ${RED}$command_output${NC}"
        # echo -e "  ➡️  ${RED}DIFFERENCE FOUND${NC}"
    elif [[ "$command_output" == "$expected_val" ]]; then
        # skip cuz 
        # echo -e "  Current:        $command_output"
        # echo -e "  ✅  ${GREEN}OK${NC}"
        printf " "
    else
        echo -e "\nChecking key: ${YELLOW}${key}${NC} : ${read_cmd[*]}"
        echo "  .macos to set:  $expected_val"
        echo -e "  Current:        ${RED}${command_output}${NC}"
        # echo -e "  ➡️  ${RED}DIFFERENCE FOUND${NC}"
    fi
done
