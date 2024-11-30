<?php
// Database credentials
$host = 'db'; //This can be a url, here it is an alias for localhost set in /etc/hosts
$dbname = 'db_name';
$username = 'db_user';
$password = 'db_user_password';


$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


/* TODO: Replace old SQL connector with modern PDO and prepared statements.*/
?>

