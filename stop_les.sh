#!/bin/bash
if [ -f .env ]; then export $(grep -v '^#' .env | xargs); else echo "Error: .env missing"; exit 1; fi

STUDENT_ID=9445

TOKEN=$(curl -s -X POST "https://$JAMF_DOMAIN/api/teacher/authenticate" -H "Authorization: Bearer $JAMF_AUTH" -H "X-Server-Protocol-Version: 2" -H "Content-Type: application/json" -d "{\"username\":\"$JAMF_USER\",\"password\":\"$JAMF_PASS\",\"company\":$JAMF_COMPANY}" | grep -oE '"token":"[^"]+"' | cut -d'"' -f4)

# De STOP call gebruikt dezelfde V4 logica maar een andere endpoint
RESULT=$(curl -s -X POST "https://$JAMF_DOMAIN/api/teacher/lessons/stop?token=$TOKEN" -H "X-Server-Protocol-Version: 4" -H "Content-Type: application/json" -d "{\"scope\":\"student\",\"scopeId\":$STUDENT_ID,\"students\":[$STUDENT_ID]}")

echo "Stop result: $RESULT"
