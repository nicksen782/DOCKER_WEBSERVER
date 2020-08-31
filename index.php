<!doctype html>
<html lang="en">

<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="">
	<meta name="author" content="Nickolas Andersen (nicksen782)">

	<link rel="icon" href="data:;base64,iVBORwOKGO=" />

	<title>File Browser</title>

	<style>
		body{
			background-color:black;
			width:700px;
			margin: 5px auto;
		}
		#tableDiv{
			border: 4px double darkgray;
			border-radius: 10px;
			width: 600px;
			padding: 3px;
			background-color: gray;
		}
		table{
			background-color:beige;
			width:100%;
			border-radius: 0px 0px 5px 5px;
		}
		table th{
			text-decoration:underline;
			text-align:left;
		}
		caption{
			background-color:darkkhaki;
			border-radius: 5px 5px 0px 0px;
		}
	</style>

</head>

<body>

<?php
// https://stackoverflow.com/a/18602474/2731377
function time_elapsed_string($datetime, $full = false) {
    $now = new DateTime;
    $ago = new DateTime($datetime);
    $diff = $now->diff($ago);

    $diff->w = floor($diff->d / 7);
    $diff->d -= $diff->w * 7;

    $string = array(
        'y' => 'year',
        'm' => 'month',
        'w' => 'week',
        'd' => 'day',
        'h' => 'hour',
        'i' => 'minute',
        's' => 'second',
    );
    foreach ($string as $k => &$v) {
        if ($diff->$k) {
            $v = $diff->$k . ' ' . $v . ($diff->$k > 1 ? 's' : '');
        } else {
            unset($string[$k]);
        }
    }

    if (!$full) $string = array_slice($string, 0, 1);
    return $string ? implode(', ', $string) . ' ago' : 'just now';
}

function createFileTable($data, $caption){
	$html = "";
	$html .= "<div id='tableDiv'>";

	// Headers
	$html .= "<table>\n";
	$html .= " <caption>$caption</caption>";
	$html .= " <thead>\n";
	$html .= "  <tr>";
	$html .= "   <th>Name</th>";
	$html .= "   <th>Last Modified</th>";
	$html .= "   <th>Last Modified Date/Time</th>";
	$html .= "  </tr>\n";
	$html .= " </thead>\n";
	$html .= " <tbody>\n";

	// Rows
	foreach($data as $rec) {
		$html .= " <tr>\n";
		$html .= "  <td><a href='".rawurlencode($rec['name'])."'>".$rec['name']."</a></td>\n";
		$html .= "  <td>" . $rec['age']     ."</td>\n";
		$html .= "  <td>" . $rec['lastmod'] ."</td>\n";
		$html .= " </tr>\n";
	}
	unset($rec);

	// Bottom
	$html .= " </tbody>\n";
	$html .= "</table>\n\n";

	$html .= "</div>";

	return $html;
}

$pwd = getcwd();
$allFiles = scandir($pwd, 1);
natcasesort($allFiles);
$files = [];
$dirs  = [];
$notAllowed=[ ".", "..", "_docker_webserver" ];
foreach($allFiles as $file){
	if(!in_array($file, $notAllowed)){
		$is_dir = is_dir($file);

		$mtime = filemtime($file);
		$age   = time_elapsed_string("@".$mtime, false);

		$entry = [
			"name"    => $file,
			"age"     => $age,
			"lastmod" => date('h:i:s A F dS Y (l)', $mtime),
		];

		if($is_dir){ array_push($dirs , $entry); }
		else       { array_push($files, $entry); }
	}
}
unset($file);

echo createFileTable($dirs , "DIRECTORIES"); echo "<br>"; echo "<br>";
echo createFileTable($files, "FILES");       echo "<br>"; echo "<br>";

?>

</body>

</html>

