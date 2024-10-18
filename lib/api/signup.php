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
        
        $schoolId = isset($input['users_school_id']) ? $input['users_school_id'] : '';
        $password = isset($input['users_password']) ? $input['users_password'] : '';
        $firstName = isset($input['users_firstname']) ? $input['users_firstname'] : '';
        $middleName = isset($input['users_middlename']) ? $input['users_middlename'] : '';
        $lastName = isset($input['users_lastname']) ? $input['users_lastname'] : '';
        $suffix = isset($input['users_suffix']) ? $input['users_suffix'] : '';
        $schoolIdFK = isset($input['users_schoolId']) ? $input['users_schoolId'] : '';
        $departmentId = isset($input['users_departmantId']) ? $input['users_departmantId'] : '';
        $roleId = '2';
        $status = '0';

        // Validate input
        if (empty($schoolId) || empty($password) || empty($firstName) || empty($lastName) || empty($schoolIdFK) || empty($departmentId) || empty($roleId)) {
            echo json_encode(['success' => false, 'message' => 'All required fields must be filled']);
            exit;
        }

        // Check if the school ID already exists
        $stmt = $pdo->prepare("SELECT * FROM tbl_users WHERE users_school_id = ?");
        $stmt->execute([$schoolId]);
        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => false, 'message' => 'School ID already exists']);
            exit;
        }

        // Use the password as-is without hashing
        $hashedPassword = $password;

        // Prepare SQL statement to insert new user
        $stmt = $pdo->prepare("INSERT INTO tbl_users (users_school_id, users_password, users_firstname, users_middlename, users_lastname, users_suffix, users_schoolId, users_departmantId, users_roleId, users_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        // Execute the statement
        if ($stmt->execute([$schoolId, $hashedPassword, $firstName, $middleName, $lastName, $suffix, $schoolIdFK, $departmentId, $roleId, $status])) {
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
