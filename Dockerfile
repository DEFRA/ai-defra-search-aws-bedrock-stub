FROM wiremock/wiremock:3.3.1

COPY --chown=wiremock:wiremock ./wiremock/mappings /home/wiremock/mappings
COPY --chown=wiremock:wiremock ./wiremock/__files /home/wiremock/__files

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--verbose", "--global-response-templating"]
