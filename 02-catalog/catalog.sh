# amazon linux setup
sudo yum install git -y
git clone https://github.com/aws-containers/retail-store-sample-app.git

# installing go lang for catalog
sudo yum install go -y

# Start the app in background
cd ./retail-store-sample-app/src/catalog/
go build -o main main.go > catalog-build.log 2>&1 &
./main > catalog.log 2>&1 &
