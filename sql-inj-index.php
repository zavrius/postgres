<?php
$conn = pg_connect("host=localhost port=5432 dbname=dbms1 user=postgres password=postgres");

$first_name = $_GET['first_name'] ?? '';
$query = "SELECT * FROM persons WHERE first_name = '$first_name'";  // небезопасно для обучения

$result = pg_query($conn, $query);

while($row = pg_fetch_assoc($result)){
    echo $row['first_name'] . " " . $row['last_name'] . " (" . $row['age'] . ")<br>";
}
?>


# Это index.php для SQL-injection
# curl "http://localhost/testapp/index.php?first_name=John"
# curl "http://localhost/testapp/index.php?first_name=John%27%20OR%20%271%27%3D%271"
# curl "http://localhost/testapp/index.php?first_name=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "John' OR '1'='1")"