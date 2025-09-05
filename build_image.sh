#!/bin/bash
set -euo pipefail

# 彩色輸出
log() { echo -e "\033[1;32m[INFO]\033[0m $*"; }
err() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# 參數檢查
if [[ "$#" -ne 2 ]] || [[ "$1" == "--help" ]]; then
  echo "Usage: $0 <dockerfile_directory> <image_name>"
  echo "Example: $0 ./myapp myapp:1.0"
  exit 1
fi

DOCKERFILE_DIR="$1"
IMAGE_NAME="$2"
REGISTRY="${REGISTRY:-127.0.0.1:5000}"

# 環境檢查
if ! command -v docker &> /dev/null; then
  err "Docker is not installed or not in PATH."
  exit 1
fi

if ! sudo docker info > /dev/null 2>&1; then
  err "Docker daemon is not running or permission denied."
  exit 1
fi

if [ ! -d "$DOCKERFILE_DIR" ]; then
  err "Directory '$DOCKERFILE_DIR' does not exist."
  exit 1
fi

if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
  err "No Dockerfile found in directory '$DOCKERFILE_DIR'."
  exit 1
fi

# 建構
log "Building Docker image '$IMAGE_NAME' from directory '$DOCKERFILE_DIR'..."
sudo docker build -t "$IMAGE_NAME" "$DOCKERFILE_DIR"

# 標籤
log "Tagging Docker image as '$REGISTRY/$IMAGE_NAME'..."
sudo docker tag "$IMAGE_NAME" "$REGISTRY/$IMAGE_NAME"

# 推送
log "Pushing Docker image to '$REGISTRY/$IMAGE_NAME'..."
sudo docker push "$REGISTRY/$IMAGE_NAME"

log "Done!"

