#!/bin/bash

python3 -m venv venv
source venv/bin/activate
pip install huggingface_hub
python download-model.py $1 $2
