<?php
header("Content-Type: application/json");
include_once "../config/db_connect.php";

$sql = "SELECT * FROM barangay_residents"; // your table
$result = $conn->query($sql);

$residents = [];
while ($row = $result->fetch_assoc()) {
    $residents[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $residents
]);
?>
