FROM wiremock/wiremock:3.3.1

COPY --chown=wiremock:wiremock ./wiremock/mappings /home/wiremock/mappings
COPY --chown=wiremock:wiremock ./wiremock/__files /home/wiremock/__files

EXPOSE 443

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

RUN apt update && \
    apt upgrade -y && \
    apt install curl -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--global-response-templating"]
