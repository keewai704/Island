#!/usr/bin/env bash
# Wallpaper effects from HyprFlux (github.com/ahmad9059/HyprFlux, MIT),
# applied through the shell so the palette follows the processed picture.
set -euo pipefail

state="${XDG_STATE_HOME:-$HOME/.local/state}/island"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/island/effects"
mkdir -p "$state" "$cache"

current=$(islandctl wallpaper list | jq -r '.current // empty')
case "$current" in
"$cache"/*) source=$(cat "$state/effect-source" 2>/dev/null || true) ;;
*) source="$current" ;;
esac
if [[ -z "$source" || ! -f "$source" ]]; then
    notify-send -u low "Wallpaper effects" "No wallpaper to process"
    exit 1
fi

declare -A effects=(
    ["Black & White"]="-colorspace gray -sigmoidal-contrast 10,40%"
    ["Blurred"]="-blur 0x10"
    ["Charcoal"]="-charcoal 0x5"
    ["Edge Detect"]="-edge 1"
    ["Emboss"]="-emboss 0x5"
    ["Frame Raised"]="+raise 150"
    ["Frame Sunk"]="-raise 150"
    ["Negate"]="-negate"
    ["Oil Paint"]="-paint 4"
    ["Posterize"]="-posterize 4"
    ["Polaroid"]="-polaroid 0"
    ["Sepia Tone"]="-sepia-tone 65%"
    ["Solarize"]="-solarize 80%"
    ["Sharpen"]="-sharpen 0x5"
    ["Vignette"]="-vignette 0x3"
    ["Vignette Black"]="-background black -vignette 0x3"
    ["Zoomed"]="-gravity Center -extent 1:1"
)

choice=$(
    { echo "No Effects"; printf '%s\n' "${!effects[@]}" | LC_COLLATE=C sort; } |
        rofi -dmenu -i -p "󰸉" -mesg "Choose desired wallpaper effect" \
            -theme-str 'window { width: 24em; } listview { lines: 9; }'
) || exit 0

if [[ "$choice" == "No Effects" ]]; then
    islandctl wallpaper set "$source" >/dev/null
    exit 0
fi
[[ -n "${effects[$choice]+set}" ]] || exit 1

name=$(basename "${source%.*}")
slug=$(tr -cs '[:alnum:]' '-' <<<"$choice" | tr '[:upper:]' '[:lower:]')
output="$cache/$name-${slug%-}.png"
notify-send -u low "Applying" "$choice"
read -ra arguments <<<"${effects[$choice]}"
magick "$source" "${arguments[@]}" "$output"
printf '%s' "$source" >"$state/effect-source"
islandctl wallpaper set "$output" >/dev/null
