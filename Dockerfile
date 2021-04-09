FROM openjdk:11-jre-slim
RUN mkdir -p /app
COPY target/my-app-1.0-SNAPSHOT.jar /app/my-app-1.0-SNAPSHOT.jar
RUN groupadd -g 10001 vcare && useradd -g vcare -u 10001 vcare
RUN chown -R tmp:tmp /app && chown -R tmp:tmp /var
USER tmp
EXPOSE 9093
ENTRYPOINT ["/usr/local/openjdk-11/bin/java"]
CMD ["-jar", "/app/my-app-1.0-SNAPSHOT.jar"]
