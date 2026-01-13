# amazon linux setup
sudo yum install git -y
git clone https://github.com/aws-containers/retail-store-sample-app.git

# installing java 21 for ui
wget https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz
tar xvf openjdk-21_linux-x64_bin.tar.gz
sudo mv jdk-21/ /opt/jdk-21
sudo tee /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=/opt/jdk-21
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile.d/jdk.sh
java -version

# disable mock mode for ui 
cd ./retail-store-sample-app/src/ui/
export RETAIL_UI_DISABLE_DEMO_WARNINGS=true
export RETAIL_UI_ENDPOINTS_CATALOG=http://catalog.stallions.space:8080
export RETAIL_UI_ENDPOINTS_CARTS=http://cart.stallions.space:8080
export RETAIL_UI_ENDPOINTS_ORDERS=http://orders.stallions.space:8080
export RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout.stallions.space:8080

# Start the app in background
nohup ./mvnw spring-boot:run > ui.log 2>&1 &

