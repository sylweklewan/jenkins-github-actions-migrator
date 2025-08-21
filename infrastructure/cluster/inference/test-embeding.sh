#!/bin/bash

curl -H "Content-Type: application/json" \
-v http://80.188.223.202:10433/openai/v1/embeddings \
-d '{
  "model": "qwen3",
  "input": "This is an example sentence for embedding generation."
}'
