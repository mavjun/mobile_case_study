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

    // ✅ Use $_POST for text fields (since we're using multipart/form-data)
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $phone_number = $_POST['phone_number'] ?? '';
    $address = $_POST['address'] ?? '';
    $years_of_residency = $_POST['barangay_years'] ?? ''; // Fixed: matches Flutter field name

    // Validate required fields
    if (empty($name) || empty($email) || empty($password) || empty($phone_number) || empty($address) || empty($years_of_residency)) {
        echo json_encode(["success" => false, "error" => "All fields are required"]);
        exit();
    }

    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

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
    } else {
        echo json_encode(["success" => false, "error" => "Valid ID is required"]);
        exit();
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

        // ✅ Insert user with correct database column names
        $stmt = $conn->prepare("
            INSERT INTO users 
            (name, email, password, address, years_of_residency, valid_id_path, role, approval_status, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 'resident', 'pending', NOW(), NOW())
        ");
        
        // Fixed: using correct column names that match your database
        $stmt->bind_param("ssssis", $name, $email, $hashed_password, $address, $years_of_residency, $valid_id_path);

        if ($stmt->execute()) {
            echo json_encode([
                "success" => true, 
                "message" => "Registration successful! Your account is pending approval."
            ]);
        } else {
            echo json_encode(["success" => false, "error" => "Registration failed: " . $stmt->error]);
        }
        
        $stmt->close();
        $check_stmt->close();
        
    } catch (Exception $e) {
        echo json_encode(["success" => false, "error" => "Database error: " . $e->getMessage()]);
    }
    
    $conn->close();
} else {
    echo json_encode(["success" => false, "error" => "Invalid request method"]);
}
?>