<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // ✅ Use $_POST for text fields (since we’ll use multipart/form-data)
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = password_hash($_POST['password'] ?? '', PASSWORD_DEFAULT);
    $phone_number = $_POST['phone_number'] ?? '';
    $address = $_POST['address'] ?? '';
    $barangay_residency_year = $_POST['barangay_residency_year'] ?? '';
    $birth_date = $_POST['birth_date'] ?? ''; // Optional, if still included

    // ✅ Handle file upload (Valid ID)
    $upload_dir = "../uploads/valid_ids/";
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    $valid_id_path = null;

    if (isset($_FILES['valid_id']) && $_FILES['valid_id']['error'] === UPLOAD_ERR_OK) {
        $file_tmp = $_FILES['valid_id']['tmp_name'];
        $file_name = time() . "_" . basename($_FILES['valid_id']['name']);
        $file_path = $upload_dir . $file_name;

        if (move_uploaded_file($file_tmp, $file_path)) {
            $valid_id_path = "uploads/valid_ids/" . $file_name; // Relative path
        } else {
            echo json_encode(["success" => false, "error" => "Failed to upload Valid ID."]);
            exit();
        }
    }

    try {
        // Check if email already exists
        $check_stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $check_stmt->bind_param("s", $email);
        $check_stmt->execute();
        $check_result = $check_stmt->get_result();

        if ($check_result->num_rows > 0) {
            echo json_encode(["success" => false, "error" => "Email already exists"]);
            exit();
        }

        // ✅ Insert user with valid_id and residency year
        $stmt = $conn->prepare("
            INSERT INTO users (name, email, password, phone_number, address, valid_id, barangay_residency_year, birth_date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->bind_param("ssssssss", $name, $email, $password, $phone_number, $address, $valid_id_path, $barangay_residency_year, $birth_date);

        if ($stmt->execute()) {
            session_start();
            $_SESSION['user_id'] = $stmt->insert_id;
            $_SESSION['user_email'] = $email;
            $_SESSION['user_name'] = $name;

            echo json_encode(["success" => true, "message" => "User registered successfully"]);
        } else {
            echo json_encode(["success" => false, "error" => "Registration failed"]);
        }
    } catch (Exception $e) {
        echo json_encode(["success" => false, "error" => $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "error" => "Invalid request method"]);
}
?>
