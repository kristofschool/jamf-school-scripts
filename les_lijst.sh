k#!/bin/bash

# 1. Laad variabelen uit .env
if [ -f .env ]; then 
    export $(grep -v '^#' .env | xargs)
else 
    echo "Fout: .env bestand niet gevonden!"
    exit 1
fi

# Stap 1: Token ophalen (V2 blijft hiervoor de standaard)
TOKEN=$(curl -s -X POST "https://$JAMF_DOMAIN/api/teacher/authenticate" \
  -H "Authorization: Bearer $JAMF_AUTH" \
  -H "X-Server-Protocol-Version: 2" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$JAMF_USER\",\"password\":\"$JAMF_PASS\",\"company\":$JAMF_COMPANY}" | grep -oE '"token":"[^"]+"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then echo "Inloggen mislukt!"; exit 1; fi

echo "Lijst met alle lessen ophalen (Protocol V3)..."
echo "------------------------------------------------"

# Stap 2: Lessen ophalen met EXACT jouw parameters:
# - Versie 3
# - Accept header
# - Token in de URL
RESULT=$(curl -s -v "https://$JAMF_DOMAIN/api/teacher/lessons?token=$TOKEN" \
  -H "X-Server-Protocol-Version: 3" \
  -H "Accept: application/json")

echo "------------------------------------------------"
echo "RUWE OUTPUT:"
echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
