FROM rocker/r-ver:4.3.0

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages(c('remotes', 'rJava'), repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_github('OHDSI/SqlRender')"
RUN Rscript -e "remotes::install_github('OHDSI/DatabaseConnector')"
RUN Rscript -e "remotes::install_github('OHDSI/ETL-Synthea')"

# Download PostgreSQL JDBC driver into the image
RUN mkdir -p /jdbc && \
    Rscript -e "DatabaseConnector::downloadJdbcDrivers('postgresql', pathToDriver='/jdbc')"

WORKDIR /etl
COPY run_etl.R .

ENTRYPOINT ["Rscript", "run_etl.R"]
