# Use the specified TensorFlow container as base
FROM aclaudioquiros/tf_package:v16

# Set working directory
WORKDIR /workspace

# Upgrade pip first
RUN pip install --upgrade pip

# Install additional dependencies that might be missing
# Note: Some packages may need to be installed manually due to Python 3.6 compatibility
RUN pip install --no-cache-dir \
    scanpy==1.7.2 \
    leidenalg==0.8.9 \
    lifelines==0.26.3 \
    wandb==0.12.7 \
    umap-learn==0.5.3 \
    kneed==0.8.2 \
    lxml==4.9.1

# Copy the project files
COPY . /workspace/

# Set Python path to include the workspace
ENV PYTHONPATH=/workspace:$PYTHONPATH

# Create necessary directories
RUN mkdir -p /workspace/datasets \
    && mkdir -p /workspace/results \
    && mkdir -p /workspace/data_model_output

# Set default command
CMD ["/bin/bash"]
