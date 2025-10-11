<?php
// documents/get.php
include '../config/db_connect.php';

try {
    $stmt = $pdo->query("SELECT * FROM documents");
    $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode(["success" => true, "data" => $documents]);
} catch(PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>