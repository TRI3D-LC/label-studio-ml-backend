#!/bin/bash

# check if file `mobile_sam.pt` exists, otherwise download the model
# we keep this model inside the container, so we don't need to download it upfront
[ -f "$MOBILESAM_CHECKPOINT" ] ||
wget https://github.com/ChaoningZhang/MobileSAM/raw/master/weights/mobile_sam.pt -P $(dirname "$MOBILESAM_CHECKPOINT")

# Check if the file specified in the ONNX_CHECKPOINT environment variable exists
if [ -f "$VITH_CHECKPOINT" ] && [ ! -f "$ONNX_CHECKPOINT" ]; then
  # Run the python onnxconverter.py script if the file is not found
  python3 onnxconverter.py
else
  # if VITH_CHECKPOINT is not found, print a message to the console
  if [ ! -f "$VITH_CHECKPOINT" ]; then
    echo "VITH checkpoint not found in $VITH_CHECKPOINT. Run download_models.sh to download the model."
  else
    # Otherwise, print a message to the console
    echo "ONNX checkpoint found in $ONNX_CHECKPOINT, skipping conversion"
  fi
fi

# Execute the gunicorn command
exec gunicorn --preload --bind :$PORT --workers 1 --threads 8 --timeout 0 _wsgi:app