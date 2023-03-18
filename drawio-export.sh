#!/bin/bash
#
# This script will render all draw.io diaghrams and
# move them to the correct path so the images are updated
# when commiting to git of deploying the application




# Donwload draw.io desktop for linux
# https://github.com/jgraph/drawio-desktop/releases/download/v20.8.16/drawio-x86_64-20.8.16.AppImage


if [ ! -f draw.io.AppImage ]; then
    curl -L -o draw.io.AppImage https://github.com/jgraph/drawio-desktop/releases/download/v20.8.16/drawio-x86_64-20.8.16.AppImage
    chmod +x draw.io.AppImage
fi

MEGA_RESUME_PATH='mkdocs/docs/projects/mega-resume'

./draw.io.AppImage --export --format svg --uncompressed ${MEGA_RESUME_PATH}/docs/resume-flow-diagram.drawio

mv ${MEGA_RESUME_PATH}/docs/resume-flow-diagram.svg ${MEGA_RESUME_PATH}/images/resume-flow-diagram.svg



#!/bin/bash
#
# drawio-export.sh
#
# This script exports draw.io diagrams to SVG format and moves them to the
# specified directory. It ensures that the draw.io AppImage is present,
# downloading it if necessary, and provides feedback during the execution.
#
# Usage:
#   ./drawio-export.sh
#
# Requirements:
#   - curl
#
# Notes:
#   - Update the constants at the beginning of the script to change the
#     draw.io AppImage URL, diagram paths, or other settings as needed.
#   - Ensure you have the necessary permissions to create and modify files
#     and directories specified in the script.
#   - New verisons of Draw.io can be found here: https://github.com/jgraph/drawio-desktop/releases
#

# CONSTANTS
APPIMAGE_NAME="draw.io.AppImage"
APPIMAGE_URL="https://github.com/jgraph/drawio-desktop/releases/download/v20.8.16/drawio-x86_64-20.8.16.AppImage"

# MEGA RESUME PROJECT
MEGA_RESUME_PATH="mkdocs/docs/projects/mega-resume"
INPUT_DIAGRAM="${MEGA_RESUME_PATH}/docs/resume-flow-diagram.drawio"
OUTPUT_DIAGRAM="${MEGA_RESUME_PATH}/images/resume-flow-diagram.svg"

# Ensure draw.io AppImage is present, download if not
if [ ! -f "${APPIMAGE_NAME}" ]; then
    echo "Downloading draw.io AppImage..."
    curl -L -o "${APPIMAGE_NAME}" "${APPIMAGE_URL}"
    chmod +x "${APPIMAGE_NAME}"
fi

# Export draw.io diagram to SVG
echo "Exporting draw.io diagram..."
./"${APPIMAGE_NAME}" --export --format svg --uncompressed "${INPUT_DIAGRAM}"

# Move exported SVG to the correct location
echo "Moving exported SVG..."
mv "${INPUT_DIAGRAM%.*}.svg" "${OUTPUT_DIAGRAM}"

echo "Done!"
