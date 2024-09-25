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

    function updateActivity($json)
    {
        $data = json_decode($json, true);
        error_log("updateActivity called with data: " . print_r($data, true));
        try {
            $sql = "UPDATE tbl_activities_details 
                    SET activities_details_content = :content 
                    WHERE activities_details_id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':content', json_encode($data['activities']), PDO::PARAM_STR);
            $stmt->bindParam(':id', $data['activityId'], PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => 'Activity updated successfully']);
            } else {
                // If no rows were updated, insert a new record
                $insertSql = "INSERT INTO tbl_activities_details (activities_details_content, activities_details_headerId) 
                              VALUES (:content, :headerId)";
                $insertStmt = $this->pdo->prepare($insertSql);
                $insertStmt->bindParam(':content', json_encode($data['activities']), PDO::PARAM_STR);
                $insertStmt->bindParam(':headerId', $data['headerId'], PDO::PARAM_INT);
                $insertStmt->execute();

                if ($insertStmt->rowCount() > 0) {
                    $newId = $this->pdo->lastInsertId();
                    return json_encode(['success' => true, 'message' => 'New activity added successfully', 'id' => $newId]);
                } else {
                    return json_encode(['success' => false, 'error' => 'Failed to add new activity']);
                }
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function updateOutput($json)
    {
        $data = json_decode($json, true);
        error_log("updateOutput called with data: " . print_r($data, true));
        try {
            $sql = "UPDATE tbl_outputs 
                    SET outputs_content = :content 
                    WHERE outputs_id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':content', json_encode($data['outputs']), PDO::PARAM_STR);
            $stmt->bindParam(':id', $data['outputId'], PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => 'Output updated successfully']);
            } else {
                // If no rows were updated, insert a new record
                $insertSql = "INSERT INTO tbl_outputs (outputs_content, outputs_moduleId) 
                              VALUES (:content, :moduleId)";
                $insertStmt = $this->pdo->prepare($insertSql);
                $insertStmt->bindParam(':content', json_encode($data['outputs']), PDO::PARAM_STR);
                $insertStmt->bindParam(':moduleId', $data['moduleId'], PDO::PARAM_INT);
                $insertStmt->execute();

                if ($insertStmt->rowCount() > 0) {
                    $newId = $this->pdo->lastInsertId();
                    return json_encode(['success' => true, 'message' => 'New output added successfully', 'id' => $newId]);
                } else {
                    return json_encode(['success' => false, 'error' => 'Failed to add new output']);
                }
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function updateInstruction($json)
    {
        $data = json_decode($json, true);
        error_log("updateInstruction called with data: " . print_r($data, true));
        try {
            $sql = "UPDATE tbl_instruction 
                    SET instruction_content = :content 
                    WHERE instruction_id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':content', json_encode($data['instructions']), PDO::PARAM_STR);
            $stmt->bindParam(':id', $data['instructionId'], PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => 'Instruction updated successfully']);
            } else {
                // If no rows were updated, insert a new record
                $insertSql = "INSERT INTO tbl_instruction (instruction_content, instruction_modulesId) 
                              VALUES (:content, :moduleId)";
                $insertStmt = $this->pdo->prepare($insertSql);
                $insertStmt->bindParam(':content', json_encode($data['instructions']), PDO::PARAM_STR);
                $insertStmt->bindParam(':moduleId', $data['moduleId'], PDO::PARAM_INT);
                $insertStmt->execute();

                if ($insertStmt->rowCount() > 0) {
                    $newId = $this->pdo->lastInsertId();
                    return json_encode(['success' => true, 'message' => 'New instruction added successfully', 'id' => $newId]);
                } else {
                    return json_encode(['success' => false, 'error' => 'Failed to add new instruction']);
                }
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function updateCoachDetail($json)
    {
        $data = json_decode($json, true);
        error_log("updateCoachDetail called with data: " . print_r($data, true));
        try {
            $sql = "UPDATE tbl_coach_detail 
                    SET coach_detail_content = :content 
                    WHERE coach_detail_id = :id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':content', json_encode($data['coachDetails']), PDO::PARAM_STR);
            $stmt->bindParam(':id', $data['coachDetailId'], PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => 'Coach detail updated successfully']);
            } else {
                // If no rows were updated, insert a new record
                $insertSql = "INSERT INTO tbl_coach_detail (coach_detail_content, coach_detail_coachheaderId) 
                              VALUES (:content, :headerId)";
                $insertStmt = $this->pdo->prepare($insertSql);
                $insertStmt->bindParam(':content', json_encode($data['coachDetails']), PDO::PARAM_STR);
                $insertStmt->bindParam(':headerId', $data['coachHeaderId'], PDO::PARAM_INT);
                $insertStmt->execute();

                if ($insertStmt->rowCount() > 0) {
                    $newId = $this->pdo->lastInsertId();
                    return json_encode(['success' => true, 'message' => 'New coach detail added successfully', 'id' => $newId]);
                } else {
                    return json_encode(['success' => false, 'error' => 'Failed to add new coach detail']);
                }
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
}

// Handle preflight requests for CORS (for OPTIONS request)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Instantiate the Update class with the database connection
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
    case "updateActivity":
        echo $update->updateActivity($json);
        break;
    case "updateOutput":
        echo $update->updateOutput($json);
        break;
    case "updateInstruction":
        echo $update->updateInstruction($json);
        break;
    case "updateCoachDetail":
        echo $update->updateCoachDetail($json);
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}
// End of Selection
