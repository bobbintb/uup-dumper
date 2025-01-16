#!/bin/bash
output="archive.zip"
max_retries=5
retry_delay=30
attempt=1

if [ ! -d "/out" ]; then
  echo "You need to mount a volume in the host to '/out'!"
  exit 1
fi

cd /out
update_id=$(curl -s "https://uupdump.net/fetchupd.php?arch=amd64&ring=retail" | xmllint --html --xpath '//code/text()' - 2>/dev/null | head -n 1)
url="https://uupdump.net/get.php?id=${update_id}&pack=en-us&edition=professional"
echo "Found object id for latest build: ${update_id}"

while [ $attempt -le $max_retries ]; do
  response=$(curl -s -w "%{http_code}" -o "$output" "$url" --data-raw 'autodl=2&updates=1&cleanup=1')
  status_code="${response: -3}"

  if [ "$status_code" -eq 200 ]; then
    echo "Download successful"
    break
  elif [ "$status_code" -eq 429 ]; then
    echo "Rate limit hit, retrying in $retry_delay seconds... (Attempt $attempt)"
    attempt=$((attempt + 1))
    sleep $retry_delay
  else
    echo "Download failed with status $status_code"
    exit 1
  fi
done

if [ $attempt -gt $max_retries ]; then
  echo "Max retries reached, exiting"
  exit 1
fi
unzip -o ./archive.zip
rm archive.zip 
chmod +x uup_download_linux.sh
./uup_download_linux.sh
find . -not -iname "*.iso" -not -path "." -not -path ".." -exec rm -rf {} +
