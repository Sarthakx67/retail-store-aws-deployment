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
export RETAIL_UI_ENDPOINTS_CATALOG=http://13.233.132.213:8080
export RETAIL_UI_ENDPOINTS_CARTS=http://13.203.199.40:8080
export RETAIL_UI_ENDPOINTS_ORDERS=http://43.204.107.73:8080
export RETAIL_UI_ENDPOINTS_CHECKOUT=http://3.108.42.165:8080

# Start the app in background
nohup ./mvnw spring-boot:run > ui.log 2>&1 &

