FROM amazoncorretto:21
WORKDIR /app
COPY . .
RUN yum install -y \
    bash \
    tar \
    gzip \
    go \
RUN go build -o main main.go
CMD [ "./main" ]