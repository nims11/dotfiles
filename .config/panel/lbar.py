#!/usr/bin/python2
"""
Bar generator
"""
from __future__ import print_function
import sys
import os
import traceback
import subprocess
import time
from collections import defaultdict
from threading import Thread
import psutil
import abc
import Xlib
import Xlib.display

reload(sys)
sys.setdefaultencoding('utf8')

CUR_DIR = os.path.dirname(os.path.abspath(__file__))

def read_config():
    """
    Reads config from Xresources
    a very dirty way to read xresources (no class, no xrdb)
    """
    config = {}
    try:
        xres = os.path.join(os.path.expanduser('~'), '.Xresources')
        with open(xres) as config_file:
            for line in config_file:
                line = [x.strip() for x in line.strip().split(':')]
                if len(line) == 2:
                    key, val = line
                    config[key] = val
    except IOError:
        traceback.print_exc()
    return config

CONFIG = read_config()
OPACITY = CONFIG.get('*.opacity', '#EE')[1:]
BG = '#'+OPACITY+CONFIG.get('*.background', '#141311')[1:]
FG = CONFIG.get('*.foreground', '#686766')
ALTFG = CONFIG.get('*.background', '#141311')
ALTBG = '#'+OPACITY+CONFIG.get('*.foreground', '#686766')[1:]
FONT1SIZE = CONFIG.get('lbar.fontsize', '9')
FONT2SIZE = int(FONT1SIZE) - 1
BARHEIGHT = CONFIG.get('lbar.height', '25')


# Weather settings
WEATHER_LOCATION = CONFIG.get('lbar.location','waterloo')
WEATHER_URL = 'http://rss.accuweather.com/rss/liveweather_rss.asp?locCode=%s&metric=1'\
    % WEATHER_LOCATION

# Window Widget
ACTIVE_WIN_MAX_LEN = 80

# Decorators
def schedule(time_in_seconds=None):
    def _scheduled(func):
        def _run():
            while True:
                try:
                    func()
                    time.sleep(time_in_seconds)
                except:
                    traceback.print_exc(file=sys.stderr)

        if time_in_seconds is not None:
            t = Thread(target=_run)
        else:
            t = Thread(target=func)
        t.setDaemon(True)
        t.start()
        return func
    return _scheduled

BRIGHTNESS_FILE_AVAILABLE = os.path.exists('/usr/bin/light')

# Power supply settings
for dir in ['/sys/class/power_supply/ACAD', '/sys/class/power_supply/AC']:
    if os.path.exists(os.path.join(dir, 'online')):
        AC_POWER_FILE = os.path.join(dir, 'online')
        break
else:
    AC_POWER_FILE = None

for dir in ['/sys/class/power_supply/BAT0']:
    if os.path.exists(os.path.join(dir, 'capacity')):
        BAT_CAP_FILE = os.path.join(dir, 'capacity')
        break
else:
    BAT_CAP_FILE = None

WIDGETS = defaultdict(str)
STATE = {}
temp_info_mode = False
temp_info_active = False
temp_info_item = None

ICONS = {
    'volume_high'       : u'\uF028',
    'volume_low'        : u'\uF027',
    'volume_mute'       : u'%%{F%s}\uF026%%{F-}' % CONFIG.get('*.color1', '#F44242'),
    'brightness_high'   : u'\uF0EB',
    'os'                : u'\uF17C',
    'weather'           : u'\uF2CB',
    'play'              : u'\uf04b',
    'pause'             : u'\uf04c',
    'next'              : u'\uf051',
    'prev'              : u'\uf048',
    'music'             : u'%{T2}\uf001%{T-}',
    'power'             : u'%{T2}\uf011%{T-}',
    'CPU'               : u'\uf0e4',
    'wallpaper'         : u'\uf108',
    'sync'              : u'\uf021',
    'battery-0'         : u'\uf244',
    'battery-1'         : u'\uf243',
    'battery-2'         : u'\uf242',
    'battery-3'         : u'\uf241',
    'battery-4'         : u'\uf240',
    'disk'              : u'\uf01c',
    'net'               : u'\uf1eb',
}

POWER_COMMANDS = {
    'Shutdown': 'systemctl poweroff',
    'Reboot': 'systemctl reboot',
    'Suspend': 'systemctl suspend',
    'Hibernate': 'systemctl hibernate',
    'Lock Screen': 'slimlock'
}

POWER_OPTIONS_ORDER = ['Shutdown', 'Reboot', 'Suspend', 'Hibernate', 'Lock Screen']

WIDGETS['brightness'] = '%%{A:redshift_toggle:}%%{A4:brightness_up:}%%{A5:brightness_down:}%%{A0:brightness_show:}%s%%{A}%%{A}%%{A}%%{A}' % ICONS['brightness_high']
WIDGETS['os_plain'] = '%%{A:update:}%%{A0:os_show:}%s%%{A}%%{A}' % ICONS['os']
WIDGETS['weather'] = '%%{A:weather_open:}%%{A0:weather_show:}%s%%{A}%%{A}' % ICONS['weather']
WIDGETS['power'] = '%%{A0:power_show:}%%{A3:power_next:}%%{A:power_select:}%s%%{A}%%{A}%%{A}' % (ICONS['power'])
WIDGETS['power_help'] = '[Power Options] Right Click To Navigate, Left Click To Select'
WIDGETS['cur_power_selection'] = ''
WIDGETS['wallpaper'] = '%%{A0:wallpaper_help:}%%{A:sel_wallpaper:}%%{A3:random_wallpaper:}%s%%{A}%%{A}%%{A}' % ICONS['wallpaper']
WIDGETS['wallpaper_help'] = 'Select Wallpaper [left click] / Random Wallpaper [right click]'

#### Helpers ####
def progress(val, tot=100, bars=40, name=''):
    progress = (u'\u2588'*(bars*val//tot)) + (' '*(bars-bars*val//tot))
    return u'%s \uf053 %s \uf054 %d/%d' % (name, progress, val, tot)

#### Scheduled function ####
class Main(object):
    @staticmethod
    def start_bar(command):
        """
        Starts lemonbar and returns the handler
        """
        return subprocess.Popen(
            command,
            shell=True,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE)

    def __init__(self, panel_str, command):
        self.panel_str = panel_str
        self.BAR_PROC = Main.start_bar(command)
        self.right_widgets = ['weather', 'os', 'wallpaper', 'brightness', 'volume', 'power']
        if not BRIGHTNESS_FILE_AVAILABLE:
            self.right_widgets.remove('brightness')

    def redraw(self):
        info_panel_item = WIDGETS['sys_stat']
        if temp_info_active:
            info_panel_item = WIDGETS.get(temp_info_item, '')
        panel_str = self.panel_str % (
            BG,
            WIDGETS['wname'].decode('utf8', 'ignore'),
            info_panel_item,
            WIDGETS['music'],
            ' '.join(WIDGETS[x] for x in self.right_widgets),
            WIDGETS['clock']
        )
        self.BAR_PROC.stdin.write(panel_str.encode('utf-8'))
        self.BAR_PROC.stdin.flush()

# class Widget(object):
#     __metaclass__ = abc.ABCMeta

#     def __init__(self, update_time=None):
#         try:
#             self.init()
#             schedule(update_time)(self.update)
#         except:
#             traceback.print_exc()

#     @abc.abstractmethod
#     def init(self):
#         return

#     @abc.abstractmethod
#     def update(self):
#         return

COMMAND = 'lemonbar -B%s -F%s -a 30 -b -g x%s -f "Ubuntu Mono-%s" -f "FontAwesome-%s" -f "Source Han Sans JP-8"' \
    % (BG, FG, BARHEIGHT, FONT1SIZE, FONT2SIZE)

main = Main(
    panel_str=u'%%{B%s}%%{l} %s %%{c} %s %%{r} %%{R}%s%%{R}  %s  %%{R} %s %%{R}\n',
    command=COMMAND
)

def clock():
    global WIDGETS
    WIDGETS['clock'] = b'%%{A0:date_show:}%%{A:calendar:}%s%%{A}%%{A}' % time.strftime('%H:%M:%S').encode()

def human_friendly(bytes):
    units = 'BKMG'
    for unit in units:
        if bytes < 100:
            return '%4.1f %s/s' % (bytes, unit)
        bytes /= 1024.0
    return '%4.1f %s/s' % (bytes, unit)

def set_sys_stat(interval=1):
    vmem = psutil.virtual_memory()
    io_data = psutil.disk_io_counters()
    io_bytes = io_data.write_bytes + io_data.read_bytes
    io_rate = (io_bytes - WIDGETS.get('io_bytes', 0))/float(interval)
    WIDGETS['io_bytes'] = io_bytes

    nw_data = psutil.net_io_counters()
    nw_bytes = nw_data.bytes_sent + nw_data.bytes_recv
    nw_rate = (nw_bytes - WIDGETS.get('nw_bytes', 0))/float(interval)
    WIDGETS['nw_bytes'] = nw_bytes
    WIDGETS['sys_stat'] = '%%{A:system_status:}%s %2.0f%% %.2fGB  %s %s  %s %s%%{A}' % (
        ICONS['CPU'], psutil.cpu_percent(), vmem.used / float(2**30),
        ICONS['disk'], human_friendly(io_rate),
        ICONS['net'], human_friendly(nw_rate)
    )
    if AC_POWER_FILE != None or BAT_CAP_FILE != None:
        WIDGETS['sys_stat'] += '  %%{F%s}%s%%{F-} %s' % (
            CONFIG.get('*.color2', '#0F0') if WIDGETS.get('ac_power', True) else CONFIG.get('*.color1', '#F00'),
            WIDGETS.get('battery-icon', ICONS['battery-0']),
            str(WIDGETS.get('battery', ''))
        )

def get_music_status():
    """
    Assumes mpd is running and mpc is installed
    """
    try:
        cmd = "mpc | awk 'NR==1{print $0} NR==2{print $1}'"
        out = subprocess.check_output(cmd, shell=True).split('\n')
        if len(out) < 3:
            raise Exception("stopped")
        cur_playing, status = out[:2]
    except:
        cur_playing = 'Not Playing'
        status = '[stopped]'
    status = 0 if status == '[playing]' else 1
    return status, cur_playing

def mpc_loop():
    while True:
        status, cur_playing = get_music_status()
        WIDGETS['music'] = '%%{A0:music_show:}%%{A:music_open:}  %s  %%{A}%%{A:music_prev:} %s %%{A} %%{A:music_toggle:} %s %%{A} %%{A:music_next:} %s %%{A} %%{A}' % (ICONS['music'], ICONS['prev'], ICONS['play'] if status != 0 else ICONS['pause'], ICONS['next'])
        if cur_playing != WIDGETS['cur_playing']:
            WIDGETS['cur_playing'] = cur_playing
            activate_temp_info('cur_playing')
        subprocess.check_output('mpc idle player', shell=True)

def set_volume_info():
    global WIDGETS
    cur_volume = int(subprocess.check_output('amixer get Master | awk -F"[][]" \'/[.*?%]/{print $2}\' | head -1', shell=True).strip()[:-1])
    cur_icon = ICONS['volume_high']
    if cur_volume == 0:
        cur_icon = ICONS['volume_mute']
    elif cur_volume < 50:
        cur_icon = ICONS['volume_low']
    WIDGETS['volume'] = '%%{A:volume_more:}%%{A4:volume_up:}%%{A5:volume_down:}%%{A0:volume_show:}%s%%{A}%%{A}%%{A}%%{A}' % cur_icon
    WIDGETS['volume_bar'] = progress(cur_volume, name='[Volume]')

def set_ac_power():
    global WIDGETS
    with open(AC_POWER_FILE) as f:
        WIDGETS['ac_power'] = f.read().strip() != '0'

def set_brightness_info():
    global WIDGETS
    brightness_val = int(float(subprocess.check_output(['light']).strip()))
    STATE['brightness'] = brightness_val
    WIDGETS['brightness_bar'] = progress(brightness_val, tot=100, name='[Brightness]')

def set_os_info():
    global WIDGETS
    os_version = subprocess.check_output('uname -sr', shell=True).strip()
    update_count = int(subprocess.check_output('pacman -Qu | wc -l', shell=True).strip())
    WIDGETS['os_info'] = '%s - %s Updates available' % (os_version, update_count)
    if update_count > 0:
        WIDGETS['os'] = '%%{F%s}%s%%{F-}' % (CONFIG.get('*.color2', '#8E7'), WIDGETS['os_plain'])
    else:
        WIDGETS['os'] = WIDGETS['os_plain']

def set_weather_info():
    WIDGETS['weather_bar'] = '[Weather] ' + subprocess.check_output("curl --connect-timeout 15 -s '%s' | grep '<title>Currently' | sed -E 's/<.?title>//g' | sed 's/Currently://' | xargs" % WEATHER_URL, shell=True).strip()

def set_bat_cap():
    global WIDGETS
    with open(BAT_CAP_FILE) as f:
        WIDGETS['battery'] = int(f.read().strip())
        cap = WIDGETS['battery']
        if cap <= 10:
            WIDGETS['battery-icon'] = ICONS['battery-0']
        elif 10 < cap < 40:
            WIDGETS['battery-icon'] = ICONS['battery-1']
        elif 40 <= cap < 65:
            WIDGETS['battery-icon'] = ICONS['battery-2']
        elif 65 <= cap < 90:
            WIDGETS['battery-icon'] = ICONS['battery-3']
        elif cap >= 90:
            WIDGETS['battery-icon'] = ICONS['battery-4']

def wname_loop():
    """
    https://gist.github.com/ssokolow/e7c9aae63fb7973e4d64cff969a78ae8
    """
    global WIDGETS
    disp = Xlib.display.Display()
    root = disp.screen().root
    root.change_attributes(event_mask=Xlib.X.PropertyChangeMask)
    NET_ACTIVE_WINDOW = disp.intern_atom('_NET_ACTIVE_WINDOW')
    NET_WM_NAME = disp.intern_atom('_NET_WM_NAME')
    WM_NAME = disp.intern_atom('WM_NAME')
    last_seen = {'xid': None}
    
    def get_window_obj(win_id):
        try:
            return disp.create_resource_object('window', win_id)
        except Xlib.error.XError:
            return None


    def get_active_window():
        window_id = root.get_full_property(NET_ACTIVE_WINDOW,
                                           Xlib.X.AnyPropertyType).value[0]

        focus_changed = (window_id != last_seen['xid'])

        if focus_changed:
            if last_seen['xid'] != None:
                old_win = get_window_obj(last_seen['xid'])
                if old_win != None:
                    old_win.change_attributes(event_mask=Xlib.X.NoEventMask)
            last_seen['xid'] = window_id
            new_win = get_window_obj(window_id)
            if new_win != None:
                new_win.change_attributes(event_mask=Xlib.X.PropertyChangeMask)

        return window_id, focus_changed


    def get_window_name(window_id):
        try:
            window_obj = get_window_obj(window_id)
            window_name = window_obj.get_full_property(NET_WM_NAME, 0).value
        except AttributeError:
            window_name = ''

        return window_name


    root.change_attributes(event_mask=Xlib.X.PropertyChangeMask)
    while True:
        try:
            win, changed = get_active_window()
            active_window = get_window_name(win)
        except Xlib.error.BadWindow:
            active_window = ''
        if len(active_window) > ACTIVE_WIN_MAX_LEN:
            active_window = active_window[:ACTIVE_WIN_MAX_LEN] + '...'
        prev = WIDGETS['wname']
        WIDGETS['wname'] = '%%{A:window_switcher:}%s%%{A}' % (active_window)
        if prev != WIDGETS['wname']:
            main.redraw()

        while True:
            event = disp.next_event()
            if (event.type == Xlib.X.PropertyNotify and
                    event.atom in (NET_ACTIVE_WINDOW, NET_WM_NAME, WM_NAME)):
                break


@schedule(1)
def high_priority_jobs():
    clock()
    main.redraw()

def setup_monitors():
    t = Thread(target=mpc_loop)
    t.setDaemon(True)
    t.start()

    t = Thread(target=wname_loop)
    t.setDaemon(True)
    t.start()

setup_monitors()

@schedule(2)
def medium_priority_jobs():
    set_sys_stat(2)
    set_volume_info()
    if AC_POWER_FILE != None:
        set_ac_power()

@schedule(10)
def low_priority_jobs():
    if BAT_CAP_FILE != None:
        set_bat_cap()

@schedule(600)
def shit_priority_jobs():
    set_os_info()
    set_weather_info()
    subprocess.call("sudo pacman_update_list", shell=True)

def music_toggle():
    subprocess.Popen('mpc toggle >/dev/null', shell=True)

def music_next():
    subprocess.Popen('mpc next >/dev/null', shell=True)

def music_prev():
    subprocess.Popen('mpc prev >/dev/null', shell=True)

def activate_temp_info(name):
    global temp_info_active, temp_info_mode, temp_info_item
    temp_info_active = True
    temp_info_mode = True
    temp_info_item = name
    main.redraw()

@schedule(None)
def temp_info_counter():
    global temp_info_active, temp_info_mode
    counter = 0
    while True:
        if temp_info_mode:
            counter = 1
            temp_info_active = True
            temp_info_mode = False
        elif counter > 0:
            counter -= 1

        if counter == 0:
            temp_info_active = False
        time.sleep(1)


### Actions  ###
def volume_up():
    subprocess.call('amixer -D pulse sset Master 3%+', shell=True)
def volume_down():
    subprocess.call('amixer -D pulse sset Master 3%-', shell=True)

def brightness_up():
    subprocess.call('light -A 10', shell=True)

def brightness_down():
    subprocess.call('light -U 10', shell=True)

def redshift_toggle():
    subprocess.call('~/scripts/toggle_redshift.sh', shell=True)

def update_packages():
    subprocess.call("urxvt -e bash -c \"sudo pacman -Syu; echo Press any key to continue... && read -n 1\"", shell=True)
    set_os_info()

@schedule(None)
def perform_action():
    global temp_info_mode
    while True:
        action = main.BAR_PROC.stdout.readline().strip()
        if action == 'calendar':
            subprocess.Popen('gsimplecal')
        elif action == 'volume_show':
            set_volume_info()
            activate_temp_info('volume_bar')
        elif action == 'volume_up':
            volume_up()
            set_volume_info()
            activate_temp_info('volume_bar')
            main.redraw()
        elif action == 'volume_down':
            volume_down()
            set_volume_info()
            activate_temp_info('volume_bar')
            main.redraw()
        elif action == 'volume_more':
            subprocess.Popen('pavucontrol')
        elif action == 'brightness_show':
            set_brightness_info()
            activate_temp_info('brightness_bar')
        elif action == 'brightness_up':
            brightness_up()
            set_brightness_info()
            activate_temp_info('brightness_bar')
            main.redraw()
        elif action == 'brightness_down':
            brightness_down()
            set_brightness_info()
            activate_temp_info('brightness_bar')
            main.redraw()
        elif action == 'redshift_toggle':
            redshift_toggle()
        elif action == 'os_show':
            activate_temp_info('os_info')
        elif action == 'update':
            Thread(target=update_packages).start()
        elif action == 'window_switcher':
            subprocess.Popen('rofi -show window', shell=True)
        elif action == 'weather_show':
            activate_temp_info('weather_bar')
        elif action == 'weather_open':
            subprocess.Popen('urxvt -e bash -c \'curl wttr.in && read -n 1\'', shell=True)
        elif action == 'system_status':
            subprocess.Popen('urxvt -e htop', shell=True)
        elif action == 'music_open':
            subprocess.Popen('urxvt -e ncmpcpp', shell=True)
        elif action == 'power_show':
            if not temp_info_active or temp_info_item != 'cur_power_selection':
                WIDGETS['cur_power_selection'] = WIDGETS['power_help']
            activate_temp_info('cur_power_selection')
        elif action == 'power_next':
            cur_selection = WIDGETS['cur_power_selection']
            cur_idx = POWER_OPTIONS_ORDER.index(cur_selection) \
                if cur_selection in POWER_OPTIONS_ORDER else -1
            next_idx = (cur_idx + 1) % len(POWER_OPTIONS_ORDER)
            WIDGETS['cur_power_selection'] = POWER_OPTIONS_ORDER[next_idx]
            activate_temp_info('cur_power_selection')
            main.redraw()
        elif action == 'power_select':
            if temp_info_active and temp_info_item == 'cur_power_selection' and WIDGETS['cur_power_selection'] in POWER_COMMANDS:
                subprocess.Popen(POWER_COMMANDS[WIDGETS['cur_power_selection']], shell=True)
        elif action == 'date_show':
            WIDGETS['date_info'] = time.strftime('%A, %d %B %Y')
            activate_temp_info('date_info')
        elif action == 'music_show':
            activate_temp_info('cur_playing')
        elif action == 'music_toggle':
            music_toggle()
        elif action == 'music_prev':
            music_prev()
        elif action == 'music_next':
            music_next()
        elif action == 'wallpaper_help':
            activate_temp_info('wallpaper_help')
        elif action == 'sel_wallpaper':
            subprocess.Popen('bash ~/wallpaper.sh select', shell=True)
        elif action == 'random_wallpaper':
            subprocess.Popen('bash ~/wallpaper.sh', shell=True)


try:
    while True:
        time.sleep(0.1)
except KeyboardInterrupt:
    print("Keyboard Interrupt Detected. Exiting...")
    sys.exit(0)
