# =========================
# Stage 1: Build
# =========================
FROM maven:3.9.9-amazoncorretto-21 AS build

WORKDIR /app

# Copy only dependency files first (CACHE KEY)
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

RUN chmod +x mvnw

# Download dependencies (cached layer)
RUN ./mvnw -B dependency:go-offline

# Copy source code
COPY src ./src

# Build JAR
RUN ./mvnw -B package -DskipTests

# =========================
# Stage 2: Runtime
# =========================
FROM amazoncorretto:21

WORKDIR /app

# Copy only the built JAR
COPY --from=build /app/target/*.jar app.jar
ENV RETAIL_UI_DISABLE_DEMO_WARNINGS=true
ENV RETAIL_UI_ENDPOINTS_CATALOG=http://catalog:8080
ENV RETAIL_UI_ENDPOINTS_CARTS=http://cart:8080
ENV RETAIL_UI_ENDPOINTS_ORDERS=http://orders:8080
ENV RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout:8080

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
