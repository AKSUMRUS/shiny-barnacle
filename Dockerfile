# build
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

COPY . .

RUN ./gradlew build -x test --no-daemon

# runtime
FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder /app/muffin-wallet-server/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT [ "java", "-jar", "/app/app.jar" ]