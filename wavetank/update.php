<html>
<head>Wave tank Settings</head>
<body>
Updated<br>

<?php
require __DIR__ . '/vendor/autoload.php';
$server   = 'localhost';
$port     = 1883;
$clientId = 'wavetank-settings';
$mqttTopic = "cmnd/wavetank/control";

$mqtt = new \PhpMqtt\Client\MqttClient($server, $port, $clientId);
$mqtt->connect(null,true);
$pubJson = "{ \"period\":".$_POST['period'].",\"ptp\":". $_POST['ptp'].",\"mean\":". $_POST['mean'].",\"disabled\":". "\"".$_POST['disabled']."\"}";
echo $pubJson;
$mqtt->publish($mqttTopic ,$pubJson , 0, true);

$mqtt->disconnect();

?>

</body
</html>

