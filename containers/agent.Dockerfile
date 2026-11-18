FROM python:3.11-slim
RUN useradd --create-home --uid 1000 agent
WORKDIR /submission
USER agent
ENV HOME=/home/agent
CMD ["python3", "--version"]
