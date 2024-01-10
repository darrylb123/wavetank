# Level control
# Compare setpoint against actual level and use the pump to adjust the level to setpoint
# Template: {"NAME":"ESP32-WaveTank","GPIO":[32,1,1,1,1,1,1,1,448,229,228,229,1,1,1,1,0,1,1,288,0,226,227,36,0,0,0,0,224,225,1,1,1,0,0,1],"FLAG":0,"BASE":1}

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
var pumpState = [0,0]

# load volume setting from memory
var mems = tasmota.cmd('mem')
var10 = real(mems['Mem1'])
var11 = real(mems['Mem2'])



def checkVol(sp,vol,pumpa,pumpb)
    # deadband is > 2* flow rate
    # if the pumps are running, then run to setpoint
    # else wait until the volume has exceeded the deadband before running again.
	var deadband = 0.05
	print(string.format("SP: %f Vol: %f Diff: %f",sp,vol, vol - sp))
	# If the pump is running, allow to drive into the deadband
	if pumpa || pumpb
	    if  vol  < sp
		    return -1
		end
	    if vol  > sp 
		    return 1
	    end
	elif  math.abs(vol - sp) > deadband
	    if  vol  < sp
		    return -1
		end
	    if vol  > sp 
		    return 1
	    end
	end
	return 0
end


def each_ten_sec()
	var tasvars=tasmota.cmd('var')
	var disable = number(tasvars['Var4'])
	var volume = real(tasvars['Var7'])
	var pwrState = tasmota.get_power()
    
	if !disable && !pwrState[5] 
	    # pump A control
	    var ret = checkVol(volume,var10,pwrState[0],pwrState[1])
	    if ret != pumpState[0]
	        pumpState[0] = ret
	        ret = 0
	    end
	    
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
	    ret = checkVol(volume,var11,pwrState[2],pwrState[3])
	    if ret !=  pumpState[1]
	        pumpState[1] = ret
	        ret = 0
	    end
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
	var pwrState = tasmota.get_power()
	# If the pump to empty button is set
	if pwrState[5] 
	    mean = 0
	    ptp = 0
	endif
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





















