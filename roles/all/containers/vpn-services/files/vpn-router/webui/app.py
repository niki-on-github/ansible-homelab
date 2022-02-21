#!bin/python
import random
import string
import os

from lib.dnsleaktest import run_dnsleaktest

from flask import Flask, request, redirect, url_for, render_template, Response
from flask_wtf import FlaskForm
from flask_bootstrap import Bootstrap
from wtforms import SubmitField, BooleanField, StringField, IntegerField, validators
from functools import wraps

CONFIG_FILE='/config.sh'
USER = os.environ.get('WEBUI_USER', 'admin') # default usr is 'admin'
PASSWORD = os.environ.get('WEBUI_PASSWORD', 'Geheim') # default pw is 'Geheim'

app = Flask(__name__)
app.config.from_mapping(
    SECRET_KEY=''.join(random.choices(string.ascii_uppercase + string.digits, k=64)),
    SEND_FILE_MAX_AGE_DEFAULT=0)
Bootstrap(app)

class SettingsForm(FlaskForm):
    LOWER_THRESHOLD = IntegerField('Lower Threshold (Bytes)', [validators.DataRequired()])
    UPPER_THRESHOLD = IntegerField('Upper Threshold (Bytes)', [validators.DataRequired()])
    RECONNECT_THRESHOLD_SEC = IntegerField('Reconnect Threshold (Seconds)', [validators.DataRequired()])
    UPDATE_INTERVAL_SEC = IntegerField('Update Interval (Seconds)', [validators.DataRequired()])
    RECONNECT_ENABLED = BooleanField('Enable Lowspeed Reconnect')
    EXCLUDE_START_H = IntegerField('Begin Exclude Time Slot (Hour)', [validators.DataRequired()])
    EXCLUDE_END_H = IntegerField('End Exclude Time Slot (Hour)', [validators.DataRequired()])
    submit = SubmitField('Save')

def read_config():
    config = dict()
    if not os.path.exists(CONFIG_FILE): return
    with open(CONFIG_FILE, 'r') as config_file:
        for line in config_file.readlines():
            if '=' in line: config[line.split('=')[0]] = line.split('=')[1].replace('\n', '')
    return config

def save_config(request):
    with open(CONFIG_FILE, 'w') as config_file:
        for key in request.form.keys():
            if key == 'csrf_token': continue
            if key == 'RECONNECT_ENABLED':
                config_file.write('RECONNECT_ENABLED=true\n')
                continue
            config_file.write(str(key)+'='+str(request.form[key]+'\n'))
        if 'RECONNECT_ENABLED' not in request.form.keys():
            config_file.write('RECONNECT_ENABLED=false\n')

def update_default_values(form):
    config = read_config()
    for key in config.keys():
        field = getattr(form, key)
        value = config[key]
        if key == 'RECONNECT_ENABLED':
            setattr (field, "default", 'checked' if value=='true' else '')
        else:
            setattr (field, "default", value)
        form.process ()

def html(content):
   return '<html><head></head><body>' + content + '</body></html>'

def check_auth(username, password):
    """This function is called to check if a username password combination is valid.
    """
    return username == USER and password == PASSWORD

def authenticate():
    """Sends a 401 response that enables basic auth"""
    return Response(
    'Could not verify your access level for that URL.\n'
    'You have to login with proper credentials', 401,
    {'WWW-Authenticate': 'Basic realm="Login Required"'})

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/', methods=['GET', 'POST'])
@requires_auth
def settings():
    form = SettingsForm(request.form)
    if request.method == 'POST' and form.validate_on_submit():
        save_config(request)
        return redirect(url_for('settings'))

    update_default_values(form)
    return render_template('settings.html', form=form)

@app.route('/dnsleaktest', methods=['GET'])
@requires_auth
def dnsleaktest():
    return html(run_dnsleaktest())

@app.route('/reconnect', methods=['GET'])
@requires_auth
def reconnect():
    os.system('pkill openvpn')
    return html('reconnect ... ok')

if __name__ == '__main__':
    app.run()
