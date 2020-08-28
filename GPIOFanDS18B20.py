import os, glob, time, signal, sys

high = 50
low = 40
state = 1 # default device status. Comes from device tree
interval = 5 
fan = "/sys/class/leds/fan_0/brightness"
DEBUG = True

# Use a device tree overlay to set up your fan GPIO as a "gpio-leds"
#
# This lets us name it and easily set its value
#
# # A better implementation would use it as a "gpio-fan" with a cooling zone
# but there is no w1-therm device tree binding, so I don't see how to wire
# them together.
# 
# You could also rework this to use regular sysfs gpio if you want

def signalHandler(stuff, signal):
    global running
    debug("Shutting down.")
    running = False

def debug(*args):
    global DEBUG, lastDebug
    name="GPIOFanDS18B20"
    if DEBUG:
        if lastDebug != args:
            print(name + ":", *args)
        lastDebug = args

desired = None
running = True
lastDebug = None

for hwmon in glob.glob("/sys/class/hwmon/*"):
    with open(hwmon + "/name", "r") as namehandle:
        if "w1_slave_temp" in namehandle.read():
            desired = hwmon
            debug("desired device found: ",desired)
if not desired:
    debug("warning: no sensor detected.")
    sys.exit(1)

signal.signal(signal.SIGHUP, signalHandler)
signal.signal(signal.SIGINT, signalHandler)
signal.signal(signal.SIGTERM, signalHandler)
signal.signal(signal.SIGQUIT, signalHandler)
signal.signal(signal.SIGABRT, signalHandler)

while running:
    with open(desired + "/temp1_input", "r") as temp:
        temptext = temp.read()
    temp = float(temptext)
    temp /= 1000
    debug("got temp:",temp)

    if (temp > high) and (state==0):
        state = 1
        debug("enabling fan")
        with open(fan, "w") as fansetting:
            fansetting.write("255")
    if (temp < low) and (state==1):
        state = 0
        debug("disabling fan")
        with open(fan, "w") as fansetting:
            fansetting.write("0")

    time.sleep(interval)