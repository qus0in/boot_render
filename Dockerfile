# Stage 1: Build the application
FROM gradle:7.6.1-jdk17 AS build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src src
RUN gradle build --no-daemon -x test

# Stage 2: Create the final Docker image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
EXPOSE 8080