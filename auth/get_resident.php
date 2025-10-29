<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include '../config/db_connect.php';

// Get email from query parameter
$email = $_GET['email'] ?? null;

if (!$email) {
    echo json_encode(["success" => false, "error" => "Email parameter missing"]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT * FROM barangay_residents WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $resident = $result->fetch_assoc();
    
    if ($resident) {
        echo json_encode([
            "success" => true, 
            "resident" => $resident
        ]);
    } else {
        echo json_encode(["success" => false, "error" => "Resident not found"]);
    }
    
    $stmt->close();
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}

$conn->close();
?>