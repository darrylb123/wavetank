###################################################################################
# Soft start/stop of wave drive
# ramps up/down PWM1 to vary the control voltage to the speed controller.
# requires rule top call the function when relay 5 ( wave drive toggle) state changes
# Template {"NAME":"ESP32-4Relay","GPIO":[32,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,288,0,226,227,1,0,0,0,0,224,225,1,1,1,0,0,1],"FLAG":0,"BASE":1}
#          {"NAME":"ESP32-WaveTank","GPIO":[32,1,1,1,1,1,1,1,448,1,228,608,640,1,1,7360,0,7361,1,288,0,226,227,36,0,0,0,0,224,225,1,1,1,0,0,1],"FLAG":0,"BASE":1}
# Template with i2c removed and 6th relay added
#          {"NAME":"ESP32-WaveTank","GPIO":[32,1,1,1,1,1,1,1,448,229,228,1,1,1,1,1,0,1,1,288,0,226,227,36,0,0,0,0,224,225,1,1,1,0,0,1],"FLAG":0,"BASE":1}
# rule1 on power5#state do softss %value% endon
# rule1 1
###################################################################################
import string

def softss(cmd, idx, payload, payload_json)
	# print(payload)
	var pwmmin = 900
	var pwmmax = 1023
	var step = 10
	var pwmval = 0
	var pwmvalue =tasmota.cmd("PWM")

	pwmval = pwmvalue['PWM']['PWM1']
	# Closure - can access the variables in host function
	# Called by time delay
	def delaycmd()
		# print(pwmval)
		if pwmval < pwmmin
			pwmval = pwmmin
		end
		if (pwmval < pwmmax) &&  (pwmval >= pwmmin)
			pwmval = pwmval + step
			print(pwmval)
			var cmdstr = string.format("pwm1 %d",pwmval)
			tasmota.cmd(cmdstr)
			tasmota.set_timer(200,delaycmd,"wave")
		end
		if pwmval <= pwmmin
			tasmota.remove_timer("wave")
			tasmota.cmd("PWM1 500")
		end	
	end
	if ( payload == "1" )
		print("Start Wave Drive")
		step = 10
		
	else
		print("Stop Wave Drive")
		# Loop the PWM between Min and Max
		step = -10
		
	end
	delaycmd()
	tasmota.resp_cmnd_done()

end



tasmota.add_cmd('SoftSS', softss)
