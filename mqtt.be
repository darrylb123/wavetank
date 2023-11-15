# MQTT Communications


import json
import string
import mqtt




# mosquitto_pub -h mqtt -t cmnd/wavetank/control -m "{ \"period\":250,\"mean\":165,\"ptp\":41,\"disabled\":\"false\"}"
def wavetank_msg(topic, idx, payload_s, payload_b)
	# print(payload_s)
	var tank_msg = json.load(payload_s)
	var disabled = 0
	if tank_msg['disabled'] == "disabled"
		disabled = 1
	end
	var  output_str = string.format("Tidal Period: %f,Tidal mean: %f, Tide PtP: %f, Pumps disabled %d", tank_msg['period'],tank_msg['mean'],tank_msg['ptp'],disabled)
	print(output_str)
	var cmd_str = string.format("backlog var1 %d; var2 %d; var3 %d; var4 %d",number(tank_msg['period']),number(tank_msg['mean']),number(tank_msg['ptp']),disabled)
	tasmota.cmd(cmd_str)

end


mqtt.subscribe("cmnd/wavetank/control",wavetank_msg)




