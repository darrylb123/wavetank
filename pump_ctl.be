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

def check_level(sp,level)
	var deadband = 0.2
	print(string.format("SP: %f Level: %f",sp,level))
	if  (level + deadband) < sp
		return 1
	end
	if (level - deadband) > sp 
		return -1
	end
	return 0
end

def each_ten_sec()
	var tasvars=tasmota.cmd('var')
	var disable = number(tasvars['Var4'])
	var levelA =  number(tasvars['Var5'])
	var levelB =  number(tasvars['Var6'])
	
	# print(check_level(setpoint,levelA))
	
	# pump A control
	var ret = check_level(setpoint,levelA)
	if ret == 1 && !disable
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
	ret = check_level(setpoint,levelB)
	if ret == 1 && !disable
		tasmota.set_power(2,false)
		tasmota.set_power(3,true)
	elif ret == -1
		tasmota.set_power(2,true)
		tasmota.set_power(3,false)
	else
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






















