# Use a stable Java 17 runtime
FROM eclipse-temurin:17-jdk-jammy

# Create app directory
WORKDIR /app

# Copy the packaged jar produced by Maven
COPY target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

