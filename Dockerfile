FROM openjdk:11-jre-slim
RUN mkdir -p /app
COPY target/micro-service-0.0.1-SNAPSHOT.jar  /app/microservice-template.jar
RUN groupadd -g 10001 vcare && useradd -g vcare -u 10001 vcare
RUN chown -R tmp:tmp /app && chown -R tmp:tmp /var
USER tmp
EXPOSE 9093
ENTRYPOINT ["/usr/local/openjdk-11/bin/java"]
CMD ["-jar", "/app/microservice-template.jar"]
