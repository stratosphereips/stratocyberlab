<?php

$services = array(
	'dashboard',
	'proxy',
	'mail',
);

if (!isset($_POST['entry'])
	|| !isset($_POST['service'])
	|| !in_array($_POST['service'], $services)
) {
	http_response_code(400);
	die();
}

$filename = '/var/log/dashboard/' . $_POST['service'] . date('Y-m-d') . '.log';
$data = json_encode(array(
	"time" => time(),
	"entry" => $_POST['entry']
));

$result = file_put_contents($filename, $data, FILE_APPEND | LOCK_EX);

