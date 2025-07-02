#!/bin/bash
helm uninstall kserve -n kserve
cd ..
tofu apply -auto-approve
cd -
