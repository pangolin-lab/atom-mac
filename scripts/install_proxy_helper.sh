cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/proton/"
sudo cp sysproxyconfig "/Library/Application Support/proton/"
sudo chown root:admin "/Library/Application Support/proton/sysproxyconfig"
sudo chmod +s "/Library/Application Support/proton/sysproxyconfig"

echo done
