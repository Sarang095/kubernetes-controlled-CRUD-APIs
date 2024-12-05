FROM openjdk:17-alpine as build
RUN apk update && apk add --no-cache bash
COPY target/crud-v1.jar /app/crud-v1.jar


FROM aquasec/trivy:latest as vulnscan
COPY --from=build /app /app
RUN trivy rootfs --no-progress --exit-code 1 /app


FROM openjdk:17-alpine as runtime
RUN adduser -D -g 'app' app
WORKDIR /app
COPY --from=build /app/crud-v1.jar /app/crud-v1.jar
EXPOSE 8080
RUN chown app:app crud-v1.jar
USER app
ENTRYPOINT ["java", "-jar", "crud-v1.jar"]

