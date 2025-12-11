#!/usr/bin/env bash
# Update WLED scrolling text with a random "days til Christmas" message.

set -eu

# WLED device address (IP or DNS name)
WLED_HOST="192.168.0.89"   # change to your WLED device

# Force UK local time
export TZ="Europe/London"

today_epoch=$(date +%s)
today_ymd=$(date +%Y-%m-%d)
year=$(date +%Y)

christmas_this_year="${year}-12-25"

# If today is after this year's Christmas, count to next year
if [[ "${today_ymd}" > "${christmas_this_year}" ]]; then
    year=$((year + 1))
fi

christmas="${year}-12-25"
christmas_epoch=$(date -d "${christmas}" +%s)
seconds_left=$((christmas_epoch - today_epoch))

if (( seconds_left <= 0 )); then
    # Christmas Day (or later, if clock is odd)
    text="Merry Christmas"
else
    days_left=$((seconds_left / 86400))

    # Phrases containing {N} placeholder
    phrases=(
	"{N} days until Christmas. Behave yourself. Santa is watching."
	"Brace yourself. Christmas arrives in {N} days."
	"{N} days until Santa squeezes down your chimney, Matron."
	"Stockings get filled in {N} days."
	"{N} days until Christmas. Die Hard at the ready!"
	"{N} sleeps before Santa comes!"
	"Expect turkey-related flatulence in {N} days."
	"Expect spout-related flatulence in {N} days."
	"Santa is loading the sleigh. ETA {N} days."
	"Official Christmas countdown: {N} days."
	"Approaching Christmas in {N} days. Hold tight."
	"{N} days until Christmas."
	"{N} nights until Christmas."
	"{N} sleeps until Father Christmas does his rounds."
	"{N} sleeps until the mince pies mysteriously vanish."
	"{N} sleeps until Christmas."
	"{N} sleeps until Christmas mayhem commences."
	"{N} sleeps until the Christmas in-law invasion."
	"{N} nights until Christmas."
	"Christmas in {N} days."
	"{N} days until Santa judges your life choices."
        "Only {N} sleeps until Christmas."
        "Just {N} sleeps until Father Christmas does his rounds."
        "{N} sleeps until mince pie day."
        "{N} sleeps until Christmas chaos begins."
        "{N} sleeps until Christmas mayhem commences."
        "{N} sleeps until the big day."
        "{N} nights until Christmas. Brace yourself."
    )

    phrase="${phrases[RANDOM % ${#phrases[@]}]}"
    text="${phrase//\{N\}/${days_left}}"
fi


# Generate random RGB colour
R=$((RANDOM % 256))
G=$((RANDOM % 256))
B=$((RANDOM % 256))

# Build JSON payload with text + colour
json_payload=$(printf '{"seg":[{"id":0,"n":"%s","col":[[%d,%d,%d]]}]}\n' "$text" "$R" "$G" "$B")


#json_payload=$(printf '{"seg":[{"id":0,"n":"%s"}]}\n' "$text")

# Send to WLED JSON API
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$json_payload" \
  "http://${WLED_HOST}/json/state" >/dev/null

echo Sent $text
