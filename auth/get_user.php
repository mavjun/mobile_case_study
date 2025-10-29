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
    // Select only the columns that exist in your database
    $stmt = $conn->prepare("SELECT name, email, address, birthday, gender, years_of_residency, valid_id_path, role, approval_status FROM users WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    
    if ($user) {
        echo json_encode([
            "success" => true, 
            "user" => [
                "name" => $user['name'],
                "email" => $user['email'],
                "address" => $user['address'] ?? 'Not provided',
                "birthday" => $user['birthday'] ?? 'Not provided',
                "gender" => $user['gender'] ?? 'Not provided',
                "years_of_residency" => $user['years_of_residency'] ?? '0',
                "valid_id_path" => $user['valid_id_path'] ?? '',
                "role" => $user['role'] ?? 'resident',
                "approval_status" => $user['approval_status'] ?? 'pending'
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "error" => "User not found"]);
    }
    
    $stmt->close();
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}

$conn->close();
?>