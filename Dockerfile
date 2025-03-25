# # Stage 1: Builder
# FROM python:3.12.3-slim AS build

# WORKDIR /app

# ENV PIP_DEFAULT_TIMEOUT=100

# # Install build tools
# RUN apt-get update && apt-get install -y build-essential

# # Install Poetry
# ENV POETRY_VERSION=2.1.1
# ENV POETRY_VIRTUALENVS_IN_PROJECT=false

# RUN pip install --no-cache-dir poetry==$POETRY_VERSION
# RUN poetry config virtualenvs.create false

# # Copy dependency files
# COPY pyproject.toml poetry.lock* /app/

# # Install dependencies
# RUN poetry install --no-interaction --no-ansi --no-cache --no-root --only main

# # Stage 2: Final
# FROM python:3.12.3-slim

# WORKDIR /app

# # Copy installed dependencies
# COPY --from=build /usr/local/bin /usr/local/bin
# COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# COPY . /app

# # Create a non-root user and group
# RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# # Create the cache directory with proper ownership & permissions
# RUN mkdir -p /app/.composio_cache && chown -R appuser:appgroup /app/.composio_cache && chmod -R 777 /app/.composio_cache

# # Set the environment variable
# ENV COMPOSIO_CACHE_DIR=/app/.composio_cache

# # Switch to non-root user
# USER appuser

# # Expose port and run the application
# EXPOSE 8000
# ENTRYPOINT ["python3", "main.py"]


# Use slim Python image
FROM python:3.12.3-slim

WORKDIR /app

ENV PIP_DEFAULT_TIMEOUT=100
ENV POETRY_VERSION=2.1.1
ENV POETRY_VIRTUALENVS_IN_PROJECT=false
ENV COMPOSIO_CACHE_DIR=/app/.composio_cache

# Install system dependencies
RUN apt-get update && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry==$POETRY_VERSION
RUN poetry config virtualenvs.create false

# Copy project files
COPY pyproject.toml poetry.lock* /app/

# Install dependencies
RUN poetry install --no-interaction --no-ansi --no-cache --no-root --only main

# Copy the application code
COPY . /app

# Create a non-root user and set permissions
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser \
    && mkdir -p $COMPOSIO_CACHE_DIR \
    && chown -R appuser:appgroup $COMPOSIO_CACHE_DIR \
    && chmod -R 777 $COMPOSIO_CACHE_DIR

# Switch to the non-root user
USER appuser

# Expose port and run the application
EXPOSE 8000
ENTRYPOINT ["python3", "main.py"]
