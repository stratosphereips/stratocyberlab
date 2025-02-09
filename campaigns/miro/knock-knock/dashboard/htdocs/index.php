<?php

$files = scandir('/var/www/html');

$no = array('.', '..', 'index.php');

?>
<!doctype html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Dashboard</title>
</head>
<body>
	<h1>Welcome, Ronnie. <small>How are you today?</small></h1>
	<span>Your files:</span>
	<ul><?php foreach ($files as $file) {
		if (in_array($file, $no)) continue;
		?>
		<li><a href="/<?=$file?>"><?=$file?></a></li>
	<?php } ?></ul>
</body>
</html>

