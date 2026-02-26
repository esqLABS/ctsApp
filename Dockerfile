FROM rocker/r-ver:4.5.1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  dotnet-runtime-8.0 \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  git \
  libgit2-dev \
  libssh2-1-dev \
  && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/lib/x86_64-linux-gnu/libdl.so.2 /usr/lib/x86_64-linux-gnu/libdl.so

# Pass GitHub token for private repos
ARG GITHUB_PAT
ENV GITHUB_PAT=${GITHUB_PAT}

# Copy the app package
COPY . /app
WORKDIR /app

# Install renv and restore environment
RUN R -e "install.packages('renv'); \
          options(renv.config.repos.override = 'https://packagemanager.posit.co/cran/latest'); \
          renv::restore();"

# Install your golem package
RUN R -e "renv::install('.')"

EXPOSE 80
CMD ["R", "-e", "options(shiny.host='0.0.0.0', shiny.port=80); ctsApp::run_app()"]
