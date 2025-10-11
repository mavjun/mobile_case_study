<?php
// residents/add.php
include '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    
    try {
        $stmt = $pdo->prepare("INSERT INTO barangay_residents (first_name, last_name, address, contact_number, birth_date) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([
            $data['first_name'] ?? '',
            $data['last_name'] ?? '',
            $data['address'] ?? '',
            $data['contact_number'] ?? '',
            $data['birth_date'] ?? ''
        ]);
        
        echo json_encode(["success" => true, "message" => "Resident added successfully"]);
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "error" => $e->getMessage()]);
    }
}
?>