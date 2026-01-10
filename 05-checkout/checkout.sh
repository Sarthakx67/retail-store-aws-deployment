# amazon linux setup
sudo yum install git -y
git clone https://github.com/aws-containers/retail-store-sample-app.git

#installing nodejs 16 for checkout --> t2.medium
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
sudo npm install -g yarn

# Start the checkout server
cd ./retail-store-sample-app/src/checkout/
yarn install
yarn serve:dev


