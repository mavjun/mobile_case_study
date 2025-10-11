<?php
// payments/add.php
include '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    
    try {
        $stmt = $pdo->prepare("INSERT INTO payments (service_request_id, amount, payment_date, status) VALUES (?, ?, ?, ?)");
        $stmt->execute([
            $data['service_request_id'] ?? '',
            $data['amount'] ?? '',
            $data['payment_date'] ?? date('Y-m-d'),
            $data['status'] ?? 'pending'
        ]);
        
        echo json_encode(["success" => true, "message" => "Payment added successfully"]);
    } catch(PDOException $e) {
        echo json_encode(["success" => false, "error" => $e->getMessage()]);
    }
}
?>