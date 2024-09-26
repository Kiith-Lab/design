<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Include the database connection file
include 'db_connection.php';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "SELECT school_id, school_name FROM tbl_school ORDER BY school_id ASC";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $schools = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($schools)) {
        // If no schools are found, return an empty array instead of null
        echo json_encode([]);
    } else {
        echo json_encode($schools);
    }
} catch(PDOException $e) {
    error_log("Database error: " . $e->getMessage());
    echo json_encode(['error' => 'Database error occurred']);
} catch(Exception $e) {
    error_log("General error: " . $e->getMessage());
    echo json_encode(['error' => 'An error occurred']);
}
