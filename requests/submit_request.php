<?php
header('Content-Type: application/json');

// Optional: disable notices/warnings
error_reporting(E_ALL & ~E_NOTICE & ~E_WARNING);

// Example: collect POST data
$user_id = $_POST['user_id'] ?? '';
$service_type = $_POST['service_type'] ?? '';
$purpose = $_POST['purpose'] ?? '';

// Simple validation
if (!$user_id || !$service_type || !$purpose) {
    echo json_encode(['success' => false, 'error' => 'Missing required fields']);
    exit;
}

// TODO: save request to database here

// Return success JSON
echo json_encode(['success' => true, 'message' => 'Request submitted successfully']);
