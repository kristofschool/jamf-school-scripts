#!/bin/bash

# Jamf School Focus Script
# Activeert een les (beperkingsprofiel) voor een specifieke leerling
# Protocol: V2 voor auth, V4 voor actie

# 1. Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file missing. Operation aborted."
    echo "Copy .env.example to .env and fill in your Jamf credentials."
    exit 1
fi

# 2. Parameters (Hardcoded for testing, can be made dynamic later)
STUDENT_ID=9445
LESSON_ID=945
DURATION=300

echo "================================"
echo "Jamf School Focus Script"
echo "================================"
echo "Student ID: $STUDENT_ID"
echo "Lesson ID: $LESSON_ID"
echo "Duration: $DURATION seconds"
echo "Domain: $JAMF_DOMAIN"
echo "User: $JAMF_USER"
echo "================================"
echo ""

# 3. Authenticate and get Token (V2)
echo "Authenticating with Jamf School (Protocol V2)..."

RESPONSE_AUTH=$(curl -s -X POST "https://$JAMF_DOMAIN/api/teacher/authenticate" \
    -H "Authorization: Bearer $JAMF_AUTH" \
    -H "X-Server-Protocol-Version: 2" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$JAMF_USER\",\"password\":\"$JAMF_PASS\",\"company\":$JAMF_COMPANY}")

TOKEN=$(echo $RESPONSE_AUTH | grep -oE '"token":"[^"]+"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Authentication failed."
    echo "Response: $RESPONSE_AUTH"
    exit 1
fi

echo "✅ Authentication successful"
echo ""

# 4. Start Lesson (V4)
echo "Starting lesson with Protocol V4..."
echo "Payload: { scope: student, scopeId: $STUDENT_ID, students: [$STUDENT_ID], clearAfter: $DURATION }"
echo ""

RESULT=$(curl -s -X POST "https://$JAMF_DOMAIN/api/teacher/lessons/start/$LESSON_ID?token=$TOKEN" \
    -H "X-Server-Protocol-Version: 4" \
    -H "Content-Type: application/json" \
    -d "{ \"scope\": \"student\", \"scopeId\": $STUDENT_ID, \"students\": [$STUDENT_ID], \"clearAfter\": $DURATION }")

# 5. Output result
echo "================================"
if [[ $RESULT == *'"success":true'* ]] || [[ $RESULT == *'"success": true'* ]]; then
    echo "✅ SUCCESS: Lesson pushed to Student $STUDENT_ID"
    echo "Response: $RESULT"
else
    echo "❌ FAILURE: Server returned error"
    echo "Response: $RESULT"
    exit 1
fi
echo "================================"
