#!/bin/bash

# Script to run the Histomorphological Phenotype Learning project in Docker
# Usage: ./run_docker.sh [command]
# If no command is provided, it will start an interactive bash session

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Histomorphological Phenotype Learning Docker Container...${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

echo -e "${YELLOW}Project directory: $PROJECT_DIR${NC}"

# Create necessary directories if they don't exist
mkdir -p "$PROJECT_DIR/datasets"
mkdir -p "$PROJECT_DIR/results"
mkdir -p "$PROJECT_DIR/data_model_output"

# Check if we should build the image
if [ "$1" = "--build" ] || [ "$1" = "-b" ]; then
    echo -e "${YELLOW}Building Docker image...${NC}"
    docker compose build
    shift # Remove --build from arguments
fi

# If a command is provided, run it in the container
if [ $# -gt 0 ]; then
    echo -e "${YELLOW}Running command in container: $@${NC}"
    docker compose run --rm hpl-container "$@"
else
    echo -e "${YELLOW}Starting interactive container...${NC}"
    echo -e "${GREEN}You can now run HPL commands inside the container.${NC}"
    echo -e "${GREEN}Example commands:${NC}"
    echo -e "  python3 run_representationspathology.py --help"
    echo -e "  python3 run_representationsleiden.py --help"
    echo -e "  python3 report_representationsleiden_lr.py --help"
    echo -e ""
    docker compose run --rm hpl-container /bin/bash
fi

echo -e "${GREEN}Docker container session ended.${NC}"
