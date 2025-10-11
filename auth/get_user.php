<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include '../config/db_connect.php';

// Get user ID from query parameter
$user_id = $_GET['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["success" => false, "error" => "User ID missing"]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT name, email, phone_number, address, birth_date FROM users WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    
    if ($user) {
        echo json_encode(["success" => true, "user" => $user]);
    } else {
        echo json_encode(["success" => false, "error" => "User not found"]);
    }
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
