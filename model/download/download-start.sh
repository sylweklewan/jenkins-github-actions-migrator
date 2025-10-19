#!/bin/bash

MODEL=$1
LOCAL_NAME=$2


python3 -m venv venv
source venv/bin/activate
pip install huggingface_hub
python download-model.py $MODEL $LOCAL_NAME
