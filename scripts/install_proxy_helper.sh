cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/Pangolin/"
sudo cp sysproxyconfig "/Library/Application Support/Pangolin/"
sudo chown root:admin "/Library/Application Support/Pangolin/sysproxyconfig"
sudo chmod +s "/Library/Application Support/Pangolin/sysproxyconfig"

echo done
