<?php
// auth/login.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database connection
include '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get JSON input
    $input = file_get_contents("php://input");
    $data = json_decode($input, true);

    // Check if JSON decoding was successful
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Invalid JSON input"]);
        $conn->close();
        exit();
    }

    $email = isset($data['email']) ? trim($data['email']) : '';
    $password = isset($data['password']) ? $data['password'] : '';

    // Input validation
    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Email and password are required"]);
        $conn->close();
        exit();
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(["success" => false, "error" => "Please enter a valid email address"]);
        $conn->close();
        exit();
    }

    try {
        $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();

        // Check if user exists
        if (!$user) {
            http_response_code(401);
            echo json_encode([
                "success" => false, 
                "error" => "Account does not exist. Please check your email or register for a new account."
            ]);
            $stmt->close();
            $conn->close();
            exit();
        }

        // Check password
        if (!password_verify($password, $user['password'])) {
            http_response_code(401);
            echo json_encode([
                "success" => false, 
                "error" => "Incorrect password. Please try again."
            ]);
            $stmt->close();
            $conn->close();
            exit();
        }
            
        // Check if account is approved
        if ($user['approval_status'] !== 'approved') {
            $status = $user['approval_status'];
            
            if ($status === 'pending') {
                $message = "Your account is pending approval. Please wait for administrator approval.";
            } elseif ($status === 'declined') {
                $message = "Your account registration was declined.";
                if (!empty($user['decline_reason'])) {
                    $message .= " Reason: " . $user['decline_reason'];
                }
            } else {
                $message = "Account not approved. Current status: " . ucfirst($status);
            }
            
            http_response_code(403);
            echo json_encode([
                "success" => false, 
                "error" => $message
            ]);
            $stmt->close();
            $conn->close();
            exit();
        }
        
        // Login successful
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Login successful",
            "user" => [
                "id" => $user['id'],
                "email" => $user['email'],
                "name" => $user['name'],
                "role" => $user['role']
            ]
        ]);
        
        $stmt->close();
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["success" => false, "error" => "Database error"]);
    }

    $conn->close();
} else {
    http_response_code(405);
    echo json_encode(["success" => false, "error" => "Invalid request method"]);
}
?>