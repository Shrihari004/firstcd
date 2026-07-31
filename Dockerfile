# =========================
# Build stage
# =========================
FROM eclipse-temurin:25-jdk AS build

WORKDIR /app

# Copy build files first (better Docker cache)
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
COPY mvnw .
COPY .mvn .mvn

RUN chmod +x ./mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline

# Copy source
COPY src src

# Build Spring Boot jar
RUN ./mvnw clean package -DskipTests


# =========================
# Runtime stage
# =========================
FROM eclipse-temurin:25-jre

WORKDIR /app

# Copy generated jar
COPY --from=build /app/target/*.jar app.jar


# Expose Spring Boot default port
EXPOSE 8081

# JVM options can be overridden at runtime
ENV JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]