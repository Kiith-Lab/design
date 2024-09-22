<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection (ensure this file exists and has the correct PDO object)
include 'db_connection.php';

class Get
{
    private $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    function addList()
    {
        $frontId = isset($_POST['front_card_id']) ? $_POST['front_card_id'] : '';
        $backId = isset($_POST['back_card_id']) ? $_POST['back_card_id'] : '';
        $folderDate = isset($_POST['folder_date']) ? $_POST['folder_date'] : '';
        $folderName = isset($_POST['folder_name']) ? $_POST['folder_name'] : '';
        try {
            $sql = "INSERT INTO tbl_list (
            folder_name,
            folder_date,
            front_card_id,
            back_card_id
            ) VALUES (
            :folder_name,
            :folder_date,
            :front_card_id,
            :back_card_id)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':folder_name', $folderName, PDO::PARAM_STR);
            $stmt->bindParam(':folder_date', $folderDate, PDO::PARAM_STR);
            $stmt->bindParam(':front_card_id', $frontId, PDO::PARAM_INT);
            $stmt->bindParam(':back_card_id', $backId, PDO::PARAM_INT);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred']);
        }
    }
    function addfolder($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_folder (
            folder_name,
            folder_date
            ) VALUES (
            :folder_name,
            :folder_date)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':folder_name', $json['folder_name'], PDO::PARAM_STR);
            $stmt->bindParam(':folder_date', $json['folder_date'], PDO::PARAM_STR);

            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();
            return json_encode(['success' => true, 'id' => $lastInsertId]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
    function addProject($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_project(
            project_userId,
            project_subject_code,
            project_subject_description,
            project_title,
            project_description,
            project_start_date,
            project_end_date
            ) VALUES (
            :project_userId,
            :project_subject_code,
            :project_subject_description,
            :project_title,
            :project_description,
            :project_start_date,
            :project_end_date)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':project_userId', $json['project_userId'], PDO::PARAM_INT);
            $stmt->bindParam(':project_subject_code', $json['project_subject_code'], PDO::PARAM_STR);
            $stmt->bindParam(':project_subject_description', $json['project_subject_description'], PDO::PARAM_STR);
            $stmt->bindParam(':project_title', $json['project_title'], PDO::PARAM_STR);
            $stmt->bindParam(':project_description', $json['project_description'], PDO::PARAM_STR);
            $stmt->bindParam(':project_start_date', $json['project_start_date'], PDO::PARAM_STR);
            $stmt->bindParam(':project_end_date', $json['project_end_date'], PDO::PARAM_STR);

            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();
            return json_encode(['success' => true, 'id' => $lastInsertId]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
    function addActs($json)
    {
        $decodedJson = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            error_log("JSON decode error: " . json_last_error_msg());
            return json_encode(['error' => 'Invalid JSON: ' . json_last_error_msg()]);
        }
        
        try {
            $this->pdo->beginTransaction();

            // Insert into tbl_project_modules
            $sql1 = "INSERT INTO tbl_project_modules (
                project_modules_projectId,	
                project_modules_masterId
                ) VALUES (:project_modules_projectId, :project_modules_masterId)";
            $stmt1 = $this->pdo->prepare($sql1);
            $stmt1->bindParam(':project_modules_projectId', $decodedJson['project_modules_projectId'], PDO::PARAM_INT);
            $stmt1->bindParam(':project_modules_masterId', $decodedJson['project_modules_masterId'], PDO::PARAM_INT);
            $stmt1->execute();
            
            $projectModulesId = $this->pdo->lastInsertId();
            error_log("Saved projectModulesId: " . $projectModulesId);
                
            // Insert into tbl_activities_header
            $sql2 = "INSERT INTO tbl_activities_header(
                activities_header_modulesId,
                activities_header_duration
                ) VALUES (:activities_header_modulesId, :activities_header_duration)";
            $stmt2 = $this->pdo->prepare($sql2);
            $stmt2->bindParam(':activities_header_modulesId', $projectModulesId, PDO::PARAM_INT);
            $stmt2->bindParam(':activities_header_duration', $decodedJson['activities_header_duration'], PDO::PARAM_STR);
            $stmt2->execute();

            $activitiesHeaderId = $this->pdo->lastInsertId();
            error_log("Saved activitiesHeaderId: " . $activitiesHeaderId);

            // Insert into tbl_activities_details
            $sql3 = "INSERT INTO tbl_activities_details(
                activities_details_content,
                activities_details_headerId,
                activities_details_remarks
                ) VALUES (:activities_details_content, :activities_details_headerId, :activities_details_remarks)";
            $stmt3= $this->pdo->prepare($sql3);
            $stmt3->bindParam(':activities_details_content', $decodedJson['activities_details_content'], PDO::PARAM_STR);
            $stmt3->bindParam(':activities_details_headerId', $activitiesHeaderId, PDO::PARAM_INT);
            $stmt3->bindParam(':activities_details_remarks', $decodedJson['activities_details_remarks'] ?? '', PDO::PARAM_STR);
            $stmt3->execute();

            // Insert into tbl_project_cards
            $sql4 = "INSERT INTO tbl_project_cards(	
                project_cards_modulesId,
                project_cards_cardId
                ) VALUES (:project_cards_modulesId, :project_cards_cardId)";
            $stmt4 = $this->pdo->prepare($sql4);
            $stmt4->bindParam(':project_cards_modulesId', $projectModulesId, PDO::PARAM_INT);
            $stmt4->bindParam(':project_cards_cardId', $decodedJson['project_cards_cardId'], PDO::PARAM_INT);
            $stmt4->execute();

            // Insert into tbl_outputs
            $sql5 = "INSERT INTO tbl_outputs(
                outputs_moduleId,
                outputs_content
                ) VALUES (:outputs_moduleId, :outputs_content)";
            $stmt5 = $this->pdo->prepare($sql5);
            $stmt5->bindParam(':outputs_moduleId', $projectModulesId, PDO::PARAM_INT);
            $stmt5->bindParam(':outputs_content', $decodedJson['outputs_content'], PDO::PARAM_STR);
            $stmt5->execute();

            // Insert into tbl_instruction
            $sql6 = "INSERT INTO tbl_instruction(
                instruction_modulesId,
                instruction_content
                ) VALUES (:instruction_modulesId, :instruction_content)";
            $stmt6 = $this->pdo->prepare($sql6);
            $stmt6->bindParam(':instruction_modulesId', $projectModulesId, PDO::PARAM_INT);
            $stmt6->bindParam(':instruction_content', $decodedJson['instruction_content'], PDO::PARAM_STR);
            $stmt6->execute();

            $this->pdo->commit();

            return json_encode(['success' => true, 'id' => $projectModulesId]);
        } catch (PDOException $e) {
            $this->pdo->rollBack();
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
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

// Instantiate the Get class with the database connection
$get = new Get($pdo);

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
    case "addActs":
        echo $get->addActs($json);
        break;
    case "addList":
        echo $get->addList();
        break;
    case "addfolder":
        echo $get->addfolder($json);
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
    case "addProject":
        echo $get->addProject($json);
        break;

}
