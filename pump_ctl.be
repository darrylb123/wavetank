# Level control
# Compare setpoint against actual level and use the pump to adjust the level to setpoint

# The holding variables will be tasmota variables
# VAR1 - Wavetank-a Setpoint
# VAR2 - Wavetank-B Setpoint
# VAR3 - Wavetank-a actual
# VAR4 - Wavetank-b Actual
# Rules will copy the level measurements into the VARx

import json
import string

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
	var setpoint = [number(tasvars['Var1']), number(tasvars['Var2'])]
	var level = [number(tasvars['Var3']),number(tasvars['Var4'])]
	# print(check_level(setpoint[0],level[0]))
	
	# pump A control
	var ret = check_level(setpoint[0],level[0])
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
	ret = check_level(setpoint[1],level[1])
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
	
end





# Each 10 seconds check level against setpoint
tasmota.add_cron("*/10 * * * * *",each_ten_sec,"level_ctl")























