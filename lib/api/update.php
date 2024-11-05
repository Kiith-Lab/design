<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

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
            $users_id = isset($_POST['users_id']) ? $_POST['users_id'] : '';

            if (empty($users_id)) {
                return json_encode(['error' => 'Invalid user ID']);
            }

            $sql = "UPDATE tbl_users SET users_status = CASE WHEN users_status = 0 THEN 1 ELSE 0 END WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $users_id, PDO::PARAM_STR);
            $stmt->execute();

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

    function editUserNames()
    {
        try {
            $users_id = isset($_POST['users_id']) ? $_POST['users_id'] : '';
            $firstname = isset($_POST['users_firstname']) ? $_POST['users_firstname'] : '';
            $middlename = isset($_POST['users_middlename']) ? $_POST['users_middlename'] : '';
            $lastname = isset($_POST['users_lastname']) ? $_POST['users_lastname'] : '';

            if (empty($users_id) || empty($firstname) || empty($middlename) || empty($lastname)) {
                return json_encode(['error' => 'Invalid input']);
            }

            $sql = "UPDATE tbl_users 
                    SET users_firstname = :firstname, 
                        users_middlename = :middlename, 
                        users_lastname = :lastname 
                    WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $users_id, PDO::PARAM_STR);
            $stmt->bindParam(':firstname', $firstname, PDO::PARAM_STR);
            $stmt->bindParam(':middlename', $middlename, PDO::PARAM_STR);
            $stmt->bindParam(':lastname', $lastname, PDO::PARAM_STR);
            $stmt->execute();

            $sql = "SELECT * FROM tbl_users WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $users_id, PDO::PARAM_STR);
            $stmt->execute();
            $returnValue = $stmt->fetch(PDO::FETCH_ASSOC);

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

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$update = new Update($pdo);

$json = isset($_POST['json']) ? $_POST['json'] : '';
$operation = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $operation = isset($_POST['operation']) ? $_POST['operation'] : '';
} else {
    echo json_encode(['error' => 'Invalid request method']);
    exit;
}

switch ($operation) {
    case 'updateUser':
        echo $update->updateUser();
        break;
    case 'editUserNames':
        echo $update->editUserNames();
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}
?>