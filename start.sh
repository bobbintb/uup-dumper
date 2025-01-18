#!/bin/bash
if [ ! -d "/out" ]; then
  echo "You need to mount a volume in the host to '/out'!"
  exit 1
fi

if [[ "$BUILD" != "YES" ]]; then
  echo "Not set to automatically build when starting container. Exiting..."
  exit 0
fi

output="archive.zip"
max_retries=5
retry_delay=30
attempt=1

AUTODL=2
EDITION=""
if [[ "$HOME" == "YES" || "$HOMESINGLE" == "YES" ]]; then
    EDITION+="core;"
fi
if [[ "$HOMEN" == "YES" ]]; then
    EDITION+="coren;"
fi
if [[ "$PRO" == "YES" || "$PROFORWORK" == "YES" || "$PROEDU" == "YES" || "$EDU" == "YES" || "$ENT" == "YES" || "$ENTMS" == "YES" || "$IOTENT" == "YES" || "$IOTENTSUB" == "YES" ]]; then
    EDITION+="professional;"
fi
if [[ "$PRON" == "YES" || "$PRONFORWORK" == "YES" || "$PROEDUN" == "YES" || "$EDUN" == "YES" || "$ENTN" == "YES" ]]; then
    EDITION+="professionaln"
fi

EDITION="${EDITION%;}"

VIRTUALEDITIONS=""
if [[ "$HOMESINGLE" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=CoreSingleLanguage"
    AUTODL=3
fi
if [[ "$PROFORWORK" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=ProfessionalWorkstation"
    AUTODL=3
fi
if [[ "$PROEDU" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=ProfessionalEducation"
    AUTODL=3
fi
if [[ "$EDU" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=Education"
    AUTODL=3
fi
if [[ "$ENT" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=Enterprise"
    AUTODL=3
fi
if [[ "$ENTMS" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=ServerRdsh"
    AUTODL=3
fi
if [[ "$IOTENT" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=IoTEnterprise"
    AUTODL=3
fi
if [[ "$IOTENTSUB" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=IoTEnterpriseK"
    AUTODL=3
fi
if [[ "$PRONFORWORK" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=ProfessionalWorkstationN"
    AUTODL=3
fi
if [[ "$PROEDUN" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=ProfessionalEducationN"
    AUTODL=3
fi
if [[ "$EDUN" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=EducationN"
    AUTODL=3
fi
if [[ "$ENTN" == "YES" ]]; then
    VIRTUALEDITIONS+="&virtualEditions[]=EnterpriseN"
    AUTODL=3
fi

mkdir -p /out/working
cd /out/working
update_id=$(curl -s "https://uupdump.net/fetchupd.php?arch=amd64&ring=retail" | xmllint --html --xpath '//code/text()' - 2>/dev/null | head -n 1)
url="https://uupdump.net/get.php?id=${update_id}&pack=en-us&edition=${EDITION}"
echo "Found object id for latest build: ${update_id}"
sleep 5

while [ $attempt -le $max_retries ]; do
  echo "Editions included in ISO: ${EDITION} ${VIRTUALEDITIONS}"
  response=$(curl -s -w "%{http_code}" -o "$output" "$url" --data-raw "autodl=${AUTODL}&updates=1&cleanup=1${VIRTUALEDITIONS}")
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
#find . -not -iname "*.iso" -not -path "." -not -path ".." -exec rm -rf {} +
/info_creator.sh /out/*.ISO
mv *.ISO /out
mv image_info.txt /out
cd ..
rm -dr ./working
