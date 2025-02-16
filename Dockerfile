FROM python:3.12-slim

WORKDIR /app

# Install system dependencies including OpenCV requirements
RUN apt-get update && apt-get install -y \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy repository contents
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir huggingface_hub

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
CMD ["python", "gradio_demo.py"]
