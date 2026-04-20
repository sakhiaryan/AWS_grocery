FROM python:3.11-slim

WORKDIR /app

# System deps for psycopg2 + healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install python deps (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY . .

EXPOSE 5000

# Default: run dev server (app binds 0.0.0.0:5000)
CMD ["python3", "run.py"]
