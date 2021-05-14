local_UID=$(id -u $USER)
local_GID=$(id -g $USER)

echo 'start'
sudo chown ${local_UID}:${local_GID} * -R
echo '======================'
sudo find . -name ".*" -print | xargs sudo chown ${local_UID}:${local_GID}
sudo chown ${local_UID}:${local_GID} .git -R
echo 'end'
