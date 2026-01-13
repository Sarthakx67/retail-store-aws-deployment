FROM amazoncorretto:21
WORKDIR /app
COPY . .
RUN yum install -y \
    bash \
    tar \
    gzip \
    && chmod +x mvnw
ENV RETAIL_UI_DISABLE_DEMO_WARNINGS=true
ENV RETAIL_UI_ENDPOINTS_CATALOG=http://catalog:8080
ENV RETAIL_UI_ENDPOINTS_CARTS=http://cart:8080
ENV RETAIL_UI_ENDPOINTS_ORDERS=http://orders:8080
ENV RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout:8080
CMD ["./mvnw", "spring-boot:run"]