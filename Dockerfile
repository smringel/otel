# Use the specified base image
FROM registry.cmmint.net/cmm/ubuntu20-elixir1144:latest

# Set environment variables
ENV MIX_ENV=prod
ENV LANG=C.UTF-8

USER root
# install build dependencies
RUN apt-get update 
RUN apt-get install -y \
  build-essential \
  git
RUN apt-get clean && \
  rm -f /var/lib/apt/lists/*_*
  
# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set the working directory
WORKDIR /app

# Copy the mix.exs and mix.lock files to the container
COPY mix.exs mix.lock ./

# Install Elixir dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy the rest of the application code
COPY . .

# Compile the application
RUN mix compile

# Build assets (if applicable)
# RUN npm install --prefix ./assets && \
#     npm run deploy --prefix ./assets && \
#     mix phx.digest

# Create the release
RUN mix release

# Expose the port the app runs on
EXPOSE 4000

# Set the entry point to run the release
CMD ["_build/prod/rel/otel/bin/otel", "start"]