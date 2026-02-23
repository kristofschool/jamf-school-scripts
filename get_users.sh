#!/bin/bash

# Laad variabelen uit .env
if [ -f .env ]; then 
    export $(grep -v '^#' .env | xargs)
else 
    echo "Fout: .env bestand niet gevonden!"
    exit 1
fi

echo "Ophalen gebruikers voor Netwerk ID: $JAMF_NETWORK_ID..."

# De -u vlag combineert Network ID en API Key voor Basic Auth
RESULT=$(curl -s -X GET "https://$JAMF_DOMAIN/api/users" \
  -u "$JAMF_NETWORK_ID:$JAMF_API_KEY" \
  -H "X-Server-Protocol-Version: 3" \
  -H "Accept: application/json")

# Resultaat tonen
echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
