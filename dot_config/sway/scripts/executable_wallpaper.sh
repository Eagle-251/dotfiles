#!/bin/bash

# today="$(date +%Y_%d_%m)"
apiUrl="https://bing.biturl.top/"
defaultDir="$HOME/Pictures/BingWallpaper"


getWallpaperUrl() {
  curl -s $apiUrl | jq -r ".url"
}

getWallpaper() {
  filename=$(getWallpaper | cut -d "=" -f 2)
  wget -O "$defaultDir/$filename" getWallpaper
}
