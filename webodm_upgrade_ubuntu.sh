source venv/bin/activate
#djangorestframework djangorestframework-filters django-filter django-guardian djangorestframework-guardian tzlocal numpy drf-nested-routers

cd ../../..

cd /code
git pull origin master
python3 -m pip install -r requirements.txt -U
sudo bash configure.sh reinstall

cd /www
git checkout package.json
git pull origin master
npm install
python3 -m pip install -r requirements.txt -U

cd /webodm
git checkout package.json
git pull origin master
npm install
python3 -m pip install -r requirements.txt -U
webpack --mode production
python3 manage.py collectstatic --noinput
python3 manage.py migrate
bash app/scripts/plugin_cleanup.sh
echo "from app.plugins import build_plugins;build_plugins()" | python3 manage.py shell

sudo chown -R odm:odm /code /www /webodm /home/odm
