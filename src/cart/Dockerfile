# =========================================================
# Stage 1: Build -> Heavy (Maven, source code, dependencies)
# =========================================================
FROM maven:3.9.9-amazoncorretto-21 AS build

WORKDIR /app

# Copy only dependency files first (CACHE KEY)
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
# If source code changes, but pom.xml does not:
# Docker reuses cached dependency layer
# Build is MUCH faster
RUN chmod +x mvnw  
# mvnw is a shell script

# Download dependencies (cached layer)
RUN ./mvnw -B dependency:go-offline

# What it does

# Downloads ALL dependencies Stores them in Maven cache -B → batch mode (no interactive prompts)
# Why it’s smart Happens before source code and Cached unless pom.xml changes
# Massive speed-up for rebuilds

# Copy source code
COPY src ./src

# Build JAR
RUN ./mvnw -B package -DskipTests

# NOTE :
    # now What happens here
    # Compiles code
    # Runs packaging phase
    # Produces: 
    # /app/target/your-app-name.jar



# =========================
# Stage 2: Runtime -> Light (only Java + JAR)
# =========================
FROM amazoncorretto:21

WORKDIR /app

# Copy only the built JAR
COPY --from=build /app/target/*.jar app.jar

# Exactly what happens :
# Takes the JAR built in Stage 1
# Copies it into Stage 2
# Renames it to app.jar


EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
