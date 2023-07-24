<html>
<head>Wave tank Settings</head>
<body>
Updated Tank Full<br>

<?php
require __DIR__ . '/vendor/autoload.php';
$server   = 'localhost';
$port     = 1883;
$clientId = 'wavetank-settings';
$mqttTopic = "cmnd/wavetank/full";

$mqtt = new \PhpMqtt\Client\MqttClient($server, $port, $clientId);
$mqtt->connect(null,true);
$pubJson = "{ \"T1\": \"".$_POST['T1']."\",\"T2\": \"". $_POST['T2']."\",\"T3\": \"". $_POST['T3']."\",\"T4\": \"".$_POST['T4']."\",\"T5\": \"".$_POST['T5']."\",\"T6\": \"".$_POST['T6']."\"}";
echo $pubJson;
$mqtt->publish($mqttTopic ,$pubJson , 0, true);

$mqtt->disconnect();

?>

</body
</html>
