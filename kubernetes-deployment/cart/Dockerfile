FROM amazoncorretto:21
WORKDIR /app
COPY . .
RUN yum install -y \
    bash \
    tar \
    gzip \
    && chmod +x mvnw
CMD ["./mvnw", "spring-boot:run"]