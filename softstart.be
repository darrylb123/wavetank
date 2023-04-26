###################################################################################
# Soft start/stop of wave drive
# ramps up/down PWM1 to vary the control voltage to the speed controller.
# requires rule top call the function when relay 5 ( wave drive toggle) state changes
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
