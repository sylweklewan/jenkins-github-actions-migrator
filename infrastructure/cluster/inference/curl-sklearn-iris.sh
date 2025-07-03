#!/bin/bash

HOST_IP="80.188.223.202"
PORT="10434"
MODEL="sklearn-iris"
PROMPT='[[5.1, 3.5, 1.4, 0.2]]'

read -r -d '' PAYLOAD <<EOF
{
  "instances": $PROMPT
}
EOF

curl -s -X POST "$HOST_IP:$PORT/v1/models/$MODEL:predict" -H "Content-Type: application/json" -d "$PAYLOAD" && echo

