FROM wiremock/wiremock:3.3.1

USER root
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./wiremock/mappings /home/wiremock/mappings
COPY ./wiremock/__files /home/wiremock/__files
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ARG PORT=8085
ENV PORT=${PORT}
EXPOSE ${PORT}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--global-response-templating", "--port", "8085"]
