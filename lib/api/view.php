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

    function getContacts()
    {
        try {
            $sql = "SELECT 
            tbl_front_cards.cards_title,
            tbl_front_cards.cards_id,
            tbl_front_cards.cards_content,
            MAX(tbl_back_cards_header.back_content) as back_content,
            MAX(tbl_back_cards_header.back_content_title) as back_content_title,
            MAX(tbl_back_cards_header.back_cards_header_frontId) as back_cards_header_frontId,
            MAX(tbl_back_cards_header.back_cards_header_title) as back_cards_header_title
        FROM tbl_front_cards 
        LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_frontId = tbl_front_cards.cards_id
        WHERE tbl_front_cards.cards_masterId = 1
        GROUP BY tbl_front_cards.cards_id, tbl_front_cards.cards_title, tbl_front_cards.cards_content
        ORDER BY tbl_front_cards.cards_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error in getContacts: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'Database error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred']);
        }
    }

    function getDefine()
    {
        try {
            $sql = "SELECT 
            tbl_front_cards.cards_title,
            tbl_front_cards.cards_id,
            tbl_front_cards.cards_content,
            MAX(tbl_back_cards_header.back_content) as back_content,
            MAX(tbl_back_cards_header.back_content_title) as back_content_title,
            MAX(tbl_back_cards_header.back_cards_header_frontId) as back_cards_header_frontId,
            MAX(tbl_back_cards_header.back_cards_header_title) as back_cards_header_title
            FROM tbl_front_cards 
            LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_frontId = tbl_front_cards.cards_id
            WHERE tbl_front_cards.cards_masterId = 2
            GROUP BY tbl_front_cards.cards_id, tbl_front_cards.cards_title, tbl_front_cards.cards_content
            ORDER BY tbl_front_cards.cards_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error in getDefine: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'Database error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred']);
        }
    }

    function getIdeate()
    {
        try {
            $sql = "SELECT tbl_front_cards.cards_title,
       tbl_front_cards.cards_id,
       tbl_front_cards.cards_content,
       GROUP_CONCAT(tbl_back_cards_header.back_content) AS back_content,
       GROUP_CONCAT(tbl_back_cards_header.back_content_title) AS back_content_title,
       GROUP_CONCAT(tbl_back_cards_header.back_cards_header_frontId) AS back_cards_header_frontId,
       GROUP_CONCAT(tbl_back_cards_header.back_cards_header_title) AS back_cards_header_title
        FROM tbl_front_cards
        LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_frontId = tbl_front_cards.cards_id
        WHERE tbl_front_cards.cards_masterId = 3
        GROUP BY tbl_front_cards.cards_id, tbl_front_cards.cards_title, tbl_front_cards.cards_content
        ORDER BY tbl_front_cards.cards_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error in getPrototype: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'Database error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        } catch (Exception $e) {
            error_log("General error in getPrototype: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'An error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        }
    }

    function getPrototype()
    {
        try {
            $sql = "SELECT tbl_front_cards.cards_title,
                tbl_front_cards.cards_id,
                tbl_front_cards.cards_content,
                GROUP_CONCAT(tbl_back_cards_header.back_content) AS back_content,
                GROUP_CONCAT(tbl_back_cards_header.back_content_title) AS back_content_title,
                GROUP_CONCAT(tbl_back_cards_header.back_cards_header_frontId) AS back_cards_header_frontId,
                GROUP_CONCAT(tbl_back_cards_header.back_cards_header_title) AS back_cards_header_title
                FROM tbl_front_cards
                LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_frontId = tbl_front_cards.cards_id
                WHERE tbl_front_cards.cards_masterId = 4
                GROUP BY tbl_front_cards.cards_id, tbl_front_cards.cards_title, tbl_front_cards.cards_content
                ORDER BY tbl_front_cards.cards_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error in getPrototype: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'Database error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        } catch (Exception $e) {
            error_log("General error in getPrototype: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'An error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        }
    }

    function getTest()
    {
        try {
            $sql = "SELECT tbl_front_cards.cards_title,
       tbl_front_cards.cards_id,
       tbl_front_cards.cards_content,
       GROUP_CONCAT(tbl_back_cards_header.back_content) AS back_content,
       GROUP_CONCAT(tbl_back_cards_header.back_content_title) AS back_content_title,
       GROUP_CONCAT(tbl_back_cards_header.back_cards_header_frontId) AS back_cards_header_frontId,
       GROUP_CONCAT(tbl_back_cards_header.back_cards_header_title) AS back_cards_header_title
        FROM tbl_front_cards
        LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_frontId = tbl_front_cards.cards_id
        WHERE tbl_front_cards.cards_masterId = 5
        GROUP BY tbl_front_cards.cards_id, tbl_front_cards.cards_title, tbl_front_cards.cards_content
        ORDER BY tbl_front_cards.cards_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error in getTest: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'Database error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        } catch (Exception $e) {
            error_log("General error in getTest: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode([
                'error' => 'An error occurred',
                'details' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);
        }
    }

    function getBack()
    {
        $cardId = isset($_POST['cardId']) ? $_POST['cardId'] : '';
        try {
            $sql = "SELECT tbl_front_cards.cards_title, 
                    tbl_front_cards.cards_id, 
                    tbl_front_cards.cards_content,
                    tbl_back_cards_header.back_content, 
                    tbl_back_cards_header.back_content_title,
                    tbl_back_cards_header.back_cards_header_frontId
            FROM tbl_back_cards_header 
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_back_cards_header.back_cards_header_frontId = :cardId ";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':cardId', $cardId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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


    function getBack1()
    {
        $cardId = isset($_POST['cardId']) ? $_POST['cardId'] : '';
        try {
            $sql = "SELECT tbl_front_cards.cards_title, 
                    tbl_front_cards.cards_id, 
                    tbl_front_cards.cards_content,
                    tbl_back_cards_header.back_content, 
                    tbl_back_cards_header.back_content_title,
                    tbl_back_cards_header.back_cards_header_frontId,
                    tbl_back_cards_header.back_cards_header_title
            FROM tbl_back_cards_header 
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_back_cards_header.back_cards_header_frontId = :cardId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':cardId', $cardId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    function getBack2()
    {
        $cardId = isset($_POST['cardId']) ? $_POST['cardId'] : '';
        try {
            $sql = "SELECT tbl_front_cards.cards_title, 
                    tbl_front_cards.cards_id, 
                    tbl_front_cards.cards_content,
                    tbl_back_cards_header.back_content, 
                    tbl_back_cards_header.back_content_title,
                    tbl_back_cards_header.back_cards_header_frontId,
                    tbl_back_cards_header.back_cards_header_title
            FROM tbl_back_cards_header 
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_back_cards_header.back_cards_header_frontId = :cardId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':cardId', $cardId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getBack3()
    {
        $cardId = isset($_POST['cardId']) ? $_POST['cardId'] : '';
        try {
            $sql = "SELECT tbl_front_cards.cards_title, 
                    tbl_front_cards.cards_id, 
                    tbl_front_cards.cards_content,
                    tbl_back_cards_header.back_content, 
                    tbl_back_cards_header.back_content_title,
                    tbl_back_cards_header.back_cards_header_frontId,
                    tbl_back_cards_header.back_cards_header_title
            FROM tbl_back_cards_header 
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_back_cards_header.back_cards_header_frontId = :cardId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':cardId', $cardId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getBack4()
    {
        $cardId = isset($_POST['cardId']) ? $_POST['cardId'] : '';
        try {
            $sql = "SELECT tbl_front_cards.cards_title, 
                    tbl_front_cards.cards_id, 
                    tbl_front_cards.cards_content,
                    tbl_back_cards_header.back_content, 
                    tbl_back_cards_header.back_content_title,
                    tbl_back_cards_header.back_cards_header_frontId,
                    tbl_back_cards_header.back_cards_header_title
            FROM tbl_back_cards_header 
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_back_cards_header.back_cards_header_frontId = :cardId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':cardId', $cardId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getFolder()
    {
        try {
            $sql = "SELECT * FROM tbl_folder ORDER BY folder_id DESC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            return json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
    function GetModes()
    {
        try {
            $sql = "SELECT * FROM tbl_module_master ORDER BY module_master_id ASC";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getLessons()
    {
        $modeId = isset($_POST['modeId']) ? $_POST['modeId'] : '';
        try {
            $sql = "SELECT 
    tbl_front_cards.cards_title, 
    tbl_front_cards.cards_id, 
    tbl_front_cards.cards_content,
    MIN(tbl_back_cards_header.back_cards_header_id) AS back_cards_header_id, -- Use MIN or any aggregate function to avoid duplicates
    GROUP_CONCAT(DISTINCT tbl_back_cards_header.back_content ORDER BY tbl_back_cards_header.back_content SEPARATOR ', ') AS back_content, 
    GROUP_CONCAT(DISTINCT tbl_back_cards_header.back_content_title ORDER BY tbl_back_cards_header.back_content_title SEPARATOR ', ') AS back_content_title,
    tbl_back_cards_header.back_cards_header_frontId, -- Include this field for grouping
    GROUP_CONCAT(DISTINCT tbl_back_cards_header.back_cards_header_title ORDER BY tbl_back_cards_header.back_cards_header_title SEPARATOR ', ') AS back_cards_header_title,
    GROUP_CONCAT(DISTINCT tbl_module_master.module_master_name ORDER BY tbl_module_master.module_master_id SEPARATOR ', ') AS module_master_name,
    tbl_front_cards.cards_masterId
FROM 
    tbl_back_cards_header 
LEFT JOIN 
    tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
LEFT JOIN 
    tbl_module_master ON tbl_module_master.module_master_id = tbl_front_cards.cards_masterId
WHERE tbl_front_cards.cards_masterId = :modeId
GROUP BY 
    tbl_back_cards_header.back_cards_header_frontId, -- Group by unique identifier
    tbl_front_cards.cards_id, 
    tbl_front_cards.cards_title, 
    tbl_front_cards.cards_content,
    tbl_front_cards.cards_masterId
ORDER BY 
    tbl_front_cards.cards_title;
";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':modeId', $modeId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getProject()
    {
        try {
            $sql = "SELECT * FROM tbl_project WHERE project_id = (SELECT MAX(project_id) FROM tbl_project)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$returnValue) {
                return json_encode(['error' => 'No project found']);
            }

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            header('Content-Type: application/json');
            echo json_encode($returnValue);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            header('HTTP/1.1 500 Internal Server Error');
            echo json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            header('HTTP/1.1 500 Internal Server Error');
            echo json_encode(['error' => 'An error occurred']);
        }
    }
    function getUser()
    {
        try {
            $sql = "SELECT a.*, b.role_name FROM tbl_users a
            INNER JOIN tbl_role b ON b.role_id = a.users_roleId";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getUsers($json)
    {
        // Decode the JSON input
        $json = json_decode($json, true);
        $schoolname = isset($json['schoolname']) ? $json['schoolname'] : '';
        $departmentname = isset($json['departmentname']) ? $json['departmentname'] : '';

        try {
            $sql = "SELECT a.*, b.role_name, c.school_name, d.department_name FROM tbl_users a
            INNER JOIN tbl_role b ON b.role_id = a.users_roleId
            INNER JOIN tbl_school c ON c.school_id = a.users_schoolId
            INNER JOIN tbl_department d ON d.department_id = a.users_departmantId
            WHERE c.school_name = :schoolname AND d.department_name = :departmentname";
            $stmt = $this->pdo->prepare($sql);
            // Bind parameters
            $stmt->bindParam(':schoolname', $schoolname);
            $stmt->bindParam(':departmentname', $departmentname);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getSchool()
    {
        try {
            $sql = "SELECT * FROM tbl_school";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getInstructors()
    {
        try {
            $sql = "SELECT a.*, b.role_name, c.school_name, d.department_name FROM tbl_users a
            INNER JOIN tbl_role b ON b.role_id = a.users_roleId
            INNER JOIN tbl_school c ON c.school_id = a.users_schoolId
            INNER JOIN tbl_department d ON d.department_id = a.users_departmantId";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    // function getFolders()
    // {
    //     try {
    //         $sql = "SELECT 
    //         tbl_project.project_id AS ProjectId,
    //         tbl_users.users_status,
    //         tbl_module_master.module_master_name AS Mode, 
    //         tbl_activities_header.activities_header_duration AS Duration,  
    //         tbl_project.project_title AS Lesson, 
    //         tbl_activities_details.activities_details_content AS Activity, 
    //         tbl_activities_details.activities_details_remarks AS ActivityRemarks, 
    //         tbl_outputs.outputs_content AS Output, 
    //         tbl_outputs.outputs_remarks AS OutputRemarks, 
    //         tbl_instruction.instruction_content AS Instruction, 
    //         tbl_instruction.instruction_remarks AS InstructionRemarks, 
    //         tbl_coach_detail.coach_detail_content AS CoachDetail,
    //         tbl_coach_detail.coach_detail_renarks AS CoachDetailRemarks,
    //         tbl_project.project_description AS ProjectDescription,
    //         tbl_project.project_start_date AS StartDate,
    //         tbl_project.project_end_date AS EndDate
    //         FROM 
    //         tbl_folder
    //         LEFT JOIN tbl_project ON tbl_folder.projectId = tbl_project.project_id
    //         LEFT JOIN tbl_project_modules ON tbl_folder.project_moduleId = tbl_project_modules.project_modules_id
    //         LEFT JOIN tbl_module_master ON tbl_project_modules.project_modules_masterId = tbl_module_master.module_master_id
    //         LEFT JOIN tbl_activities_details ON tbl_folder.activities_detailId = tbl_activities_details.activities_details_id
    //         LEFT JOIN tbl_activities_header ON tbl_activities_header.activities_header_modulesId = tbl_activities_details.activities_details_id
    //         LEFT JOIN tbl_outputs ON tbl_folder.outputId = tbl_outputs.outputs_id
    //         LEFT JOIN tbl_instruction ON tbl_folder.instructionId = tbl_instruction.instruction_id
    //         LEFT JOIN tbl_coach_detail ON tbl_folder.coach_detailsId = tbl_coach_detail.coach_detail_id
    //         LEFT JOIN tbl_users ON tbl_project.project_userId = tbl_users.users_id";

    //         $stmt = $this->pdo->prepare($sql);
    //         $stmt->execute();

    //         $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    //         // Group by ProjectId and combine related fields
    //         $groupedResults = [];

    //         foreach ($results as $row) {
    //             $projectId = $row['ProjectId'];

    //             if (!isset($groupedResults[$projectId])) {
    //                 // Initialize the group if it doesn't exists in the data or table
    //                 $groupedResults[$projectId] = [
    //                     'ProjectId' => $projectId,
    //                     'users_status' => $row['users_status'],
    //                     'Mode' => $row['Mode'],
    //                     'Duration' => $row['Duration'],
    //                     'Lesson' => $row['Lesson'],
    //                     'ProjectDescription' => $row['ProjectDescription'],
    //                     'StartDate' => $row['StartDate'],
    //                     'EndDate' => $row['EndDate'],
    //                     'Activity' => [],
    //                     'ActivityRemarks' => [],
    //                     'Output' => [],
    //                     'OutputRemarks' => [],
    //                     'Instruction' => [],
    //                     'InstructionRemarks' => [],
    //                     'CoachDetail' => [],
    //                     'CoachDetailRemarks' => []
    //                 ];
    //             }

    //             // Append the details to the corresponding arrays
    //             $groupedResults[$projectId]['Activity'][] = $row['Activity'];
    //             $groupedResults[$projectId]['ActivityRemarks'][] = $row['ActivityRemarks'];
    //             $groupedResults[$projectId]['Output'][] = $row['Output'];
    //             $groupedResults[$projectId]['OutputRemarks'][] = $row['OutputRemarks'];
    //             $groupedResults[$projectId]['Instruction'][] = $row['Instruction'];
    //             $groupedResults[$projectId]['InstructionRemarks'][] = $row['InstructionRemarks'];
    //             $groupedResults[$projectId]['CoachDetail'][] = $row['CoachDetail'];
    //             $groupedResults[$projectId]['CoachDetailRemarks'][] = $row['CoachDetailRemarks'];
    //         }

    //         // Combine arrays into strings with newlines
    //         foreach ($groupedResults as &$group) {
    //             $group['Activity'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['Activity'])));

    //             $group['ActivityRemarks'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['ActivityRemarks'])));

    //             $group['Output'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['Output'])));

    //             $group['OutputRemarks'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['OutputRemarks'])));

    //             $group['Instruction'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['Instruction'])));

    //             $group['InstructionRemarks'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['InstructionRemarks'])));

    //             $group['CoachDetail'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['CoachDetail'])));

    //             $group['CoachDetailRemarks'] = implode("\n", array_filter(array_map(function ($a) {
    //                 return str_replace(['[', ']', '"'], '', $a);
    //             }, $group['CoachDetailRemarks'])));
    //         }

    //         error_log("SQL Query: $sql");
    //         error_log("Grouped Result: " . print_r($groupedResults, true));

    //         return json_encode(array_values($groupedResults));
    //     } catch (PDOException $e) {
    //         error_log("Database error: " . $e->getMessage());
    //         return json_encode(['error' => 'Database error occurred']);
    //     } catch (Exception $e) {
    //         error_log("General error: " . $e->getMessage());
    //         return json_encode(['error' => 'An error occurred']);
    //     }
    // }

    function getFolders()
    {
        try {
            // Your modified SQL query goes here
            $sql = "SELECT 
    tbl_project.project_id,
    GROUP_CONCAT(DISTINCT tbl_module_master.module_master_name ORDER BY tbl_module_master.module_master_name SEPARATOR ', ') AS Mode, 
    GROUP_CONCAT(DISTINCT tbl_activities_header.activities_header_duration ORDER BY tbl_activities_header.activities_header_duration SEPARATOR ', ') AS Duration,  
    GROUP_CONCAT(DISTINCT tbl_activities_details.activities_details_content ORDER BY tbl_activities_details.activities_details_content SEPARATOR ', ') AS Activity, 
    tbl_project.project_title AS Lesson, 
    GROUP_CONCAT(DISTINCT tbl_outputs.outputs_content ORDER BY tbl_outputs.outputs_content SEPARATOR ', ') AS Output, 
    GROUP_CONCAT(DISTINCT tbl_instruction.instruction_content ORDER BY tbl_instruction.instruction_content SEPARATOR ', ') AS Instruction, 
    GROUP_CONCAT(DISTINCT tbl_coach_detail.coach_detail_content ORDER BY tbl_coach_detail.coach_detail_content SEPARATOR ', ') AS CoachDetail,
    tbl_project.project_description AS ProjectDescription,
    tbl_project.project_start_date AS StartDate,
    tbl_project.project_end_date AS EndDate,
    tbl_activities_details.activities_details_remarks AS ActivityRemarks, 
    tbl_outputs.outputs_remarks AS OutputRemarks, 
    tbl_instruction.instruction_remarks AS InstructionRemarks, 
    tbl_coach_detail.coach_detail_renarks AS CoachDetailRemarks
FROM 
    tbl_folder
LEFT JOIN 
    tbl_project ON tbl_folder.projectId = tbl_project.project_id
LEFT JOIN 
    tbl_project_modules ON tbl_folder.project_moduleId = tbl_project_modules.project_modules_id
LEFT JOIN 
    tbl_module_master ON tbl_project_modules.project_modules_masterId = tbl_module_master.module_master_id
LEFT JOIN 
    tbl_activities_details ON tbl_folder.activities_detailId = tbl_activities_details.activities_details_id
LEFT JOIN 
    tbl_activities_header ON tbl_activities_header.activities_header_modulesId = tbl_activities_details.activities_details_id
LEFT JOIN 
    tbl_outputs ON tbl_folder.outputId = tbl_outputs.outputs_id
LEFT JOIN 
    tbl_instruction ON tbl_folder.instructionId = tbl_instruction.instruction_id
LEFT JOIN 
    tbl_coach_detail ON tbl_folder.coach_detailsId = tbl_coach_detail.coach_detail_id
GROUP BY 
    tbl_project.project_id, tbl_project.project_description, tbl_project.project_start_date, tbl_project.project_end_date, tbl_project.project_title;
";

            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            // Format the results into a single container
            $formattedResult = [];
            foreach ($returnValue as $row) {
                $formattedResult[] = [
                    'Mode' => $row['Mode'],
                    'Duration' => $row['Duration'],
                    'Activity' => $row['Activity'],
                    'Lesson' => $row['Lesson'],
                    'Output' => $row['Output'],
                    'Instruction' => $row['Instruction'],
                    'CoachDetail' => $row['CoachDetail'],
                    'ProjectDescription' => $row['ProjectDescription'],
                    'StartDate' => $row['StartDate'],
                    'EndDate' => $row['EndDate'],
                    'ActivityRemarks' => $row['ActivityRemarks'],
                    'OutputRemarks' => $row['OutputRemarks'],
                    'InstructionRemarks' => $row['InstructionRemarks'],
                    'CoachDetailRemarks' => $row['CoachDetailRemarks'],
                ];
            }

            return json_encode($formattedResult);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['error' => 'An error occurred']);
        }
    }



    function getFolderId($json)
    {
        $json = json_decode($json, true);
        $usersId = isset($json['users_id']) ? $json['users_id'] : '';

        try {
            // Ensure usersId is not empty
            if (empty($usersId)) {
                return json_encode(['error' => 'User ID is required']);
            }

            $sql = "SELECT 
            tbl_users.users_firstname AS Name,
            tbl_module_master.module_master_name AS Mode, 
            tbl_activities_header.activities_header_duration AS Duration,  
            tbl_activities_details.activities_details_content AS Activity, 
            tbl_project.project_title AS Lesson, 
            tbl_outputs.outputs_content AS Output, 
            tbl_instruction.instruction_content AS Instruction, 
            tbl_coach_detail.coach_detail_content AS CoachDetail,
            tbl_project.project_id AS ProjectId
                FROM 
                    tbl_folder
                LEFT JOIN tbl_project ON tbl_folder.projectId = tbl_project.project_id
                LEFT JOIN tbl_project_modules ON tbl_folder.project_moduleId = tbl_project_modules.project_modules_id
                LEFT JOIN tbl_module_master ON tbl_project_modules.project_modules_masterId = tbl_module_master.module_master_id
                LEFT JOIN tbl_activities_details ON tbl_folder.activities_detailId = tbl_activities_details.activities_details_id
                LEFT JOIN tbl_activities_header ON tbl_activities_header.activities_header_modulesId = tbl_activities_details.activities_details_id
                LEFT JOIN tbl_outputs ON tbl_folder.outputId = tbl_outputs.outputs_id
                LEFT JOIN tbl_instruction ON tbl_folder.instructionId = tbl_instruction.instruction_id
                LEFT JOIN tbl_coach_detail ON tbl_folder.coach_detailsId = tbl_coach_detail.coach_detail_id
                LEFT JOIN tbl_users ON tbl_project.project_userId = tbl_users.users_id
                    WHERE 
                        tbl_users.users_id = :users_id";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $usersId);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Group by project_id to ensure no duplicate folders for the same project
            $groupedByProject = [];
            foreach ($returnValue as $row) {
                $projectId = $row['ProjectId'];
                if (!isset($groupedByProject[$projectId])) {
                    $groupedByProject[$projectId] = $row;
                }
            }

            $result = array_values($groupedByProject);

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($result, true));

            // Return results as JSON
            return json_encode($result);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['error' => 'An error occurred']);
        }
    }
    function getUserSchoolDepartment()
    {
        try {
            $sql = "SELECT * FROM `tbl_users` INNER JOIN tbl_school ON tbl_school.school_id = tbl_users.users_schoolId INNER JOIN tbl_department ON tbl_department.department_id = tbl_users.users_departmantId";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getDepartments()
    {
        try {
            $sql = "SELECT * FROM tbl_department";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
    function getUserNotActive()
    {
        try {
            $sql = "SELECT tbl_users.users_firstname, tbl_users.users_middlename, tbl_users.users_lastname, tbl_role.role_name 
                    FROM tbl_users 
                    JOIN tbl_role ON tbl_users.users_roleId = tbl_role.role_id
                    WHERE tbl_users.users_status = 0";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // If no users are found, return an empty array
            if (!$returnValue) {
                $returnValue = [];
            }

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            return json_encode($returnValue);  // Always return a list (array)
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['error' => 'An error occurred']);
        }
    }
    function getUserNotVerify()
    {
        try {
            $sql = "SELECT tbl_users.*, tbl_role.role_name 
                    FROM tbl_users 
                    JOIN tbl_role ON tbl_users.users_roleId = tbl_role.role_id
                    WHERE tbl_users.register_status = 0";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // If no users are found, return an empty array
            if (!$returnValue) {
                $returnValue = [];
            }

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            return json_encode($returnValue);  // Always return a list (array)
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['error' => 'An error occurred']);
        }
    }
    function UserVerify($json) {
        try {
            $updatedRegisterStatus = 1; // Set the status to 'verified'
            $json = json_decode($json, true);
            
            // Check if the JSON was decoded properly
            if (json_last_error() !== JSON_ERROR_NONE) {
                return json_encode(['success' => false, 'message' => 'Invalid JSON format.']);
            }
    
            if (empty($json['users_id'])) {
                return json_encode(['success' => false, 'message' => 'User ID is missing.']);
            }
    
            // Prepare SQL statement
            $sql = "UPDATE tbl_users SET register_status = :updatedRegisterStatus WHERE users_id = :users_id";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':users_id', $json['users_id'], PDO::PARAM_INT);
            $stmt->bindParam(':updatedRegisterStatus', $updatedRegisterStatus, PDO::PARAM_INT);
    
            // Execute the update
            $stmt->execute();
    
            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => 'User verified successfully.']);
            } else {
                return json_encode(['success' => false, 'message' => 'No user found or status already updated.']);
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['success' => false, 'message' => 'Database error occurred.']);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage());
            return json_encode(['success' => false, 'message' => 'An error occurred.']);
        }
    }

    function getAllProjects()
    {
        try {
            // $sql = "SELECT project_subject_code, project_title FROM tbl_project";
            $sql = "SELECT * FROM tbl_project";

            $stmt = $this->pdo->prepare($sql);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    case 'getProject':
        echo $get->getProject();
        break;
    case "getLessons":
        echo $get->getLessons();
        break;
    case "GetModes":
        echo $get->GetModes();
        break;
    case "getContacts":
        echo $get->getContacts();
        break;
    case "getDefine":
        echo $get->getDefine();
        break;
    case "getIdeate":
        echo $get->getIdeate();
        break;
    case "getPrototype":
        echo $get->getPrototype();
        break;
    case "getTest":
        echo $get->getTest();
        break;
    case "getBack":
        echo $get->getBack();
        break;
    case "getBack1":
        echo $get->getBack1();
        break;
    case "getBack2":
        echo $get->getBack2();
        break;
    case "getBack3":
        echo $get->getBack3();
        break;
    case "getBack4":
        echo $get->getBack4();
        break;
    case "getFolder":
        echo $get->getFolder();
        break;
    case "getUser":
        echo $get->getUser();
        break;
    case "getSchool":
        echo $get->getSchool();
        break;
    case "getInstructors":
        echo $get->getInstructors();
        break;
    case "getFolders":
        echo $get->getFolders();
        break;
    case "getUserSchoolDepartment":
        echo $get->getUserSchoolDepartment();
        break;
    case "getDepartments":
        echo $get->getDepartments();
        break;
    case "getUsers":
        echo $get->getUsers($json);
        break;
    case "getFolderId":
        echo $get->getFolderId($json);
        break;
    case "getUserNotActive":
        echo $get->getUserNotActive();
        break;
    case "getUserNotVerify":
        echo $get->getUserNotVerify();
        break;
    case "UserVerify":
        $json = isset($_POST['json']) ? $_POST['json'] : '';
        echo $get->UserVerify($json);
        break;
    case "getAllProjects":
        echo $get->getAllProjects();
        break;
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}