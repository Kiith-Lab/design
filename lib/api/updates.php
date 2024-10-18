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

        if (!isset($json['actId'], $json['actContent'], $json['actRemark'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_activities_details SET activities_details_content = :actContent, 
                activities_details_remarks = :actRemark
                WHERE activities_details_id = :actId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':actId', $json['actId']);
            $stmt->bindParam(':actContent', $json['actContent']);
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

        if (!isset($json['outId'], $json['outContent'], $json['outRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_outputs SET outputs_content = :outContent, 
                outputs_remarks = :outRemarks
                WHERE outputs_id = :outId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':outId', $json['outId']);
            $stmt->bindParam(':outContent', $json['outContent']);
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

        if (!isset($json['instructionId'], $json['instructContent'], $json['instructRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_instruction SET instruction_content = :instructContent, 
                instruction_remarks = :instructRemarks
                WHERE instruction_id = :instructionId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':instructionId', $json['instructionId']);
            $stmt->bindParam(':instructContent', $json['instructContent']);
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

        if (!isset($json['coachId'], $json['coachContent'], $json['coachRemarks'])) {
            return json_encode(['error' => 'Missing required fields']);
        }

        $sql = "UPDATE tbl_coach_detail SET coach_detail_content = :coachContent, 
                coach_detail_remarks = :coachRemarks
                WHERE coach_detail_id = :coachId";

        try {
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':coachId', $json['coachId']);
            $stmt->bindParam(':coachContent', $json['coachContent']);
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
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}