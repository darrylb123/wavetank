# Level control
# Compare setpoint against actual level and use the pump to adjust the level to setpoint

# The holding variables will be tasmota variables
# VAR1 - Tide Period
# VAR2 - Tide Mean
# VAR3 - Tide PtP
# VAR4 - Wavetank pumps disable
# VAR5 = Tank A level
# VAR6 = Tank B Level
# VAR7 = Calculated Setpoint volume
# VAR8 = calculated height setpoint
# VAR10 = Derived volume Tank A
# VAR11 = Derived volume Tank B
# MQTT will copy the settings into the VAR1-4
# Rule will copy laser level into Var5-6


import json
import string
import math

var setpoint = 0.0

# load volume setting from memory
var mems = tasmota.cmd('mem')
var10 = real(mems['Mem1'])
var11 = real(mems['Mem2'])

# Calculate and update the current tank volume based on how long the pumps have been running.
def updateVolume()
    # Relay 1 and 3 increase volume, 2 &4 decrease
    var curVol = 0
    var updateCmd = ""
    var tasvars=tasmota.cmd('var')
	# var10 = number(tasvars['Var10'])
	# var11 = number(tasvars['Var11'])
	var pwrState = tasmota.get_power()
	
	# print(string.format("var11 %f var11 %f \n",var10,var11))
	# Left tank in 
    if pwrState[0]
        var10 =  var10 + volPer10Sec[tankPair][1]
        updateCmd = string.format("var10 %f", var10)
        tasmota.cmd(updateCmd)
    end
    # Left tank out 
    if pwrState[1] 
        var10 =  var10 - volPer10Sec[tankPair][0]
        updateCmd = string.format("var10 %f", var10)
        tasmota.cmd(updateCmd)
    end
    # Right Tank un
    if pwrState[2] 
        var11 =  var11 + volPer10Sec[tankPair][3]
        updateCmd = string.format("var11 %f", var11)
        tasmota.cmd(updateCmd)
    end
    # Right tank out
    if pwrState[3]
        var11 =  var11 - volPer10Sec[tankPair][2]
        updateCmd = string.format("var11 %f", var11)
        tasmota.cmd(updateCmd)
    end 
    
end


def checkVol(sp,vol)
	var deadband = 0.02
	print(string.format("SP: %f Vol: %f",sp,vol))
	if  (vol + deadband) > sp
		return 1
	end
	if (vol - deadband) < sp 
		return -1
	end
	return 0
end


def each_ten_sec()
	var tasvars=tasmota.cmd('var')
	var disable = number(tasvars['Var4'])
	var volume = real(tasvars['Var7'])
	updateVolume()
	var pwrState = tasmota.get_power()

	if !disable && !pwrState[5] 
	    # pump A control
	    var ret = checkVol(volume,var10)
	    if ret == 1
	        if pwrState[0] 
	    	    tasmota.set_power(0,false)
	    	end
	    	if !pwrState[1]
	    	    tasmota.set_power(1,true)
	    	    end
	    elif ret == -1
	        if !pwrState[0]
	    	    tasmota.set_power(0,true)
	    	end
	    	if pwrState[1]
	    	    tasmota.set_power(1,false)
	    	end
	    else
	        if pwrState[0]
	    	    tasmota.set_power(0,false)
	    	end
	    	if pwrState[1]
	    	    tasmota.set_power(1,false)
	    	end
	    end
		
	    # pump B control
	    ret = checkVol(volume,var11)
	    if ret == 1
	        if pwrState[2]
	    	    tasmota.set_power(2,false)
	    	end
	    	if !pwrState[3]
	    	    tasmota.set_power(3,true)
	    	end
	    elif ret == -1
	        if !pwrState[2]
	    	    tasmota.set_power(2,true)
	    	end
	    	if pwrState[3]
	    	    tasmota.set_power(3,false)
	    	end
	    else
	        if pwrState[2]
	    	    tasmota.set_power(2,false)
	    	end
	    	if pwrState[3]
	    	    tasmota.set_power(3,false)
	    	end
	    end
	else
	    if pwrState[0]
	        tasmota.set_power(0,false)
	    end
	    if pwrState[1]
	        tasmota.set_power(1,false)
	    end
	    if pwrState[2]
            tasmota.set_power(2,false)
        end
        if pwrState[3]
	    	tasmota.set_power(3,false)
	    end
	end
end


def each_minute()
    var tasvars=tasmota.cmd('var')
	var period = number(tasvars['Var1'])
	var mean = number(tasvars['Var2'])
	var ptp = number(tasvars['Var3'])
	
	var thetime=tasmota.rtc()
	var minute = thetime['local']/60
	setpoint = mean+((math.sin((2.0*math.pi)*(real((minute % period)) / period)))*(ptp/2))
	var volume = ( 0.00032229 * (setpoint * setpoint)) +  ( 0.0037352 * setpoint ) - 0.11038
	var sp= string.format("backlog var7 %f ; var8 %f ; mem1 %f ; mem2 %f", volume, setpoint, var10, var11)
	# print(sp)
	tasmota.cmd(sp)
end


# Each 10 seconds check level against setpoint
# tasmota.add_cron("*/10 * * * * *",each_ten_sec,"level_ctl")
# tasmota.add_cron("0 * * * * *",each_minute,"setpoint")






















