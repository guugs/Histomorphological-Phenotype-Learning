# Docker Setup for Histomorphological Phenotype Learning

This document explains how to run the Histomorphological Phenotype Learning (HPL) project using Docker with the `aclaudioquiros/tf_package:v16` container.

## Prerequisites

- Docker and Docker Compose installed on your system
- Sufficient disk space for datasets and results
- GPU support (optional, for faster training)

## Quick Start

### 1. Build and Run the Container

```bash
# Build the Docker image and start an interactive session
./run_docker.sh --build

# Or just start without rebuilding
./run_docker.sh
```

### 2. Run Specific Commands

```bash
# Run a specific HPL command
./run_docker.sh python3 run_representationspathology.py --help

# Run with custom arguments
./run_docker.sh python3 run_representationspathology.py \
  --img_size 224 \
  --batch_size 64 \
  --epochs 60 \
  --z_dim 128 \
  --model BarlowTwins_3 \
  --dataset TCGAFFPE_LUADLUSC_5x_250K \
  --check_every 10 \
  --report
```

## Directory Structure

The Docker setup mounts the following directories:

- `/workspace` - Main project directory
- `/workspace/datasets` - Dataset files (mounted from `./datasets`)
- `/workspace/results` - Output results (mounted from `./results`)
- `/workspace/data_model_output` - Model outputs (mounted from `./data_model_output`)
- `/workspace/utilities` - Utility scripts (mounted from `./utilities`)

## Available Commands

### Self-Supervised Training

```bash
python3 run_representationspathology.py \
  --img_size 224 \
  --batch_size 64 \
  --epochs 60 \
  --z_dim 128 \
  --model BarlowTwins_3 \
  --dataset TCGAFFPE_LUADLUSC_5x_250K \
  --check_every 10 \
  --report
```

### Tile Vector Representations

```bash
python3 run_representationspathology_projection.py \
  --dataset TCGAFFPE_LUADLUSC_5x_60pc_250K \
  --checkpoint ./data_model_output/BarlowTwins_3/TCGAFFPE_5x_perP_250k/h224_w224_n3_zdim128/checkpoints/BarlowTwins_3.ckt \
  --real_hdf5 ./datasets/TCGAFFPE_5x_perP/he/patches_h224_w224/hdf5_TCGAFFPE_5x_perP_he_test.h5 \
  --model BarlowTwins_3
```

### Leiden Clustering

```bash
python3 run_representationsleiden.py \
  --meta_field lung_subtypes_nn250 \
  --matching_field slides \
  --folds_pickle ./utilities/files/LUAD/folds_LUAD_Institutions.pkl \
  --h5_complete_path ./results/BarlowTwins_3/TCGAFFPE_LUADLUSC_5x_60pc/h224_w224_n3_zdim128/hdf5_TCGAFFPE_LUADLUSC_5x_60pc_he_complete_lungsubtype_survival.h5 \
  --subsample 200000
```

### Logistic Regression

```bash
python3 report_representationsleiden_lr.py \
  --meta_folder lung_subtypes_nn250 \
  --meta_field luad \
  --matching_field slides \
  --min_tiles 100 \
  --folds_pickle ./utilities/files/LUAD/folds_LUAD_Institutions.pkl \
  --h5_complete_path ./results/BarlowTwins_3/TCGAFFPE_LUADLUSC_5x_60pc/h224_w224_n3_zdim128/hdf5_TCGAFFPE_LUADLUSC_5x_60pc_he_complete_lungsubtype_survival.h5
```

### Cox Proportional Hazards

```bash
python3 report_representationsleiden_cox.py \
  --meta_folder luad_overall_survival_nn250 \
  --matching_field samples \
  --event_ind_field os_event_ind \
  --event_data_field os_event_data \
  --min_tiles 100 \
  --folds_pickle ./utilities/files/LUAD/overall_survival_TCGA_folds.pkl \
  --h5_complete_path ./results/BarlowTwins_3/TCGAFFPE_LUADLUSC_5x_60pc/h224_w224_n3_zdim128/hdf5_TCGAFFPE_LUADLUSC_5x_60pc_he_complete_lungsubtype_survival.h5
```

## GPU Support

To enable GPU support, uncomment the GPU-related lines in `docker-compose.yml`:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## Troubleshooting

### Container Won't Start

- Ensure Docker is running: `docker info`
- Check if the base image exists: `docker pull aclaudioquiros/tf_package:v16`

### Permission Issues

- Make sure the run script is executable: `chmod +x run_docker.sh`
- Check file permissions in mounted directories

### Memory Issues

- Increase Docker memory limits in Docker Desktop settings
- Use smaller batch sizes in training commands

### Dataset Issues

- Ensure datasets are in the correct directory structure
- Check that H5 files are accessible and not corrupted

## Environment Variables

The container sets the following environment variables:

- `PYTHONPATH=/workspace` - Ensures Python can find project modules
- `CUDA_VISIBLE_DEVICES=0` - Uses first GPU if available

## File Persistence

All important data is persisted through volume mounts:

- Datasets remain on your host system
- Results are saved to your host system
- Model outputs are preserved between container runs

## Advanced Usage

### Custom Docker Compose Commands

```bash
# Build without cache
docker compose build --no-cache

# Run in detached mode
docker compose up -d

# View logs
docker compose logs -f

# Stop container
docker compose down
```

### Direct Docker Commands

```bash
# Build image directly
docker build -t hpl-tf-container .

# Run container directly
docker run -it --rm \
  -v $(pwd):/workspace \
  -v $(pwd)/datasets:/workspace/datasets \
  -v $(pwd)/results:/workspace/results \
  -v $(pwd)/data_model_output:/workspace/data_model_output \
  hpl-tf-container /bin/bash
```

## Support

For issues specific to the HPL project, refer to the main README files:

- `README_HPL.md` - Main HPL instructions
- `README.md` - Project overview
- `README_replication.md` - Replication instructions
