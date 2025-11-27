FROM amazoncorretto:21

RUN mkdir /app


COPY ./target/newsku-*.jar  /app/newsku.jar

ADD ./docker/run.sh /run.sh

EXPOSE 8080

RUN chmod +x /run.sh

CMD "./run.sh"
