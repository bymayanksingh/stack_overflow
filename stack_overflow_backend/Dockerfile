FROM elixir:1.16-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    inotify-tools \
    postgresql-client \
    git

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy source code
COPY . .

# Expose port
EXPOSE 4000

# Default command
CMD ["mix", "phx.server"]
