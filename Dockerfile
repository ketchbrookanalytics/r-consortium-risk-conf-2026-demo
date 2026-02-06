FROM rocker/verse:4.5.2

# Install {pak}
RUN R -q -e "install.packages('pak')"

# Define the version of {renv} we want to use, and ensure we use {pak} on the
# backend to install the packages in the lock file
ARG RENV_VERSION=1.1.7
ENV RENV_CONFIG_PAK_ENABLED=true

# Install {renv}
RUN R -q -e "pak::pkg_install('renv@${RENV_VERSION}')"

# Add local files and folders needed to generate the report
COPY assets/         assets/
COPY qmd/            qmd/
COPY _quarto.yml    _quarto.yml
COPY _targets.R     _targets.R
COPY R/              R/
COPY references.bib references.bib
COPY renv.lock      renv.lock
COPY report.qmd     report.qmd

# Install the R packages in the lock file
# This should use {pak} and install system packages, too
RUN R -q -e "renv::restore()"

# Debug // Check current user
RUN whoami

# Install Chrome
RUN apt-get update && apt-get install --no-install-recommends -y \
    wget \
    gnupg2 \
  && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
     > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install --no-install-recommends -y \
    google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

# Install Quarto
ARG QUARTO_VERSION=1.8.27
RUN wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
  && dpkg -i "quarto-${QUARTO_VERSION}-linux-amd64.deb" \
  && rm "quarto-${QUARTO_VERSION}-linux-amd64.deb"