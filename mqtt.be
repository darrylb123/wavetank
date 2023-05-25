# MQTT Communications


import json
import string
import mqtt

def wavetank_msg(topic, idx, payload_s, payload_b)
	print(payload_s)
	var tank_msg = json.load(payload_s)
	var disabled = 0
	if tank_msg['disabled'] == "disabled"
		disabled = 1
	end
	var  output_str = string.format("Tidal Period: %d,Tidal mean: %d, Tide PtP: %d, Pumps disabled %d", tank_msg['period'],tank_msg['mean'],tank_msg['ptp'],disabled)
	log(output_str)
	var cmd_str = string.format("backlog var1 %d; var2 %d; var3 %d; var4 %d",tank_msg['period'],tank_msg['mean'],tank_msg['ptp'],disabled)
	tasmota.cmd(cmd_str)
end

def subscribes()
  mqtt.subscribe("cmnd/wavetank/control",wavetank_msg)
end

tasmota.add_rule("MQTT#Connected=1", subscribes)
