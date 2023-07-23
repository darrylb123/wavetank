# MQTT Communications


import json
import string
import mqtt




def wavetank_msg(topic, idx, payload_s, payload_b)
	# print(payload_s)
	var tank_msg = json.load(payload_s)
	var disabled = 0
	if tank_msg['disabled'] == "disabled"
		disabled = 1
	end
	var  output_str = string.format("Tidal Period: %f,Tidal mean: %f, Tide PtP: %f, Pumps disabled %d", tank_msg['period'],tank_msg['mean'],tank_msg['ptp'],disabled)
	log(output_str)
	var cmd_str = string.format("backlog var1 %d; var2 %d; var3 %d; var4 %d",number(tank_msg['period']),number(tank_msg['mean']),number(tank_msg['ptp']),disabled)
	tasmota.cmd(cmd_str)
end

# Load MEM1 and MEM2 with the full value as a starting point for volume calculations
def tanks_full(topic, idx, payload_s, payload_b)
    print(payload_s)
    var tank_msg = json.load(payload_s)
    # Unique number set in autoexec.be
    var mem1 = 0
    var mem2 = 0
    if ( tankPair == 1 )
        if tank_msg['T1'] == "true"
            mem1 = fullConst
            var10 = fullConst
        end
        if tank_msg['T2'] == "true"
            mem2 = fullConst
            var11 = fullConst
        end
    end
    if ( tankPair == 2 )
        if tank_msg['T3'] == "true"
            var10 = fullConst
            mem1 = fullConst
        end
        if tank_msg['T4'] == "true"
            var11 = fullConst
            mem2 = fullConst
        end
    end
    if ( tankPair == 3 )
        if tank_msg['T5'] == "true"
            var10 = fullConst
            mem1 = fullConst
        end
        if tank_msg['T6'] == "true"
            var11 = fullConst
            mem2 = fullConst
        end
    end
    var cmd_str = string.format("backlog mem1 %f; mem2 %f; var10 %f; var11 %f",mem1,mem2,var10,var11)
	tasmota.cmd(cmd_str)
end
    

# mqtt.subscribe("cmnd/wavetank/control",wavetank_msg)
# mqtt.subscribe("cmnd/wavetank/full",tanks_full)

def subscribes()
  mqtt.subscribe("cmnd/wavetank/control",wavetank_msg)
  mqtt.subscribe("cmnd/wavetank/full",tanks_full)
  # Each 10 seconds check level against setpoint
    tasmota.add_cron("*/10 * * * * *",each_ten_sec,"level_ctl")
    tasmota.add_cron("0 * * * * *",each_minute,"setpoint")
end

tasmota.add_rule("MQTT#Connected=1", subscribes)
