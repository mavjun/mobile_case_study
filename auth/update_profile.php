<?php
// auth/update_profile.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include '../config/db_connect.php';

// Read POST JSON
$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data['user_id'] ?? null;
$name = $data['name'] ?? '';
$email = $data['email'] ?? '';
$phone = $data['phone_number'] ?? '';
$address = $data['address'] ?? '';
$birth_date = $data['birth_date'] ?? '';

if (!$user_id) {
    echo json_encode(["success" => false, "error" => "User ID missing"]);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE users SET name=?, email=?, phone_number=?, address=?, birth_date=? WHERE id=?");
    $stmt->bind_param("sssssi", $name, $email, $phone, $address, $birth_date, $user_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
    } else {
        echo json_encode(["success" => false, "error" => "Failed to update profile"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
