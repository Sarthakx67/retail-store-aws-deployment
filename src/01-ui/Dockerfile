FROM amazoncorretto:21-alpine-jdk
COPY . .
WORKDIR /app
RUN export RETAIL_UI_DISABLE_DEMO_WARNINGS=true
RUN export RETAIL_UI_ENDPOINTS_CATALOG=http://catalog.stallions.space:8080
RUN export RETAIL_UI_ENDPOINTS_CARTS=http://cart.stallions.space:8080
RUN export RETAIL_UI_ENDPOINTS_ORDERS=http://orders.stallions.space:8080
RUN export RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout.stallions.space:8080
CMD ["/app/mvnw", "spring-boot:run"]   