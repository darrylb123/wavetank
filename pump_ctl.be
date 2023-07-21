# Level control
# Compare setpoint against actual level and use the pump to adjust the level to setpoint

# The holding variables will be tasmota variables
# VAR1 - Tide Period
# VAR2 - Tide Mean
# VAR3 - Tide PtP
# VAR4 - Wavetank pumps disable
# VAR5 = Tank A level
# VAR6 = Tank B Level
# VAR7 = Calculated Setpoint
# MQTT will copy the settings into the VAR1-4
# Rule will copy laser level into Var5-6

import json
import string
import math

var setpoint = 0
var volPer10Sec = 1;
var mem1 = 0
var mem2 = 0

# Calculate and update the current tank volume based on how long the pumps have been running.
def updateVolume()
    # Relay 1 and 3 increase volume, 2 &4 decrease
    var curVol = 0
    var updateCmd = ""
    var tasvars=tasmota.cmd('mem')
	mem1 = number(tasvars['Mem1'])
	mem2 = number(tasvars['Mem2'])
	var pwrState = tasmota.get_power()
	
	print(string.format("mem2 %d mem2 %d \n",mem1,mem2))
    if pwrState[0]
        mem1 =  mem1 + volPer10Sec
        updateCmd = string.format("mem1 %d", mem1)
        tasmota.cmd(updateCmd)
    end
    if pwrState[1] 
        mem1 =  mem1 - volPer10Sec
        updateCmd = string.format("mem1 %d", mem1)
        tasmota.cmd(updateCmd)
    end
    if pwrState[2] 
        mem2 =  mem2 + volPer10Sec
        updateCmd = string.format("mem2 %d", mem2)
        tasmota.cmd(updateCmd)
    end
    if pwrState[3]
        mem2 =  mem2 - volPer10Sec
        updateCmd = string.format("mem2 %d", mem2)
        tasmota.cmd(updateCmd)
    end 
    
end


def checkVol(sp,vol)
	var deadband = 0.2
	print(string.format("SP: %f Vol: %f",sp,vol))
	if  (vol + deadband) < sp
		return 1
	end
	if (vol - deadband) > sp 
		return -1
	end
	return 0
end


def each_ten_sec()
	var tasvars=tasmota.cmd('var')
	var disable = number(tasvars['Var4'])
	updateVolume()
	
	# print(checkVol(setpoint,mem1))
	if !disable
	    # pump A control
	    var ret = checkVol(setpoint,mem1)
	    if ret == 1
	    	tasmota.set_power(0,false)
	    	tasmota.set_power(1,true)
	    elif ret == -1
	    	tasmota.set_power(0,true)
	    	tasmota.set_power(1,false)
	    else
	    	tasmota.set_power(0,false)
	    	tasmota.set_power(1,false)
	    end
		
	    # pump B control
	    ret = checkVol(setpoint,mem2)
	    if ret == 1
	    	tasmota.set_power(2,false)
	    	tasmota.set_power(3,true)
	    elif ret == -1
	    	tasmota.set_power(2,true)
	    	tasmota.set_power(3,false)
	    else
	    	tasmota.set_power(2,false)
	    	tasmota.set_power(3,false)
	    end
	else
	        tasmota.set_power(0,false)
	    	tasmota.set_power(1,false)
            tasmota.set_power(2,false)
	    	tasmota.set_power(3,false)
	end
end


def each_minute()
	var tasvars=tasmota.cmd('var')
	var period = number(tasvars['Var1'])
	var mean = number(tasvars['Var2'])
	var ptp = number(tasvars['Var3'])
	
	var thetime=tasmota.rtc()
	var minute = thetime['local']/60
	setpoint = mean+((math.sin((2.0*math.pi)*(real((minute % period)) / period)))*ptp)
	var sp= string.format("var7 %f", setpoint)
	tasmota.cmd(sp)
end


# Each 10 seconds check level against setpoint
tasmota.add_cron("*/10 * * * * *",each_ten_sec,"level_ctl")
tasmota.add_cron("0 * * * * *",each_minute,"setpoint")






















