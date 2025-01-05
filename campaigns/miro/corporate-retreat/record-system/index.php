<?php
require_once 'vendor/autoload.php';
$faker = Faker\Factory::create();
$faker->seed(737800);
srand(737800);

$our_man = "88811";
$our_man_address = "Langelinie Allé 21, 2100 København, Danmark (55.698056, 12.599945)";
$our_man_ip = "10.0.1.233, 10.0.4.18";

$employees = array();
for ($i = 0; $i < rand(500, 5000); $i++) {
	$devices = array();
	for ($j = 0; $j < rand(0, 6); $j++) {
		$devices[] = $faker->localIpv4();
	}
	$employees[rand(5000, 800000)] = array(
		"first_name" => $faker->firstName(),
		"last_name" => $faker->lastName(),
		"date_of_birth" => $faker->date("Y-m-d", "-20years"),
		"address" => $faker->address() . " (" . $faker->latitude() . ", " . $faker->longitude() . ")",
		"devices" => $devices,
	);
}

function make_mail($emp) {
	return strtolower($emp['first_name']) . "." . strtolower($emp['last_name']) . "@bigcomp.com";
}

?>
<!doctype html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Employee Record System</title>
</head>
<body>
<?php
if (isset($_GET['page']) && array_key_exists($_GET['page'], $employees)) {
	$id = $_GET['page'];
	$employee = $employees[$id]; ?>
	<a href="/">Back</a>
	<h1><?=$employee['first_name']?> <?=$employee['last_name']?></h1>
	<table>
		<tr>
			<th>ID</th>
			<td><?=$id?></td>
		</tr>
		<tr>
			<th>Date of birth</th>
			<td><?=$employee['date_of_birth']?></td>
		</tr>
		<tr>
			<th>Email</th>
			<td><?=make_mail($employee)?></td>
		</tr>
		<tr>
			<th>Address (GPS)</th>
			<td>
				<address>
					<?php if ($id === $our_man) {
						echo $our_man_address;
					} else {
						echo $employee['address'];
					} ?>
				</address>
			</td>
		</tr>
		<tr>
			<th>Registered device IPs</th>
			<td>
				<?php if ($id === $our_man) {
					echo $our_man_ip;
				} else {
					echo implode(", ", $employee['devices']);
				} ?>
			</td>
		</tr>
	</table>
<?php } else { ?>
	<h1>Employee Record System</h1>
	<table>
		<thead>
			<tr>
				<th>ID</th>
				<th>First name</th>
				<th>Last name</th>
				<th>Year of birth</th>
				<th>Email</th>
			</tr>
		</thead>
		<tbody>
			<?php foreach ($employees as $id => $employee) { ?>
				<tr>
					<td><a href="?page=<?=$id?>"><?=$id?></a></td>
					<td><?=$employee['first_name']?></td>
					<td><?=$employee['last_name']?></td>
					<td><?=substr($employee['date_of_birth'], 0, 4)?></td>
					<td><?=make_mail($employee)?></td>
				</tr>
			<?php } ?>
		</tbody>
	</table>
	<span>Total <?=count($employees)?> employees</span>
<?php } ?>
</body>
</html>
