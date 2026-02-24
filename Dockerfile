FROM wiremock/wiremock:3.3.1

USER root
RUN apt update && \
    apt upgrade -y && \
    apt install curl -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./wiremock/mappings /home/wiremock/mappings
COPY ./wiremock/__files /home/wiremock/__files

EXPOSE 443

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--global-response-templating"]
