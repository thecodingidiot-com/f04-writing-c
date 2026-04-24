#!/bin/bash

set -o pipefail

# Color codes (disabled if not a tty)
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_RESET='\033[0m'

if [[ ! -t 1 ]]; then
    C_GREEN=''
    C_RED=''
    C_RESET=''
fi

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

hr() {
    echo "────────────────────────────────────────────"
}

banner() {
    echo "════════════════════════════════════════════"
    echo "  f04 — Writing C  /  test.sh"
    echo "════════════════════════════════════════════"
}

pass() {
    local label="$1"
    echo -e "${C_GREEN}PASS${C_RESET}  $label"
    pass_count=$((pass_count + 1))
}

fail() {
    local label="$1"
    local reason="$2"
    echo -e "${C_RED}FAIL${C_RESET}  $label"
    echo "      $reason"
    fail_count=$((fail_count + 1))
}

celebrate() {
    echo ""
    echo "════════════════════════════════════════════"
    echo ""
    echo "Crash Bandicoot. Two developers. One house."
    echo "The same language you just used."
    echo ""
    echo "════════════════════════════════════════════"
}

# ─────────────────────────────────────────────────────────────────────────────
# Pre-flight
# ─────────────────────────────────────────────────────────────────────────────

if ! command -v gcc >/dev/null 2>&1; then
    echo "Error: gcc not found. Install it and rerun."
    exit 1
fi

if [[ ! -f hello.c && ! -f calculator.c && ! -f words.c && ! -f guess.c ]]; then
    echo "Error: no .c files found in the current directory."
    echo "Copy this script into your f04-practice directory and run it from there:"
    echo ""
    echo "  cp test.sh ~/f04-practice/"
    echo "  cd ~/f04-practice"
    echo "  bash test.sh"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Checks
# ─────────────────────────────────────────────────────────────────────────────

pass_count=0
fail_count=0

check_hello() {
    local label="hello.c — compiles and prints a greeting"
    if [[ ! -f hello.c ]]; then
        fail "$label" "hello.c not found"
        return
    fi
    if ! gcc -Wall -Wextra hello.c -o _hello 2>/dev/null; then
        fail "$label" "hello.c did not compile — run: gcc -Wall -Wextra hello.c -o hello"
        return
    fi
    local output
    output=$(./_hello 2>/dev/null | tr '[:upper:]' '[:lower:]')
    rm -f _hello
    if echo "$output" | grep -q 'hello'; then
        pass "$label"
    else
        fail "$label" "output did not contain 'hello' (got: $output)"
    fi
}

check_calculator() {
    local label="calculator.c — compiles and computes correctly"
    if [[ ! -f calculator.c ]]; then
        fail "$label" "calculator.c not found"
        return
    fi
    if ! gcc -Wall -Wextra calculator.c -o _calculator 2>/dev/null; then
        fail "$label" "calculator.c did not compile — run: gcc -Wall -Wextra calculator.c -o calculator"
        return
    fi
    local errors=0
    local result
    # addition
    result=$(printf '3 + 4\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -q '7'; then
        echo "      3 + 4: expected output to contain '7', got: $result"
        errors=$((errors + 1))
    fi
    # subtraction
    result=$(printf '10 - 3\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -q '7'; then
        echo "      10 - 3: expected output to contain '7', got: $result"
        errors=$((errors + 1))
    fi
    # multiplication
    result=$(printf '3 * 8\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -q '24'; then
        echo "      3 * 8: expected output to contain '24', got: $result"
        errors=$((errors + 1))
    fi
    # division
    result=$(printf '10 / 2\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -q '5'; then
        echo "      10 / 2: expected output to contain '5', got: $result"
        errors=$((errors + 1))
    fi
    # division by zero
    result=$(printf '5 / 0\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -qi 'zero\|error'; then
        echo "      5 / 0: expected an error message, got: $result"
        errors=$((errors + 1))
    fi
    # unknown operator
    result=$(printf '3 ^ 4\n' | ./_calculator 2>/dev/null)
    if ! echo "$result" | grep -qi 'unknown\|error'; then
        echo "      3 ^ 4: expected an error message for unknown operator, got: $result"
        errors=$((errors + 1))
    fi
    rm -f _calculator
    if [[ "$errors" -eq 0 ]]; then
        pass "$label"
    else
        fail "$label" "$errors test case(s) failed — see above"
    fi
}

check_words() {
    local label="words.c — compiles and counts words correctly"
    if [[ ! -f words.c ]]; then
        fail "$label" "words.c not found"
        return
    fi
    if ! gcc -Wall -Wextra words.c -o _words 2>/dev/null; then
        fail "$label" "words.c did not compile — run: gcc -Wall -Wextra words.c -o words"
        return
    fi
    local errors=0
    local result
    # three words, 15 characters
    result=$(echo "hello world foo" | ./_words 2>/dev/null)
    if ! echo "$result" | grep -q '3'; then
        echo "      'hello world foo': expected output to contain '3' (word count), got: $result"
        errors=$((errors + 1))
    fi
    if ! echo "$result" | grep -q '15'; then
        echo "      'hello world foo': expected output to contain '15' (char count), got: $result"
        errors=$((errors + 1))
    fi
    # one word, 3 characters
    result=$(echo "one" | ./_words 2>/dev/null)
    if ! echo "$result" | grep -q '1'; then
        echo "      'one': expected output to contain '1' (word count), got: $result"
        errors=$((errors + 1))
    fi
    if ! echo "$result" | grep -q '3'; then
        echo "      'one': expected output to contain '3' (char count), got: $result"
        errors=$((errors + 1))
    fi
    # empty input, 0 words, 0 characters
    result=$(echo "" | ./_words 2>/dev/null)
    if ! echo "$result" | grep -qE '^0 word'; then
        echo "      empty input: expected output to start with '0 word', got: $result"
        errors=$((errors + 1))
    fi
    rm -f _words
    if [[ "$errors" -eq 0 ]]; then
        pass "$label"
    else
        fail "$label" "$errors test case(s) failed — see above"
    fi
}

check_guess() {
    local label="guess.c — compiles cleanly"
    if [[ ! -f guess.c ]]; then
        fail "$label" "guess.c not found"
        return
    fi
    if gcc -Wall -Wextra guess.c -o _guess 2>/dev/null; then
        rm -f _guess
        pass "$label (game is interactive — play it yourself)"
    else
        fail "$label" "guess.c did not compile — run: gcc -Wall -Wextra guess.c -o guess"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat <<'HELP'
Usage: bash test.sh [OPTION]

  (no arguments)    Run all checks against .c files in the current directory.
  --help, -h        Show this message.

── Setup ────────────────────────────────────────────────────────────────────

Copy this script into your f04-practice directory and run it from there:

  cp test.sh ~/f04-practice/
  cd ~/f04-practice
  bash test.sh

── What the tester checks ───────────────────────────────────────────────────

  1. hello.c compiles with -Wall -Wextra and prints a greeting.
  2. calculator.c compiles and produces correct output for +, -, *, /,
     division by zero, and an unknown operator.
  3. words.c compiles and correctly counts words for several inputs.
  4. guess.c compiles cleanly. The game is interactive — the tester cannot
     play it. Run ./guess yourself to verify it works.

HELP
    exit 0
fi

if [[ -n "$1" ]]; then
    echo "Unknown option: $1"
    echo "Run bash test.sh --help for usage."
    exit 1
fi

banner
echo ""

check_hello
check_calculator
check_words
check_guess

echo ""
hr
TOTAL=$((pass_count + fail_count))
echo "  $pass_count / $TOTAL checks passed"

if [[ "$fail_count" -eq 0 ]]; then
    celebrate
    exit 0
else
    echo ""
    echo "Fix the failing checks and rerun."
    exit 1
fi
