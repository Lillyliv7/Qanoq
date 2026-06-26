# Stage 1: Build Flutter
FROM ubuntu:24.04 AS flutter-builder
RUN apt-get update && apt-get install -y curl git unzip xz-utils && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --enable-web

WORKDIR /build
COPY Qanoq/ ./Qanoq/
WORKDIR /build/Qanoq
RUN flutter build web --release

# Stage 2: Python Runtime
FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn hfst
COPY . .
COPY --from=flutter-builder /build/Qanoq/build/web ./static

CMD ["python", "analyzer/api.py"]