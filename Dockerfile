# Base image
FROM python:3.12-slim-bookworm AS base

# Set environment variables for Poetry
ENV POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=true \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1
ENV PATH="$PATH:$POETRY_HOME/bin"

# Install Poetry
RUN pip install poetry

# Build stage
FROM base AS build
WORKDIR /app

# Copy only the files needed for dependency resolution
COPY pyproject.toml ./
RUN poetry install --no-root --only main

# Copy the rest of your application code
COPY . .

# Runtime stage
FROM base AS runtime
WORKDIR /app

# Copy the installed dependencies from the build stage
COPY --from=build /app /app

# Copy the .env file into the image
ENV PATH="/app/.venv/bin:$PATH"

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["flask", "--app", "app", "run", "--host", "0.0.0.0"]