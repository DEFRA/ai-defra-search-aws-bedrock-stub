FROM wiremock/wiremock:3.3.1

COPY --chown=wiremock:wiremock ./wiremock/mappings /home/wiremock/mappings
COPY --chown=wiremock:wiremock ./wiremock/__files /home/wiremock/__files

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

RUN apt-get update && apt-get install -y curl

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--global-response-templating"]
