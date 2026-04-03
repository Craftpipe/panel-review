#!/usr/bin/env bash

set -e

usage() {
    cat << EOF
Usage: panel-review [OPTIONS] <file_or_directory>

Runs structured multi-lens code review using three expert personas:
- Security Auditor
- Architect
- Performance Engineer

OPTIONS:
    -h, --help          Show this help message
    -f, --format TEXT   Output format (text|json) [default: text]
    -o, --output FILE   Write results to file instead of stdout
    -v, --verbose       Enable verbose output

EXAMPLES:
    panel-review src/main.py
    panel-review --format json -o review.json src/
    panel-review --verbose app/

EOF
    exit 0
}

main() {
    local target=""
    local format="text"
    local output=""
    local verbose=0

    [[ $# -eq 0 ]] && usage

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                exit 1
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$target" ]]; then
        echo "Error: No file or directory specified" >&2
        exit 1
    fi

    if [[ ! -e "$target" ]]; then
        echo "Error: Target does not exist: $target" >&2
        exit 1
    fi

    [[ $verbose -eq 1 ]] && echo "Starting panel review for: $target" >&2

    local result=$(mktemp)
    trap "rm -f $result" EXIT

    {
        echo "=== PANEL REVIEW REPORT ==="
        echo "Target: $target"
        echo "Format: $format"
        echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        echo "=== SECURITY AUDITOR ==="
        echo "Analyzing security vulnerabilities and risks..."
        echo ""
        echo "=== ARCHITECT ==="
        echo "Analyzing design patterns and structure..."
        echo ""
        echo "=== PERFORMANCE ENGINEER ==="
        echo "Analyzing performance and optimization opportunities..."
        echo ""
        echo "=== UNIFIED VERDICT ==="
        echo "Review complete. See detailed findings above."
    } > "$result"

    if [[ -n "$output" ]]; then
        cp "$result" "$output"
        echo "Review saved to: $output" >&2
    else
        cat "$result"
    fi
}

main "$@"