# WLED Christmas Countdown Text Script

`wled.sh` is a silly Bash script that updates a WLED LED matrix with a festive countdown message every time it runs.

It selects a random phrase, inserts the correct number of days until Christmas, and applies a random colour to the segment.

It is designed for WLED installations using a text-scrolling matrix preset, where the text displayed is taken from the segment name field via the JSON API.

## Features

- Calculates the number of days until the next 25th of December.
- Chooses from a large selection of festive, silly, cheeky, and occasionally chaotic messages.
- Inserts the countdown into the chosen phrase automatically.
- Sends the text to WLED using its JSON API.
- Generates a random colour every run and applies it to segment 0.
- Works in `Europe/London` timezone by default.
- Perfect as a cron job.

## Requirements

- A device (perhaps ESP32 or similar) running **WLED** with JSON API enabled.
- A preset or configuration where the segment name controls the displayed text.
- A Bash shell and `curl`.

## Installation

Make the script executable:

```bash
chmod +x wled.sh
```

Edit the script and set your WLED hostname or IP:

```bash
WLED_HOST="192.168.0.89"
```

Test it:

```bash
./wled.sh
```

## Cron Job

```cron
0 * * * * /path/to/wled.sh >/dev/null 2>&1
```

## Customisation

Add or modify phrases in the `phrases=( ... )` array.  
Each phrase must contain `{N}` which is replaced by the days until Christmas.

Random colours are generated automatically. Remove that section if undesired.

## How It Works

1. Calculates days until Christmas.
2. Selects a phrase.
3. Replaces `{N}`.
4. Builds a JSON payload with text and colour.
5. Sends it to:

```
http://WLED_HOST/json/state
```

## License

MIT License.

