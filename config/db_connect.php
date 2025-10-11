<?php
$host = "127.0.0.1:3307";
$user = "root";
$pass = ""; // since phpMyAdmin logs in automatically
$db   = "system_integ_db"; // <-- correct database name

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}
?>
