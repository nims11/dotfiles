#!/usr/bin/python2
from __future__ import print_function
import subprocess
import time
import wnck
import gtk
import sys
import os
from collections import defaultdict
from threading import Thread

BRIGHT_FILE = '/sys/class/backlight/acpi_video0'
MAX_BRIGHTNESS = 10
with open(os.path.join(BRIGHT_FILE, 'max_brightness')) as f:
    MAX_BRIGHTNESS = int(f.read().strip())

icons = defaultdict(str)
widgets = defaultdict(str)
state = {}
temp_info_mode = False
temp_info_active = False
temp_info_item = None

icons['volume_high'] = u'\uF028'
icons['brightness_high'] = u'\uF185'

widgets['volume'] = '%%{A4:volume_up:}%%{A5:volume_down:}%%{A0:volume_show:}%s%%{A}%%{A}%%{A}' % icons['volume_high']
widgets['brightness'] = '%%{A4:brightness_up:}%%{A5:brightness_down:}%%{A0:brightness_show:}%s%%{A}%%{A}%%{A}' % icons['brightness_high']

screen = wnck.screen_get_default()
screen.force_update()

bar_proc = subprocess.Popen('/home/nimesh/bar/lemonbar -b -g x20 -B#333 -f "Inconsolata-8" -f "FontAwesome-8"',
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE)

#### Helpers ####
def progress(val, tot=100, bars=50):
    progress = (u'\u2588'*(bars*val//tot)) + (' '*(bars-bars*val//tot))
    return u'\uf0d9 %s \uf0da %d/%d' % (progress, val, tot)

#### Scheduled function ####
def redraw():
    info_panel_item = widgets['wname']
    if temp_info_active:
        info_panel_item = widgets[temp_info_item]
    panel_str = u'%%{l} %s %%{r} %s %s %s \n' % (
            info_panel_item, 
            widgets['brightness'],
            widgets['volume'],
            widgets['clock']
            )
    bar_proc.stdin.write(panel_str.encode('utf-8'))
    bar_proc.stdin.flush()

def clock():
    global widgets
    while True:
        widgets['clock'] = b'%%{A:calendar:}%s%%{A}' % time.strftime('%H:%M:%S').encode()
        # redraw()
        time.sleep(1)

def set_volume_info():
    global widgets
    widgets['volume_bar'] = progress(int(subprocess.check_output('amixer get Master | awk -F"[][]" \'/[.*?%]/{print $2}\' | head -1', shell=True).strip()[:-1]))

def set_brightness_info():
    global widgets
    brightness_val = 0
    with open(os.path.join(BRIGHT_FILE, 'brightness')) as f:
        brightness_val = int(f.read().strip())
        state['brightness'] = brightness_val
    widgets['brightness_bar'] = progress(brightness_val, tot=MAX_BRIGHTNESS)

def volume():
    while True:
        set_volume_info()
        time.sleep(2)

def brightness():
    while True:
        set_brightness_info()
        time.sleep(10)

def wname():
    global widgets
    while True:
        while gtk.events_pending():
            gtk.main_iteration()
        time.sleep(0.2)
        widgets['wname'] = screen.get_active_window().get_name()
        redraw()

def activate_temp_info(name):
    global temp_info_active, temp_info_mode, temp_info_item
    temp_info_active = True
    temp_info_mode = True
    temp_info_item = name

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

Thread(target=clock).start()
Thread(target=wname).start()
Thread(target=volume).start()
Thread(target=brightness).start()
Thread(target=perform_action).start()
Thread(target=temp_info_counter).start()
