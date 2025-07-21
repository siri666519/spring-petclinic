FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/spring-petclinic-*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
