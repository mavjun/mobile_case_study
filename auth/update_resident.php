<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database connection
include '../config/db_connect.php';

// Get the raw POST data
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Check if JSON decoding was successful
if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(["success" => false, "error" => "Invalid JSON data"]);
    exit();
}

// Check if required fields are present
if (!isset($data['email'])) {
    echo json_encode(["success" => false, "error" => "Email is required"]);
    exit();
}

try {
    // Check if resident exists by email
    $checkStmt = $conn->prepare("SELECT resident_id FROM barangay_residents WHERE email = ?");
    $checkStmt->bind_param("s", $data['email']);
    $checkStmt->execute();
    $checkResult = $checkStmt->get_result();
    $existingResident = $checkResult->fetch_assoc();
    $checkStmt->close();

    if ($existingResident) {
        // Update existing resident
        $stmt = $conn->prepare("UPDATE barangay_residents SET 
            barangay_name = ?, first_name = ?, middle_name = ?, last_name = ?, 
            date_of_birth = ?, gender = ?, contact_number = ?, 
            address = ?, civil_status = ?, occupation = ?, updated_at = CURRENT_DATE 
            WHERE email = ?");
        
        $stmt->bind_param("sssssssssss", 
            $data['barangay_name'], $data['first_name'], $data['middle_name'], 
            $data['last_name'], $data['date_of_birth'], $data['gender'], 
            $data['contact_number'], $data['address'], 
            $data['civil_status'], $data['occupation'], $data['email']
        );
        
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "resident_id" => $existingResident['resident_id']]);
        } else {
            echo json_encode(["success" => false, "error" => "Failed to update resident: " . $stmt->error]);
        }
        
        $stmt->close();
    } else {
        // Create new resident
        $stmt = $conn->prepare("INSERT INTO barangay_residents (
            barangay_name, first_name, middle_name, last_name, 
            date_of_birth, gender, contact_number, email, 
            address, civil_status, occupation, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, CURRENT_DATE)");
        
        $stmt->bind_param("sssssssssss", 
            $data['barangay_name'], $data['first_name'], $data['middle_name'], 
            $data['last_name'], $data['date_of_birth'], $data['gender'], 
            $data['contact_number'], $data['email'], $data['address'], 
            $data['civil_status'], $data['occupation']
        );
        
        if ($stmt->execute()) {
            $new_resident_id = $conn->insert_id;
            echo json_encode(["success" => true, "resident_id" => $new_resident_id]);
        } else {
            echo json_encode(["success" => false, "error" => "Failed to create resident record: " . $stmt->error]);
        }
        
        $stmt->close();
    }
} catch(Exception $e) {
    echo json_encode(["success" => false, "error" => "Database error: " . $e->getMessage()]);
}

$conn->close();
?>