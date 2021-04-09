FROM openjdk:11-jre-slim
RUN mkdir -p /app
COPY target/my-app-1.0-SNAPSHOT.jar /app/my-app-1.0-SNAPSHOT.jar
RUN groupadd -g 10001 myusr && useradd -g myusr -u 10001 myusr
RUN chown -R myusr:myusr /app && chown -R myusr:myusr /var
USER myusr
EXPOSE 9093
ENTRYPOINT ["/usr/local/openjdk-11/bin/java"]
CMD ["-jar", "/app/my-app-1.0-SNAPSHOT.jar"]
