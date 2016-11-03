#!/usr/bin/python2
from __future__ import print_function
import subprocess
import time
import wnck
import gtk
import sys
import os
import traceback
import psutil
from collections import defaultdict
from threading import Thread

# Weather settings
WEATHER_LOCATION = 'waterloo'
WEATHER_URL = 'http://rss.accuweather.com/rss/liveweather_rss.asp?locCode=%s&metric=1' % WEATHER_LOCATION

CUR_DIR = os.path.dirname(os.path.abspath(__file__))

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
POWER_DIRECTORY='/sys/class/power_supply/ACAD'
AC_POWER_FILE = os.path.join(POWER_DIRECTORY, 'online')

icons = defaultdict(str)
widgets = defaultdict(str)
state = {}
temp_info_mode = False
temp_info_active = False
temp_info_item = None

icons['volume_high'] = u'\uF028'
icons['volume_low'] = u'\uF027'
icons['volume_mute'] = u'%{F#F44242}\uF026%{F-}'
icons['brightness_high'] = u'\uF0EB'
icons['os'] = u'\uF17C'
icons['weather'] = u'\uF0C2'

widgets['volume'] = '%%{A:volume_more:}%%{A4:volume_up:}%%{A5:volume_down:}%%{A0:volume_show:}%s%%{A}%%{A}%%{A}%%{A}' % icons['volume_high']
widgets['brightness'] = '%%{A4:brightness_up:}%%{A5:brightness_down:}%%{A0:brightness_show:}%s%%{A}%%{A}%%{A}' % icons['brightness_high']
widgets['os_plain'] = '%%{A:update:}%%{A0:os_show:}%s%%{A}%%{A}' % icons['os']
widgets['os'] = widgets['os_plain']
widgets['weather'] = '%%{A:weather_open:}%%{A0:weather_show:}%s%%{A}%%{A}' % icons['weather']

screen = wnck.screen_get_default()
screen.force_update()

bar_proc = subprocess.Popen('lemonbar -a 20 -b -g x20 -B#333 -f "Ubuntu Mono-8" -f "FontAwesome-8"',
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE)

#### Helpers ####
def progress(val, tot=100, bars=50, name=''):
    progress = (u'\u2588'*(bars*val//tot)) + (' '*(bars-bars*val//tot))
    return u'%s \uf0d9 %s \uf0da %d/%d' % (name, progress, val, tot)

#### Scheduled function ####
def redraw():
    info_panel_item = widgets['sys_stat']
    if temp_info_active:
        info_panel_item = widgets[temp_info_item]
    panel_str = u'%%{B%s}%%{l} %s %%{c} %s %%{r} %s  %s \n' % (
                '#333' if widgets['ac_power'] else '#533',
                widgets['wname'],
                info_panel_item,
                ' '.join(widgets[x] for x in ('weather', 'os', 'brightness', 'volume')),
                widgets['clock']
            )
    bar_proc.stdin.write(panel_str.encode('utf-8'))
    bar_proc.stdin.flush()

@schedule(1)
def clock():
    global widgets
    widgets['clock'] = b'%%{A:calendar:}%s%%{A}' % time.strftime('%H:%M:%S').encode()

@schedule(2)
def set_volume_info():
    global widgets
    cur_volume = int(subprocess.check_output('amixer get Master | awk -F"[][]" \'/[.*?%]/{print $2}\' | head -1', shell=True).strip()[:-1])
    cur_icon = icons['volume_high']
    if cur_volume == 0:
        cur_icon = icons['volume_mute']
    elif cur_volume < 50:
        cur_icon = icons['volume_low']
    widgets['volume'] = '%%{A:volume_more:}%%{A4:volume_up:}%%{A5:volume_down:}%%{A0:volume_show:}%s%%{A}%%{A}%%{A}%%{A}' % cur_icon
    widgets['volume_bar'] = progress(cur_volume, name='[Volume]')

@schedule(1)
def set_ac_power():
    global widgets
    with open(AC_POWER_FILE) as f:
        widgets['ac_power'] = f.read().strip() != '0'

@schedule(10)
def set_brightness_info():
    global widgets
    brightness_val = 0
    with open(os.path.join(BRIGHT_FILE, 'brightness')) as f:
        brightness_val = int(f.read().strip())
        state['brightness'] = brightness_val
    widgets['brightness_bar'] = progress(brightness_val, tot=MAX_BRIGHTNESS, name='[Brightness]')

@schedule(600)
def set_os_info():
    global widgets
    os_version = subprocess.check_output('uname -sr', shell=True).strip()
    update_count = int(subprocess.check_output('pacman -Qu | wc -l', shell=True).strip())
    widgets['os_info'] = '%s - %s Updates available' % (os_version, update_count)
    if update_count > 0:
        widgets['os'] = '%%{F#74A340}%s%%{F-}' % widgets['os_plain']
    else:
        widgets['os'] = widgets['os_plain']

@schedule(600)
def set_weather_info():
    widgets['weather_bar'] = '[Weather] ' + subprocess.check_output("curl --connect-timeout 15 -s '%s' | grep '<title>Currently' | sed -E 's/<.?title>//g' | sed 's/Currently://' | xargs" % WEATHER_URL, shell=True).strip()

@schedule(1)
def set_sys_stat():
    vmem = psutil.virtual_memory()
    widgets['sys_stat'] = '%2.0f%% | %.2fGB (%2.0f%%)' % (psutil.cpu_percent(), vmem.used / float(2**30), vmem.percent )

@schedule(0.2)
def wname():
    global widgets
    while gtk.events_pending():
        gtk.main_iteration()
    try:
        widgets['wname'] = screen.get_active_window().get_name()
    except:
        widgets['wname'] = 'Desktop'
    widgets['wname'] = '%%{A:window_switcher:}%s%%{A}' % (widgets['wname'])
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
    subprocess.call('sudo tee "%s" <<< %d &>/dev/null' % (os.path.join(BRIGHT_FILE, 'brightness'), state['brightness']+1), shell=True)
def brightness_down():
    subprocess.call('sudo tee "%s" <<< %d &>/dev/null' % (os.path.join(BRIGHT_FILE, 'brightness'), state['brightness']-1), shell=True)

def update_packages():
    subprocess.call("xterm -e 'sudo pacman -Syu; echo Press any key to continue... && read -n 1'", shell=True)
    set_os_info()

@schedule(None)
def perform_action():
    global temp_info_mode
    while True:
        action = bar_proc.stdout.readline().strip()
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
