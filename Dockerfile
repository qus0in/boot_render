# Build stage
FROM gradle:7.6.1-jdk17 AS build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src ./src
RUN ls -la
RUN gradle build --no-daemon -x test
RUN echo "Content of /app directory:" && ls -la /app
RUN echo "Content of /app/build directory:" && ls -la /app/build
RUN echo "Content of /app/build/libs directory:" && ls -la /app/build/libs

# Run stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN apk add --no-cache bash
COPY --from=build /app/build/libs /app/libs
RUN echo "Content of /app/libs directory:" && ls -la /app/libs
RUN bash -c 'cp /app/libs/$(ls -t /app/libs/*.jar | grep -v plain | head -1) app.jar'
RUN echo "Content of /app directory after copying JAR:" && ls -la /app
RUN ls -l app.jar || (echo "Executable JAR file not found" && exit 1)
RUN echo "JAR file details:" && ls -l app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]