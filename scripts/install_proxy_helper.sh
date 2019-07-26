cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/sofa/"
sudo cp sysproxyconfig "/Library/Application Support/sofa/"
sudo chown root:admin "/Library/Application Support/sofa/sysproxyconfig"
sudo chmod +s "/Library/Application Support/sofa/sysproxyconfig"

echo done
