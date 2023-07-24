<html>
<head> <title>Wavetank Settings</title></head>
<body>
<h2>Wavetank Settings</h2>
<?php
require __DIR__ . '/vendor/autoload.php';
$server   = 'localhost';
$port     = 1883;
$clientId = 'wavetank-config';
$data=array("dummy" => -1);

$mqtt = new \PhpMqtt\Client\MqttClient($server, $port, $clientId);
$mqtt->connect(null,true);
$mqtt->subscribe('+/wavetank/control', function ($topic, $message, $retained, $matchedWildcards) use($mqtt,&$data){
    echo sprintf("Received message on topic [%s]: %s\n", $topic, $message);
    # $tmpdata = (array)json_decode($message);
    $data = array_merge($data,(array)json_decode($message));
    # var_dump($data);
    $mqtt->interrupt();
}, \PhpMqtt\Client\MqttClient::QOS_EXACTLY_ONCE);
$mqtt->loop(true);
$mqtt->disconnect();
# echo $data->period;
?>
<BR>
<H4> Wave tank controllers </H4>
<ul>
<LI> <a href="http://192.168.11.111">1 & 2 Tank Controller</a>
<LI> <a href="http://192.168.11.112">3 & 4 Tank Controller</a>
<LI> <a href="http://192.168.11.113">5 & 6 Tank Controller</a>
</ul>
<H4>Current Position</H4>
<table style="text-align:left">
<tr><th>Tide Period:</th><td><?php echo $data["period"]; ?></TD></TR>
<tr><th>Tide Elapsed:</th><td><?php echo $data["sofar"]; ?></TD></TR>
<tr><th>Tide Peak to Peak Height:</th><td><?php echo $data["ptp"]; ?></TD></TR>
<tr><th>Tide Mean Height:</th><td><?php echo $data["mean"]; ?></TD></TR>
<tr><th>Current Height:</th><td><?php echo $data["current"]; ?></TD></TR>
<tr><th>Pumps Disabled:</th><td><?php if (empty( $data["disabled"])) echo "enabled"; else echo "disabled";?></TD></TR>
</table>
<hr>
<H4>New Settings</h4>
<form action="update.php" method="post">
<label for="period">Tide Period:</label>
<input type="text" name="period"value=<?php echo $data["period"]; ?> >minutes<br>
<label for="mean">Tide Mean:</label>
<input type="text" name="mean"value=<?php echo $data["mean"]; ?> >mm<br>
<label for="height">Tide Peak to Peak Height:</label>
<input type="text" name="ptp" value=<?php echo $data["ptp"]; ?> >mm<br>
<label for="disabled">Disable pump operation:</label>
<input type="checkbox" id="disabled" name="disabled" value="disabled" <?php if (!empty($data["disabled"])) echo "checked";?>><br>
<input type="submit">
</form>
<HR>
<form action="full.php" method="post">
<table style="text-align:left" >
<TR><TH>Tank</TH><TH>1</TH><TH>2</TH><TH>3</TH><TH>4</TH><TH>5</TH><TH>6</TH></TR>
<TR><TH>Mark Tank Full</TH><TD><input type="checkbox" id="T1" name="T1" value="true"></TD>
<TD><input type="checkbox" id="T2" name="T2" value="true"></TD>
<TD><input type="checkbox" id="T3" name="T3" value="true"></TD>
<TD><input type="checkbox" id="T4" name="T4" value="true"></TD>
<TD><input type="checkbox" id="T5" name="T5" value="true"></TD>
<TD><input type="checkbox" id="T6" name="T6" value="true"></TD></TR>
</table>
<input type="submit">
</form> 


</body>


</html>
