# Load at bootup
# tank pair setting
var tankPair = 1
# The water volume at full mark
var fullConst = 24
# pumping volume
var volPer10Sec = 0.15;
# Derived volume variables
var var10 = 0
var var11 = 0

load("mqtt.be")
load("pump_ctl.be")
# load("softstart.be")

