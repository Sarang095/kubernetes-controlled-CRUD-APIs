# Stage 1: Build stage (build environment)
FROM openjdk:17-alpine as build

# Install bash for compatibility (if necessary for any subsequent operations)
RUN apk update && apk add --no-cache bash

# Copy the JAR file into the container (in the build stage)
COPY target/crud-v1.jar /app/crud-v1.jar

# Stage 2: Vulnerability scanning stage (Trivy)
FROM aquasec/trivy:latest as vulnscan

# Perform a root filesystem scan for vulnerabilities
COPY --from=build /app /app
RUN trivy rootfs --no-progress --exit-code 1 /app

# Stage 3: Final runtime stage (smaller image, production-ready)
FROM openjdk:17-alpine as runtime

# Create a non-root user with the least privilege
RUN adduser -D -g 'app' app

# Set the working directory to /app, only for runtime
WORKDIR /app

# Copy the application artifact (JAR) from the build stage into the runtime image
COPY --from=build /app/crud-v1.jar /app/crud-v1.jar

# Expose the application port (8080)
EXPOSE 8080

# Change ownership of the application to the non-root user (POLP principle)
RUN chown app:app crud-v1.jar

# Switch to a non-root user with the least privileges (POLP principle)
USER app

# Entry point to run the application
ENTRYPOINT ["java", "-jar", "crud-v1.jar"]

