#!/bin/sh
# Checks the built Base image (laravel-php) against the agreed contract.
# Usage: image-test.sh IMAGE
# Runs every check inside the image with no network and without its entrypoint.
set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 IMAGE" >&2
    exit 2
fi

docker run --rm -i --network none --entrypoint sh "$1" -s <<'CHECKS'
set -u
failures=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; failures=$((failures + 1)); }

# expect LABEL EXPECTED ACTUAL
expect() {
    if [ "$3" = "$2" ]; then pass "$1 is $2"; else fail "$1 is $2 (found: $3)"; fi
}

ini() { php -r 'echo ini_get($argv[1]);' "$1"; }

# --- PHP build: 7.4.33 with the official CVE-2026-109618/109619 backport ---
expect "PHP CLI version" "7.4.33" "$(php -r 'echo PHP_VERSION;')"
# max_multipart_body_parts only exists when the backport is compiled in.
expect "backport ini max_multipart_body_parts" "-1" "$(php -r 'var_export(ini_get("max_multipart_body_parts"));' | tr -d "'")"
case "$(php-fpm -v 2>&1)" in
    *"PHP 7.4.33 (fpm-fcgi)"*) pass "PHP-FPM version is 7.4.33" ;;
    *) fail "PHP-FPM version is 7.4.33 (found: $(php-fpm -v 2>&1 | head -1))" ;;
esac

# --- Extensions the App images rely on ---
# iconv is GNU libiconv compiled into PHP; pcntl/posix for Horizon; sockets for Papertrail.
for ext in bcmath ctype curl dom fileinfo iconv intl json mbstring openssl pcntl \
           pdo pdo_mysql posix SimpleXML sockets sodium tokenizer xml zip zlib; do
    if php -r 'exit(extension_loaded($argv[1]) ? 0 : 1);' "$ext"; then
        pass "extension $ext is loaded"
    else
        fail "extension $ext is loaded"
    fi
done
# GNU libiconv, not musl's iconv, which breaks //TRANSLIT.
expect "iconv implementation" "libiconv" "$(php -r 'echo ICONV_IMPL;')"
# php-meminfo, used by api's MemoryProfiler middleware.
if php -r 'exit(extension_loaded("meminfo") && function_exists("meminfo_dump") ? 0 : 1);'; then
    pass "extension meminfo is loaded (meminfo_dump exists)"
else
    fail "extension meminfo is loaded (meminfo_dump exists)"
fi
if php -r '$f = fopen("php://memory", "w+"); meminfo_dump($f); rewind($f); exit(is_array(json_decode(stream_get_contents($f), true)) ? 0 : 1);' 2>/dev/null; then
    pass "meminfo_dump writes valid JSON"
else
    fail "meminfo_dump writes valid JSON"
fi

# --- php.ini: 7.4 php.ini-production plus our customisations ---
expect "memory_limit" "512M" "$(ini memory_limit)"
expect "upload_max_filesize" "10M" "$(ini upload_max_filesize)"
expect "post_max_size" "8M" "$(ini post_max_size)"
# E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED & ~E_STRICT
expect "error_reporting" "6143" "$(ini error_reporting)"
expect "expose_php (off)" "" "$(ini expose_php)"
expect "display_errors (off)" "" "$(ini display_errors)"
expect "log_errors (on)" "1" "$(ini log_errors)"
expect "zend.assertions" "-1" "$(ini zend.assertions)"
# The backport removes upload progress; the setting must not claim it is on.
expect "session.upload_progress.enabled (off)" "" "$(ini session.upload_progress.enabled)"
# php-fpm reads the same php.ini as the CLI.
case "$(php-fpm -i 2>/dev/null | grep '^memory_limit')" in
    "memory_limit => 512M => 512M") pass "FPM memory_limit is 512M" ;;
    *) fail "FPM memory_limit is 512M (found: $(php-fpm -i 2>/dev/null | grep '^memory_limit'))" ;;
esac

# --- Tools: same versions as the 7.3 Base image in production ---
expect "architecture" "x86_64" "$(uname -m)"
expect "Composer version" "1.9.3" "$(composer --version 2>/dev/null | awk '{print $3}')"
expect "Node version" "v10.24.1" "$(node --version 2>&1)"
for tool in npm python git mysql bash make g++ curl; do
    if command -v "$tool" >/dev/null 2>&1; then pass "$tool is installed"; else fail "$tool is installed"; fi
done

# --- php-fpm ---
if php-fpm -t >/dev/null 2>&1; then pass "php-fpm config is valid"; else fail "php-fpm config is valid"; fi
expect "working directory" "/var/www/html" "$(pwd)"

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed" >&2
    exit 1
fi
echo "All checks passed"
CHECKS
