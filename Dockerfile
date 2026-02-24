FROM wiremock/wiremock:3.3.1

COPY --chown=wiremock:wiremock ./wiremock/mappings /home/wiremock/mappings
COPY --chown=wiremock:wiremock ./wiremock/__files /home/wiremock/__files

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

USER root
RUN apt update && \
    apt install -y curl \
USER wiremock

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--global-response-templating"]
