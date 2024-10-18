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

try {
    // Check if the request method is POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Retrieve user data from the POST request
        $input = json_decode(file_get_contents('php://input'), true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON format');
        }
        
        // Extract user data
        $fields = [
            'users_school_id',
            'users_password',
            'users_firstname',
            'users_middlename',
            'users_lastname',
            'users_suffix',
            'users_schoolId',
            'users_departmantId',
            'user_email' // Added user_email
        ];
        $userData = [];
        foreach ($fields as $field) {
            $userData[$field] = $input[$field] ?? '';
        }
        
        // Additional default values
        $userData['users_roleId'] = '2';
        $userData['users_status'] = '1';
        $userData['register_status'] = '0';

        // Validate input
        foreach (['users_school_id', 'users_password', 'users_firstname', 'users_lastname', 'users_schoolId', 'users_departmantId', 'user_email'] as $requiredField) {
            if (empty($userData[$requiredField])) {
                echo json_encode(['success' => false, 'message' => 'All required fields must be filled']);
                exit;
            }
        }

        // Check if the school ID already exists
        $stmt = $pdo->prepare("SELECT 1 FROM tbl_users WHERE users_school_id = :schoolId");
        $stmt->execute([':schoolId' => $userData['users_school_id']]);
        if ($stmt->fetchColumn()) {
            echo json_encode(['success' => false, 'message' => 'School ID already exists']);
            exit;
        }

        // Prepare SQL statement to insert new user
        $stmt = $pdo->prepare("
            INSERT INTO tbl_users (users_school_id, users_password, users_firstname, users_middlename, users_lastname, users_suffix, users_schoolId, users_departmantId, user_email, users_roleId, users_status, register_status) 
            VALUES (:schoolId, :password, :firstname, :middlename, :lastname, :suffix, :schoolIdFK, :departmentId, :email, :roleId, :userStatus, :registerStatus)
        ");

        // Execute the statement
        if ($stmt->execute([
            ':schoolId' => $userData['users_school_id'],
            ':password' => $userData['users_password'], 
            ':firstname' => $userData['users_firstname'],
            ':middlename' => $userData['users_middlename'],
            ':lastname' => $userData['users_lastname'],
            ':suffix' => $userData['users_suffix'],
            ':schoolIdFK' => $userData['users_schoolId'],
            ':departmentId' => $userData['users_departmantId'],
            ':email' => $userData['user_email'],
            ':roleId' => $userData['users_roleId'],
            ':userStatus' => $userData['users_status'],
            ':registerStatus' => $userData['register_status']
        ])) {
            echo json_encode(['success' => true, 'message' => 'User registered successfully']);
        } else {
            throw new Exception('Registration failed');
        }
    } else {
        // If the request method is not POST
        echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    }
} catch (Exception $e) {
    // Catch any exceptions and return them as JSON
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
