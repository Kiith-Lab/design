<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(['error' => 'Invalid JSON format']);
    exit;
}

if (!isset($data['operation']) || !isset($data['json'])) {
    echo json_encode(['error' => 'Missing operation or json key']);
    exit;
}

$operation = $data['operation'];
$json = $data['json'];

$pdo = include 'db_connection.php';

class Updates
{
    private $conn;

    public function __construct($dbConnection)
    {
        $this->conn = $dbConnection;
    }

    function updateActs($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['actId'], $json['currentValue'], $json['newValue'], $json['actRemark'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        // Decode the existing JSON array from the database
        $stmt = $this->conn->prepare("SELECT activities_details_content FROM tbl_activities_details WHERE activities_details_id = :actId");
        $stmt->bindParam(':actId', $json['actId']);
        $stmt->execute();
        $existingContent = $stmt->fetchColumn();

        $contentArray = json_decode($existingContent, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid existing JSON format']);
        }

        // Update the specific value in the array
        $indexToUpdate = array_search($json['currentValue'], $contentArray);
        if ($indexToUpdate !== false) {
            $contentArray[$indexToUpdate] = $json['newValue'];
        } else {
            return json_encode(['error' => 'Current value not found']);
        }

        // Encode the updated array back to JSON
        $updatedContent = json_encode($contentArray);

        $sql = "UPDATE tbl_activities_details SET activities_details_content = :actContent, 
                activities_details_remarks = :actRemark
                WHERE activities_details_id = :actId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':actId', $json['actId']);
            $stmt->bindParam(':actContent', $updatedContent);
            $stmt->bindParam(':actRemark', $json['actRemark']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for actId {$json['actId']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateOutput($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['outId'], $json['currentValue'], $json['newValue'], $json['outRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        // Decode the existing JSON array from the database
        $stmt = $this->conn->prepare("SELECT outputs_content FROM tbl_outputs WHERE outputs_id = :outId");
        $stmt->bindParam(':outId', $json['outId']);
        $stmt->execute();
        $existingContent = $stmt->fetchColumn();

        $contentArray = json_decode($existingContent, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid existing JSON format']);
        }

        // Update the specific value in the array
        $indexToUpdate = array_search($json['currentValue'], $contentArray);
        if ($indexToUpdate !== false) {
            $contentArray[$indexToUpdate] = $json['newValue'];
        } else {
            return json_encode(['error' => 'Current value not found']);
        }

        // Encode the updated array back to JSON
        $updatedContent = json_encode($contentArray);

        $sql = "UPDATE tbl_outputs SET outputs_content = :outContent, 
                outputs_remarks = :outRemarks
                WHERE outputs_id = :outId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':outId', $json['outId']);
            $stmt->bindParam(':outContent', $updatedContent);
            $stmt->bindParam(':outRemarks', $json['outRemarks']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for outId {$json['outId']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateInstruction($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['instructionId'], $json['currentValue'], $json['newValue'], $json['instructRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        // Decode the existing JSON array from the database
        $stmt = $this->conn->prepare("SELECT instruction_content FROM tbl_instruction WHERE instruction_id = :instructionId");
        $stmt->bindParam(':instructionId', $json['instructionId']);
        $stmt->execute();
        $existingContent = $stmt->fetchColumn();

        $contentArray = json_decode($existingContent, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid existing JSON format']);
        }

        // Update the specific value in the array
        $indexToUpdate = array_search($json['currentValue'], $contentArray);
        if ($indexToUpdate !== false) {
            $contentArray[$indexToUpdate] = $json['newValue'];
        } else {
            return json_encode(['error' => 'Current value not found']);
        }

        // Encode the updated array back to JSON
        $updatedContent = json_encode($contentArray);

        $sql = "UPDATE tbl_instruction SET instruction_content = :instructContent, 
                instruction_remarks = :instructRemarks
                WHERE instruction_id = :instructionId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':instructionId', $json['instructionId']);
            $stmt->bindParam(':instructContent', $updatedContent);
            $stmt->bindParam(':instructRemarks', $json['instructRemarks']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for instructionId {$json['instructionId']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateCoachDetail($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['coachId'], $json['currentValue'], $json['newValue'], $json['coachRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        // Decode the existing JSON array from the database
        $stmt = $this->conn->prepare("SELECT coach_detail_content FROM tbl_coach_detail WHERE coach_detail_id = :coachId");
        $stmt->bindParam(':coachId', $json['coachId']);
        $stmt->execute();
        $existingContent = $stmt->fetchColumn();

        // Log the existing content for debugging
        error_log("Existing content for coachId {$json['coachId']}: " . $existingContent);

        $contentArray = json_decode($existingContent, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid existing JSON format']);
        }

        if (!is_array($contentArray)) {
            return json_encode(['error' => 'Existing content is not an array']);
        }

        // Update the specific value in the array
        $indexToUpdate = array_search($json['currentValue'], $contentArray);
        if ($indexToUpdate !== false) {
            $contentArray[$indexToUpdate] = $json['newValue'];
        } else {
            return json_encode(['error' => 'Current value not found']);
        }

        // Encode the updated array back to JSON
        $updatedContent = json_encode($contentArray);

        $sql = "UPDATE tbl_coach_detail SET coach_detail_content = :coachContent, 
                coach_detail_renarks = :coachRemarks
                WHERE coach_detail_id = :coachId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':coachId', $json['coachId']);
            $stmt->bindParam(':coachContent', $updatedContent);
            $stmt->bindParam(':coachRemarks', $json['coachRemarks']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for coachId {$json['coachId']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateProject($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['project_id'], $json['project_subject_code'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_project SET 
                project_subject_code = :project_subject_code
                WHERE project_id = :project_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':project_subject_code', $json['project_subject_code']);
            $stmt->bindParam(':project_id', $json['project_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for project_id {$json['project_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateProjectSubject($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['project_id'], $json['project_subject_description'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_project SET 
                project_subject_description = :project_subject_description
                WHERE project_id = :project_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':project_subject_description', $json['project_subject_description']);
            $stmt->bindParam(':project_id', $json['project_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for project_id {$json['project_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateProjectEnd($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['project_id'], $json['project_end_date'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_project SET 
                project_end_date = :project_end_date
                WHERE project_id = :project_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':project_end_date', $json['project_end_date']);
            $stmt->bindParam(':project_id', $json['project_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for project_id {$json['project_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateProjectStart($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['project_id'], $json['project_start_date'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_project SET 
                project_start_date = :project_start_date
                WHERE project_id = :project_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':project_start_date', $json['project_start_date']);
            $stmt->bindParam(':project_id', $json['project_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for project_id {$json['project_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateCardTitle($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['card_id'], $json['cards_title'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_cards SET cards_title = :cards_title WHERE card_id = :card_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':cards_title', $json['cards_title']);
            $stmt->bindParam(':card_id', $json['card_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for card_id {$json['card_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateCardContent($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['card_id'], $json['cards_content'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_cards SET cards_content = :cards_content WHERE card_id = :card_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':cards_content', $json['cards_content']);
            $stmt->bindParam(':card_id', $json['card_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for card_id {$json['card_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    function updateModule($json)
    {
        $json = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['error' => 'Invalid JSON format']);
        }

        if (!isset($json['project_id'], $json['module_master_name'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_project SET module_master_name = :module_master_name WHERE project_id = :project_id";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':module_master_name', $json['module_master_name']);
            $stmt->bindParam(':project_id', $json['project_id']);
            $stmt->execute();
            $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

            error_log("Update result for project_id {$json['project_id']}: " . $returnValue);

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    // Add more functions for other card fields as needed
}

$updates = new Updates($pdo);

switch ($operation) {
    case "activity":
        echo $updates->updateActs($json);
        break;
    case "coachDetail":
        echo $updates->updateCoachDetail($json);
        break;
    case "instruction":
        echo $updates->updateInstruction($json);
        break;
    case "output":
        echo $updates->updateOutput($json);
        break;
    case "project":
        echo $updates->updateProject($json);
        break;
    case "Subject":
        echo $updates->updateProjectSubject($json);
        break;
    case "End":
        echo $updates->updateProjectEnd($json);
        break;
    case "Start":
        echo $updates->updateProjectStart($json);
        break;
    case "updateCardTitle":
        echo $updates->updateCardTitle($json);
        break;
    case "updateCardContent":
        echo $updates->updateCardContent($json);
        break;
    case "updateModule":
        echo $updates->updateModule($json);
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}

