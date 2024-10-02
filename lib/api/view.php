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

    function getFolders()
    {
        try {
            $sql = "SELECT 
            tbl_users.users_firstname AS Name,
            tbl_module_master.module_master_name AS Mode, 
            tbl_activities_header.activities_header_duration AS Duration,  
            tbl_activities_details.activities_details_content AS Activity, 
            tbl_project.project_title AS Lesson, 
            tbl_outputs.outputs_content AS Output, 
            tbl_instruction.instruction_content AS Instruction, 
            tbl_coach_detail.coach_detail_content AS CoachDetail
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
            LEFT JOIN tbl_users ON tbl_project.project_userId = tbl_users.users_id";
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
            tbl_coach_detail.coach_detail_content AS CoachDetail
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

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            // Return results as JSON
            return json_encode($returnValue);
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
    default:
        echo json_encode(['error' => 'Invalid operation']);
        break;
}
