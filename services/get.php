<?php
// services/get.php
include '../config/db_connect.php';

$sql = "SELECT sr.*, br.first_name, br.last_name 
        FROM service_requests sr 
        LEFT JOIN barangay_residents br ON sr.resident_id = br.id";
$result = $conn->query($sql);

if ($result) {
    $services = [];
    while ($row = $result->fetch_assoc()) {
        $services[] = $row;
    }
    echo json_encode(["success" => true, "data" => $services]);
} else {
    echo json_encode(["success" => false, "error" => $conn->error]);
}

$conn->close();
?>