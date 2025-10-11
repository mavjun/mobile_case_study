<?php
// Allow requests from any origin (for dev)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

include '../config/db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);
$user_id = $data['user_id'] ?? null;
$current_password = $data['current_password'] ?? '';
$new_password = $data['new_password'] ?? '';

if (!$user_id || !$current_password || !$new_password) {
    echo json_encode(["success" => false, "error" => "Missing required fields"]);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT password FROM users WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    if (!$user || !password_verify($current_password, $user['password'])) {
        echo json_encode(["success" => false, "error" => "Current password is incorrect"]);
        exit();
    }

    $hashed_new = password_hash($new_password, PASSWORD_DEFAULT);
    $update = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
    $update->bind_param("si", $hashed_new, $user_id);
    if ($update->execute()) {
        echo json_encode(["success" => true, "message" => "Password updated successfully"]);
    } else {
        echo json_encode(["success" => false, "error" => "Failed to update password"]);
    }
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
