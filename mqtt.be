# MQTT Communications


import json
import string
import mqtt

def wavetank_msg(topic, idx, payload_s, payload_b)
	print(payload_s)
	var tank_msg = json.load(payload_s)
	var  output_str = string.format("Setpoint %d", tank_msg['Setpoint'])
	log(output_str)
	var cmd_str = string.format("backlog var1 %d; var2 %d",tank_msg['Setpoint'],tank_msg['Setpoint'])
	tasmota.cmd(cmd_str)
end

def subscribes()
  mqtt.subscribe("cmnd/wavetank/control",wavetank_msg)
end

tasmota.add_rule("MQTT#Connected=1", subscribes)
