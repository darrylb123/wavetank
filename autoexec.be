# Load at bootup
# tank pair setting  0 = 1 &2 , 1 = 3 & 4, 3 = 5 & 6
var tankPair = 0
# The water volume at full mark
# FullConst is the volume in litres when the tank is full to the top of the angled bottom
var fullConst = 16.5 
# pumping rate is the volume in litres pumped in 10 seconds
var leftFillRate = 0.0180
var leftEmptyRate = 0.0250
var rightFillRate = 0.0236
var rightEmptyRate = 0.0270

# var volPer10Sec = [ [ 0.0210, 0.0170, 0.0195, 0.0165 ],[ 0.02, 0.018, 0.0194, 0.0167 ],[ 0.019, 0.0171, 0.0198, 0.0166 ] ]
# Derived volume variables
var var10 = 0
var var11 = 0

load("pump_ctl.be")
load("mqtt.be")
# load("softstart.be")

