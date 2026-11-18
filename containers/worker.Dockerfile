FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libelf1 libnuma1 libx11-6 libxext6 libxt6 time && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --uid 1000 worker
WORKDIR /run
USER worker
ENV HOME=/tmp
ENV TMPDIR=/tmp
ENV VCS_TMPDIR=/tmp
CMD ["python3", "--version"]
