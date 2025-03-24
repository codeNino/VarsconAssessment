# Stage 1: Builder
FROM python:3.12.3-slim AS build

WORKDIR /app

ENV PIP_DEFAULT_TIMEOUT=100

# Install build tools
RUN apt-get update && apt-get install -y build-essential

# Install Poetry
ENV POETRY_VERSION=1.8.3
# Ensure Poetry installs to system site packages
ENV POETRY_VIRTUALENVS_IN_PROJECT=false

RUN pip install --no-cache-dir poetry==$POETRY_VERSION

# Configure Poetry to not use virtual environments
RUN poetry config virtualenvs.create false

# Copy pyproject.toml and poetry.lock
COPY pyproject.toml poetry.lock* /app/

# Install dependencies using Poetry
RUN poetry install --no-interaction --no-ansi --no-cache --no-root --only main


# Stage 2: Final
FROM python:3.12.3-slim

WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages


# Copy application code
COPY . /app

# Create a non-root user and switch to it
RUN useradd -m appuser

USER appuser

# Expose port and run the application
EXPOSE 8080


ENTRYPOINT ["python3", "main.py"]





