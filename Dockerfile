FROM continuumio/miniconda3

WORKDIR /app

# Copy repository contents
COPY . .

# Create and activate conda environment
RUN conda create -n "omni" python=3.12 -y
SHELL ["conda", "run", "-n", "omni", "/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir huggingface-cli

# Create download script
RUN echo 'from huggingface_hub import hf_hub_download\n\
files = [\n\
    "icon_detect/train_args.yaml",\n\
    "icon_detect/model.pt",\n\
    "icon_detect/model.yaml",\n\
    "icon_caption/config.json",\n\
    "icon_caption/generation_config.json",\n\
    "icon_caption/model.safetensors"\n\
]\n\
\n\
for f in files:\n\
    print(f"Downloading {f}")\n\
    hf_hub_download("microsoft/OmniParser-v2.0", f, local_dir="weights")\n\
' > download_weights.py

# Create weights directory and download model weights
RUN mkdir -p weights && \
    python download_weights.py && \
    cd weights && \
    mv icon_caption icon_caption_florence

# Expose port for Gradio
EXPOSE 7860

# Start the Gradio server
CMD ["conda", "run", "-n", "omni", "python", "gradio_demo.py"]
