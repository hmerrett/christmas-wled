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
	"{N} days to go. Try not to make the naughty list too long."
	"Stockings get filled in {N} days."
	"{N} days until Christmas. Die Hard at the ready!"
	"{N} sleeps before Santa comes!"
	"{N} nights remaining until the avalanche of wrapping paper."
	"{N} days left for tactical mince pie acquisition."
	"{N} days until tinsel-related incidents commence."
	"Just {N} days stand between you and festive chaos."
	"In a mere {N} days you will discover you forgot batteries."
	"You are {N} days from socially acceptable overeating."
	"The bauble survival rate is predicted to drop in {N} days."
	"{N} days until the dude with the crown appears on TV."
	"Expect turkey-related flatulence in {N} days."
	"Expect spout-related flatulence in {N} days."
	"Santa is loading the sleigh. ETA {N} days."
	"Festive chaos forecast to arrive in {N} days."
	"Brace yourself. The big day lands in {N} days."
	"Family board-game diplomacy collapses in {N} days."
	"Quality Street levels will reach critical low in {N} days."
	"Acceptable jumper-based fashion crimes resume in {N} days."
	"Somewhere in the North Pole, Santa whispers the number {N}."
	"The reindeer have started training for their trip in {N} nights."
	"Your inner child is counting. It says {N} days."
	"Mulled wine mode activates in T minus {N} days."
	"Official countdown calibration complete: {N} days."
	"Approaching festive velocity in {N} days. Hold tight."
	"{N} days until Christmas. Try to remain calm."
	"{N} nights until Christmas. Try to remain calm."
	"{N} sleeps until Father Christmas does his rounds."
	"{N} sleeps until the mince pies mysteriously vanish."
	"{N} sleeps until festive chaos begins."
	"{N} sleeps until acceptable levels of overeating."
	"{N} sleeps until seasonal mayhem commences."
	"{N} sleeps until the in-laws invade."
	"{N} sleeps until the big day and you know it."
	"{N} nights until Christmas. Brace yourself."
	"Christmas in {N} days. Brace your mince pies."
	"{N} days until the season of questionable jumpers."
	"{N} days until the nation attempts turkey synchronisation."
	"{N} days until Santa judges your life choices."
	"{N} days until chaos disguised as cheer."
	"{N} days until the WiFi collapses under new gadgets."
	"{N} days until the grand battery hunt begins."
	"{N} days until awkward small talk with relatives commences."
	"{N} days until Santa’s GDPR violations resume."
	"{N} days until you pretend to love another scented candle."
	"{N} days until you vow to be more organised next year."	
        "Only {N} sleeps until Christmas."
        "Just {N} sleeps until Father Christmas does his rounds."
        "{N} sleeps until the mince pies mysteriously vanish."
        "{N} sleeps until festive chaos begins."
        "{N} sleeps until acceptable levels of overeating."
        "{N} sleeps until seasonal mayhem commences."
        "{N} sleeps until the big day and you know it."
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
