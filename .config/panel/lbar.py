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
import wnck
import gtk
import psutil

CUR_DIR = os.path.dirname(os.path.abspath(__file__))

def read_config():
    """
    Reads config from ~/.config/colorscheme.config
    """
    config = {}
    try:
        color_config = os.path.join(os.path.expanduser('~'), '.config/colorscheme.config')
        with open(color_config) as config_file:
            for line in config_file:
                key, val = [x.strip().strip('"\'') for x in line.strip().split('=')]
                config[key] = val
    except IOError:
        traceback.print_exc()
    return config

def start_bar(BG, FG):
    """
    Starts lemonbar and returns the handler
    """
    return subprocess.Popen(
        'lemonbar -B%s -F%s -a 30 -b -g x25 -f "Ubuntu Mono-9" -f "FontAwesome-9"' %
        (BG, FG),
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE)

CONFIG = read_config()
OPACITY = CONFIG.get('OPACITY', 'EE')
BG = '#'+OPACITY+CONFIG.get('BG', '141311')
FG = '#'+OPACITY+CONFIG.get('FG', '686766')
ALTFG = '#'+OPACITY+CONFIG.get('ALTFG', '141311')
ALTBG = '#'+OPACITY+CONFIG.get('ALTBG', '686766')

BAR_PROC = start_bar(BG, FG)

# Weather settings
WEATHER_LOCATION = CONFIG.get('WEATHER', 'waterloo')
WEATHER_URL = 'http://rss.accuweather.com/rss/liveweather_rss.asp?locCode=%s&metric=1'\
    % WEATHER_LOCATION

# Window Widget
ACTIVE_WIN_MAX_LEN = 60

# Decorators
def schedule(time_in_seconds=None):
    def _scheduled(func):
        def _run():
            while True:
                try:
                    func()
                except:
                    traceback.print_exc(file=sys.stderr)
                time.sleep(time_in_seconds)

        if time_in_seconds is not None:
            Thread(target=_run).start()
        else:
            Thread(target=func).start()
        return func
    return _scheduled

# Brightness settings
BRIGHT_FILE = '/sys/class/backlight/acpi_video0'
MAX_BRIGHTNESS = 10
with open(os.path.join(BRIGHT_FILE, 'max_brightness')) as f:
    MAX_BRIGHTNESS = int(f.read().strip())

# Power supply settings
POWER_DIRECTORY = '/sys/class/power_supply/ACAD'
AC_POWER_FILE = os.path.join(POWER_DIRECTORY, 'online')

WIDGETS = defaultdict(str)
STATE = {}
temp_info_mode = False
temp_info_active = False
temp_info_item = None

ICONS = {
    'volume_high'       : u'\uF028',
    'volume_low'        : u'\uF027',
    'volume_mute'       : u'%{F#F44242}\uF026%{F-}',
    'brightness_high'   : u'\uF0EB',
    'os'                : u'\uF17C',
    'weather'           : u'\uF2CB',
    'play'              : u'\uf04b',
    'pause'             : u'\uf04c',
    'next'              : u'\uf051',
    'prev'              : u'\uf048',
    'music'             : u'%{T2}\uf001%{T-}',
    'power'             : u'%{T2}\uf011%{T-}',
}

POWER_COMMANDS = {
    'Shutdown': 'systemctl poweroff',
    'Reboot': 'systemctl reboot',
    'Suspend': 'systemctl suspend',
    'Hibernate': 'systemctl hibernate',
    'Lock Screen': 'slimlock'
}

POWER_OPTIONS_ORDER = ['Shutdown', 'Reboot', 'Suspend', 'Hibernate', 'Lock Screen']

WIDGETS['brightness'] = '%%{A4:brightness_up:}%%{A5:brightness_down:}%%{A0:brightness_show:}%s%%{A}%%{A}%%{A}' % ICONS['brightness_high']
WIDGETS['os_plain'] = '%%{A:update:}%%{A0:os_show:}%s%%{A}%%{A}' % ICONS['os']
WIDGETS['weather'] = '%%{A:weather_open:}%%{A0:weather_show:}%s%%{A}%%{A}' % ICONS['weather']
WIDGETS['power'] = '%%{A0:power_show:}%%{A3:power_next:}%%{A:power_select:}%s%%{A}%%{A}%%{A}' % (ICONS['power'])
WIDGETS['power_help'] = '[Power Options] Right Click To Navigate, Left Click To Select'
WIDGETS['cur_power_selection'] = ''

screen = wnck.screen_get_default()
screen.force_update()


#### Helpers ####
def progress(val, tot=100, bars=40, name=''):
    progress = (u'\u2588'*(bars*val//tot)) + (' '*(bars-bars*val//tot))
    return u'%s \uf0d9 %s \uf0da %d/%d' % (name, progress, val, tot)

#### Scheduled function ####
def redraw():
    info_panel_item = WIDGETS['sys_stat']
    if temp_info_active:
        info_panel_item = WIDGETS.get(temp_info_item, '')
    panel_str = u'%%{B%s}%%{l} %s %%{c} %s %%{r} %%{R}%s%%{R}  %s  %%{R} %s %%{R}\n' % (
        BG if WIDGETS['ac_power'] else '#500',
        WIDGETS['wname'],
        info_panel_item,
        WIDGETS['music'],
        ' '.join(WIDGETS[x] for x in ('weather', 'os', 'brightness', 'volume', 'power')),
        WIDGETS['clock']
    )
    BAR_PROC.stdin.write(panel_str.encode('utf-8'))
    BAR_PROC.stdin.flush()

@schedule(1)
def clock():
    global WIDGETS
    WIDGETS['clock'] = b'%%{A0:date_show:}%%{A:calendar:}%s%%{A}%%{A}' % time.strftime('%H:%M:%S').encode()

@schedule(2)
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

@schedule(1)
def set_ac_power():
    global WIDGETS
    with open(AC_POWER_FILE) as f:
        WIDGETS['ac_power'] = f.read().strip() != '0'

@schedule(10)
def set_brightness_info():
    global WIDGETS
    brightness_val = 0
    with open(os.path.join(BRIGHT_FILE, 'brightness')) as f:
        brightness_val = int(f.read().strip())
        STATE['brightness'] = brightness_val
    WIDGETS['brightness_bar'] = progress(brightness_val, tot=MAX_BRIGHTNESS, name='[Brightness]')

@schedule(600)
def set_os_info():
    global WIDGETS
    os_version = subprocess.check_output('uname -sr', shell=True).strip()
    update_count = int(subprocess.check_output('pacman -Qu | wc -l', shell=True).strip())
    WIDGETS['os_info'] = '%s - %s Updates available' % (os_version, update_count)
    if update_count > 0:
        WIDGETS['os'] = '%%{F%s}%s%%{F-}' % ('#8E7', WIDGETS['os_plain'])
    else:
        WIDGETS['os'] = WIDGETS['os_plain']

@schedule(600)
def set_weather_info():
    WIDGETS['weather_bar'] = '[Weather] ' + subprocess.check_output("curl --connect-timeout 15 -s '%s' | grep '<title>Currently' | sed -E 's/<.?title>//g' | sed 's/Currently://' | xargs" % WEATHER_URL, shell=True).strip()

@schedule(1)
def set_sys_stat():
    vmem = psutil.virtual_memory()
    WIDGETS['sys_stat'] = '%%{A:system_status:}[CPU] %2.0f%% | [MEM] %.2fGB (%2.0f%%)%%{A}' % (psutil.cpu_percent(), vmem.used / float(2**30), vmem.percent )

import dbus

session_bus = dbus.SessionBus()

def get_clementine_status():
    try:
        player = session_bus.get_object('org.mpris.clementine', '/Player')
        iface = dbus.Interface(player, dbus_interface='org.freedesktop.MediaPlayer')
        metadata = iface.GetMetadata()
        cur_playing = metadata.get('title', '') + ' - ' + metadata.get('artist', '')
        if cur_playing == ' - ':
            cur_playing = 'Not Playing'
        status = iface.GetStatus().index(0)
        running = True
    except:
        cur_playing = 'Not Playing'
        status = 1
        running = True
        iface = None
    return status, cur_playing, iface

@schedule(2)
def music():
    status, cur_playing, _ = get_clementine_status()
    WIDGETS['cur_playing'] = cur_playing
    WIDGETS['music'] = '%%{A0:music_show:}%%{A:music_open:}  %s  %%{A}%%{A:music_prev:} %s %%{A} %%{A:music_toggle:} %s %%{A} %%{A:music_next:} %s %%{A} %%{A}' % (ICONS['music'], ICONS['prev'], ICONS['play'] if status != 0 else ICONS['pause'], ICONS['next'])

def music_toggle():
    status, cur_playing, iface = get_clementine_status()
    if iface is None:
        subprocess.Popen('clementine')
    elif status == 1:
        iface.Play()
    else:
        iface.Pause()

def music_next(prev=False):
    status, cur_playing, iface = get_clementine_status()
    if iface is None:
        subprocess.Popen('clementine')
    elif prev:
        iface.Prev()
    else:
        iface.Next()

@schedule(0.2)
def wname():
    global WIDGETS
    while gtk.events_pending():
        gtk.main_iteration()
    try:
        active_window = screen.get_active_window().get_name()
    except:
        active_window = 'Desktop'
    if len(active_window) > ACTIVE_WIN_MAX_LEN:
        active_window = active_window[:ACTIVE_WIN_MAX_LEN] + '...'
    WIDGETS['wname'] = '%%{A:window_switcher:}%s%%{A}' % (active_window)
    redraw()

@schedule(3600)
def update_package_list():
    subprocess.call("sudo pacman -Sy", shell=True)

def activate_temp_info(name):
    global temp_info_active, temp_info_mode, temp_info_item
    temp_info_active = True
    temp_info_mode = True
    temp_info_item = name

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
    subprocess.call('sudo tee "%s" <<< %d &>/dev/null' % (os.path.join(BRIGHT_FILE, 'brightness'), STATE['brightness']+1), shell=True)
def brightness_down():
    subprocess.call('sudo tee "%s" <<< %d &>/dev/null' % (os.path.join(BRIGHT_FILE, 'brightness'), STATE['brightness']-1), shell=True)

def update_packages():
    subprocess.call("xterm -e 'sudo pacman -Syu; echo Press any key to continue... && read -n 1'", shell=True)
    set_os_info()

@schedule(None)
def perform_action():
    global temp_info_mode
    while True:
        action = BAR_PROC.stdout.readline().strip()
        if action == 'calendar':
            subprocess.Popen('gsimplecal')
        elif action == 'volume_show':
            activate_temp_info('volume_bar')
        elif action == 'volume_up':
            volume_up()
            set_volume_info()
            activate_temp_info('volume_bar')
            redraw()
        elif action == 'volume_down':
            volume_down()
            set_volume_info()
            activate_temp_info('volume_bar')
            redraw()
        elif action == 'volume_more':
            subprocess.Popen('pavucontrol')
        elif action == 'brightness_show':
            activate_temp_info('brightness_bar')
        elif action == 'brightness_up':
            brightness_up()
            set_brightness_info()
            activate_temp_info('brightness_bar')
            redraw()
        elif action == 'brightness_down':
            brightness_down()
            set_brightness_info()
            activate_temp_info('brightness_bar')
            redraw()
        elif action == 'os_show':
            activate_temp_info('os_info')
        elif action == 'update':
            Thread(target=update_packages).start()
        elif action == 'window_switcher':
            subprocess.Popen('rofi -show window', shell=True)
        elif action == 'weather_show':
            activate_temp_info('weather_bar')
        elif action == 'weather_open':
            subprocess.Popen('xdg-open %s' % WEATHER_URL, shell=True)
        elif action == 'system_status':
            subprocess.Popen('gnome-system-monitor')
        elif action == 'music_open':
            subprocess.Popen('clementine')
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
            redraw()
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
            music()
        elif action == 'music_prev':
            music_next(True)
            music()
        elif action == 'music_next':
            music_next()
            music()
