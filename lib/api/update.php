<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection (ensure this file exists and has the correct PDO object)
include 'db_connection.php';

class Update
{
    private $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    function updateUser()
    {
        try {
            // Check if the 'users_id' is set in the POST data
            $users_id = isset($_POST['users_id']) ? $_POST['users_id'] : '';

            // Validate users_id
            if (empty($users_id)) {
                return json_encode(['error' => 'Invalid user ID']);
            }

            // SQL to toggle users_status between 0 and 1
            $sql = "UPDATE tbl_users SET users_status = CASE WHEN users_status = 0 THEN 1 ELSE 0 END WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $users_id, PDO::PARAM_STR);
            $stmt->execute();

            // Fetch and return the updated row to confirm the change
            $sql = "SELECT * FROM tbl_users WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $users_id, PDO::PARAM_STR);
            $stmt->execute();
            $returnValue = $stmt->fetch(PDO::FETCH_ASSOC);

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['error' => 'An error occurred']);
        }
    }


}
// Handle preflight requests for CORS (for OPTIONS request)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Instantiate the Get class with the database connection
$update = new Update($pdo);

$json = isset($_POST['json']) ? $_POST['json'] : '';
// Determine the request method and check for the operation
$operation = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $operation = isset($_POST['operation']) ? $_POST['operation'] : '';
} else {
    echo json_encode(['error' => 'Invalid request method']);
    exit;
}

// Handle different operations based on the request
switch ($operation) {

    case 'updateUser':
        echo $update->updateUser();
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}
