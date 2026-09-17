# HealthRisk AI / HealthRisk Lab — Dockerfile
#
# Builds a single image that can run the CLI entrypoint and the Streamlit
# Lab dashboard. Secrets stay out of the image; mount or pass them via env.

FROM python:3.11-slim

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install project deps first so Docker layer caching works for code changes
COPY pyproject.toml README.md ./
COPY src/ src/
COPY configs/ configs/

# Install runtime dependencies (without dev tools for smaller image)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -e ".[dev]"

# Also copy tests and the rest of the repo for local reproduce builds
COPY . .

# Keep secrets out of the image; require .env mounting or env injection at runtime
ENV PYTHONUNBUFFERED=1

EXPOSE 8501

# Default command runs the Streamlit Lab; override for CLI usage
CMD ["streamlit", "run", "src/healthrisk_ai/ui/lab_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
