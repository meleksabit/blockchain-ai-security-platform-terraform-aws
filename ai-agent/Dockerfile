# Stage 1: Build dependencies
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir hf_xet

# Stage 2: Runtime image
FROM python:3.12-slim
WORKDIR /home/appuser/app
COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY ai_agent.py .
RUN useradd -m appuser && \
    mkdir -p /home/appuser/.cache && \
    chown -R appuser:appuser /home/appuser
USER appuser
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8000/health || exit 1
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-w", "4", "-b", "0.0.0.0:8000", "ai_agent:app"]
