<?php
// services/add.php
include '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    
    try {
        $stmt = $pdo->prepare("INSERT INTO service_requests (resident_id, service_type, description, status) VALUES (?, ?, ?, ?)");
        $stmt->execute([
            $data['resident_id'] ?? '',
            $data['service_type'] ?? '',
            $data['description'] ?? '',
            $data['status'] ?? 'pending'
        ]);
        
        echo json_encode(["success" => true, "message" => "Service request added successfully"]);
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "error" => $e->getMessage()]);
    }
}
?>