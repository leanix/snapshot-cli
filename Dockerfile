FROM openjdk:11.0.12-jdk

COPY snapshot-cli-installer.sh /
COPY snapshot-cli /

RUN apt-get update && \
    apt-get install postgresql-client-13 -y && \
    /snapshot-cli-installer.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*