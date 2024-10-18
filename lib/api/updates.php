<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Access-Control-Allow-Origin: *"); // Allow all origins
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow specific methods
header("Access-Control-Allow-Headers: Content-Type"); // Allow specific headers
header("Content-Type: application/json"); // Set the content type to JSON

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Log the incoming request for debugging
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Check if the required keys exist
if (!isset($data['operation']) || !isset($data['json'])) {
    echo json_encode(['error' => 'Missing operation or json key']);
    exit;
}

$operation = $data['operation'];
$json = $data['json'];

// Include the database connection
include 'db_connection.php'; // Ensure this file is correct and accessible

class Updates
{
    private $conn;

    public function __construct($dbConnection)
    {
        $this->conn = $dbConnection; // Assign the database connection to the class variable
    }

    function updateActs($json)
    {
        $json = json_decode($json, true);
        $sql = "UPDATE tbl_activities_details SET activities_details_content = :actContent, 
                activities_details_remarks = :actRemark
                WHERE activities_details_id = :actId";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam('actId', $json['actId']);
        $stmt->bindParam('actContent', $json['actContent']);
        $stmt->bindParam('actRemark', $json['actRemark']);
        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;
        return json_encode($returnValue);
    }

    function updateOutput($json)
    {
        $json = json_decode($json, true);
        $sql = "UPDATE tbl_outputs SET outputs_content = :outContent, 
                outputs_remarks = :outRemarks
                WHERE outputs_id = :outId";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam('outId', $json['outId']);
        $stmt->bindParam('outContent', $json['outContent']);
        $stmt->bindParam('outRemarks', $json['outRemarks']);
        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;
        return json_encode($returnValue);
    }

    function updateInstruction($json)
    {
        $json = json_decode($json, true);
        $sql = "UPDATE tbl_instruction SET instruction_content = :instructContent, 
                instruction_remarks = :instructRemarks
                WHERE instruction_id = :instructionId";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam('instructionId', $json['instructionId']);
        $stmt->bindParam('instructContent', $json['instructContent']);
        $stmt->bindParam('instructRemarks', $json['instructRemarks']);
        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;
        return json_encode($returnValue);
    }

    function updateCoachDetail($json)
    {
        $json = json_decode($json, true);
        $sql = "UPDATE tbl_coach_detail SET coach_detail_content = :coachContent, 
                coach_detail_remarks = :coachRemarks
                WHERE coach_detail_id = :coachId"; // Corrected spelling

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam('coachId', $json['coachId']);
        $stmt->bindParam('coachContent', $json['coachContent']);
        $stmt->bindParam('coachRemarks', $json['coachRemarks']);
        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;
        return json_encode($returnValue);
    }

    function updateProject($json)
    {
        $json = json_decode($json, true);
        // Updated SQL query to only include the fields that can be updated
        $sql = "UPDATE tbl_project SET 
            project_title = :project_title, 
            project_description = :project_description, 
            project_start_date = :project_start_date, 
            project_end_date = :project_end_date 
            WHERE project_id = :project_id";

        $stmt = $this->conn->prepare($sql);
        // Bind parameters for the fields that can be updated
        $stmt->bindParam(':project_title', $json['project_title']);
        $stmt->bindParam(':project_description', $json['project_description']);
        $stmt->bindParam(':project_start_date', $json['project_start_date']);
        $stmt->bindParam(':project_end_date', $json['project_end_date']);
        $stmt->bindParam(':project_id', $json['project_id']);
        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;
        return json_encode($returnValue);
    }
}

// Create an instance of the Updates class with the database connection
$updates = new Updates($conn);

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
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}
