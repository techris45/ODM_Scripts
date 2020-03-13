#Make sure repositories are as needed
 cp -p -f /dev/null /etc/apk/repositories
echo http://dl-cdn.alpinelinux.org/alpine/edge/main > /etc/apk/repositories
echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

#Update Alpine Linux & add packages
apk update && apk upgrade
apk add git sudo npm python3 py3-virtualenv py3-setuptools py3-pip py3-wheel

#Create folder structure in root of volume for *ODM Components
mkdir ../code && mkdir ../webodm && mkdir ../www

#Change to root of volume
cd ../

#Clone & pull ODM
cd /code
git clone https://github.com/OpenDroneMap/ODM .
git pull origin master
sudo ash configure.sh reinstall

#Clone & pull WODM
cd /webodm
git clone https://github.com/OpenDroneMap/WebODM .
git checkout package.json
git pull origin master

#Clone & pull NODM
cd /www
git clone https://github.com/OpenDroneMap/NodeODM .
git checkout package.json
git pull origin master
npm install

#
source virtualenv /bin/activate
npm install
python3 -m pip install -r requirements.txt
webpack --mode production
python3 manage.py collectstatic --noinput
python3 manage.py migrate
ash app/scripts/plugin_cleanup.sh
echo “from app.plugins import build_plugins;build_plugins()” | python3 manage.py shell

#
sudo chown -R odm:odm /code /www /webodm /home/odm