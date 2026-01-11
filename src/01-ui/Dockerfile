FROM amazoncorretto:21
WORKDIR /app
COPY . .
RUN yum install -y bash \
    && chmod +x mvnw
ENV RETAIL_UI_DISABLE_DEMO_WARNINGS=true
ENV RETAIL_UI_ENDPOINTS_CATALOG=http://catalog.stallions.space:8080
ENV RETAIL_UI_ENDPOINTS_CARTS=http://cart.stallions.space:8080
ENV RETAIL_UI_ENDPOINTS_ORDERS=http://orders.stallions.space:8080
ENV RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout.stallions.space:8080
CMD ["./mvnw", "spring-boot:run"]