<?php
// Include database connection file
require_once 'db_connection.php';

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Allow cross-origin requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve username and password from the POST data
    $input = json_decode(file_get_contents('php://input'), true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit;
    }
    $username = isset($input['users_school_id']) ? $input['users_school_id'] : '';
    $password = isset($input['users_password']) ? $input['users_password'] : '';

    // Validate input
    if (empty($username) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Username and password are required']);
        exit;
    }

    // Prepare SQL statement to prevent SQL injection
    $stmt = $pdo->prepare("SELECT users_id, users_school_id, users_password, users_roleId FROM tbl_users WHERE users_school_id = :users_school_id AND users_status != 0 AND register_status != 0");
    $stmt->bindParam(':users_school_id', $username, PDO::PARAM_STR);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Verify the password (use password_verify for hashed passwords)
        if ($password === $user['users_password']) {
            // Password is correct, create a session
            session_start();
            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'users_id' => $user['users_id'],
                    'users_school_id' => $user['users_school_id'],
                    'users_roleId' => $user['users_roleId']
                ]
            ]);
        } else {
            // Password is incorrect
            echo json_encode(['success' => false, 'message' => 'Invalid username or password']);
        }
    } else {
        // User not found
        echo json_encode(['success' => false, 'message' => 'Invalid username or password']);
    }
} else {
    // If the request method is not POST
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}
?>
