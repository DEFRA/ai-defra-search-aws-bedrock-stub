FROM wiremock/wiremock:3.3.1

COPY --chown=wiremock:wiremock ./wiremock/mappings /home/wiremock/mappings
COPY --chown=wiremock:wiremock ./wiremock/__files /home/wiremock/__files

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--verbose", "--global-response-templating"]
