#!/usr/bin/env bash

set -e

# Check if Python is installed and if not install it
if command -v python >/dev/null 2>&1; then
    echo "Python is already installed."
else
    echo "Python is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install python3 python-is-python3 -y
fi

# install dependencies
echo "[INFO] Downloading dependencies"
pip install qsm-forward==0.11 webdavclient3
export PATH=$PATH:/home/runnerx/.local/bin

# download head-phantom-maps
echo "[INFO] Downloading test data"
python get-maps.py
tar xf head-phantom-maps.tar
rm head-phantom-maps.tar

# generate bids data
echo "[INFO] Simulating BIDS dataset"
qsm-forward head-phantom-maps/ bids

# install qsmxt
echo "[INFO] Pulling QSMxT image"
sudo docker pull vnmd/qsmxt_5.1.0:20230905

echo "[INFO] Creating QSMxT container"
docker create --name qsmxt-container -it -v $(pwd):/tmp vnmd/qsmxt_5.1.0:20230905 /bin/bash

echo "[INFO] Starting QSMxT container"
docker start qsmxt-container

# do reconstruction using qsmxt
# run_2_qsm.py bids/ output/ --premade nextqsm
echo "[INFO] Starting QSM reconstruction"
docker exec qsmxt-container bash -c "qsmxt /tmp/bids/ /tmp/output_dir --premade 'fast' --auto_yes"

# run metrics + generate figure - pass command-line arguments
# python metrics.py bids/ output/

# display figure to github
# ...

