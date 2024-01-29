FROM rocker/shiny:4.3.2

RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    openjdk-18-jdk-headless \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R CMD javareconf
RUN mkdir -p /opt/drivers && \
    echo "DATABASECONNECTOR_JAR_FOLDER = '/opt/drivers'" >> /usr/local/lib/R/etc/Renviron
RUN R -e "install.packages(c('rJava', 'SqlRender', 'remotes', 'ParallelLogger'))"
RUN R -e "remotes::install_github(c('OHDSI/DataQualityDashboard@v2.5.0', 'OHDSI/DatabaseConnector'))" && \
    R -e "library(DatabaseConnector); downloadJdbcDrivers('postgresql')"

COPY dqd-run.R /opt/app/dqd-run.R
USER shiny
RUN mkdir -p /tmp/output
WORKDIR /opt/app

CMD ["Rscript", "dqd-run.R"]
