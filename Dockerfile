FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy repository contents
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create weights directory and download model weights
RUN mkdir -p weights && \
    cd weights && \
    rm -rf icon_detect icon_caption icon_caption_florence && \
    pip install --no-cache-dir huggingface_hub && \
    python -c "from huggingface_hub import hf_hub_download; \
    for f in ['icon_detect/train_args.yaml', 'icon_detect/model.pt', 'icon_detect/model.yaml', \
              'icon_caption/config.json', 'icon_caption/generation_config.json', 'icon_caption/model.safetensors']: \
        hf_hub_download('microsoft/OmniParser-v2.0', f, local_dir='.')" && \
    mv icon_caption icon_caption_florence

# Run the Gradio demo
EXPOSE 7860
CMD ["python", "gradio_demo.py"]
