FROM amazoncorretto:25

RUN mkdir -p /app /app/cache/images

COPY ./target/newsku-*.jar  /app/newsku.jar

ADD ./docker/run.sh /run.sh

EXPOSE 8080

VOLUME ["/app/cache/images"]

RUN chmod +x /run.sh

CMD "./run.sh"

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
