<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection (ensure this file exists and has the correct PDO object)
include 'db_connection.php';

class Get1
{
    private $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    function getModuleId()
    {
        try {
            $sql = "SELECT * FROM tbl_activities_header";
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
    function getheaderId()
    {
        try {
            $sql = "SELECT * FROM tbl_activities_details";
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
    function getCards()
    {
        try {
            $sql = "SELECT project_cards_id,
            project_cards_remarks,
            project_cards_cardId,
            project_cards_modulesId
            FROM tbl_project_cards";
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
    function projectModeId()
    {
        try {
            $sql = "SELECT * FROM tbl_project_modules";
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
    function addMode($json)
    {
        $json = json_decode($json, true);
        error_log("addMode called with data: " . print_r($json, true));
        try {
            $sql = "INSERT INTO tbl_project_modules (
            project_modules_projectId,
            project_modules_masterId	
            ) VALUES (
            :project_modules_projectId,
            :project_modules_masterId)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':project_modules_projectId', $json['project_modules_projectId'], PDO::PARAM_INT);
            $stmt->bindParam(':project_modules_masterId', $json['project_modules_masterId'], PDO::PARAM_INT);
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

    function addDuration($json)
    {
        $json = json_decode($json, true);
        error_log("addDuration called with data: " . print_r($json, true));
        try {
            $sql = "INSERT INTO tbl_activities_header (
            activities_header_modulesId,
            activities_header_duration		
            ) VALUES (
            :activities_header_modulesId,
            :activities_header_duration)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':activities_header_modulesId', $json['activities_header_modulesId'], PDO::PARAM_INT);
            $stmt->bindParam(':activities_header_duration', $json['activities_header_duration'], PDO::PARAM_INT);
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

    function addActivity($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_activities_details (
            activities_details_remarks,
            activities_details_content,
            activities_details_headerId	
            ) VALUES (
            :activities_details_remarks,
            :activities_details_content,
            :activities_details_headerId)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':activities_details_remarks', $json['activities_details_remarks'], PDO::PARAM_STR);
            $stmt->bindParam(':activities_details_content', $json['activities_details_content'], PDO::PARAM_STR);
            $stmt->bindParam(':activities_details_headerId', $json['activities_details_headerId'], PDO::PARAM_INT);
            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();

            // Fetch the newly inserted activity
            $selectSql = "SELECT * FROM tbl_activities_details WHERE activities_details_id = :id";
            $selectStmt = $this->pdo->prepare($selectSql);
            $selectStmt->bindParam(':id', $lastInsertId, PDO::PARAM_INT);
            $selectStmt->execute();
            $activity = $selectStmt->fetch(PDO::FETCH_ASSOC);

            return json_encode(['success' => true, 'id' => $lastInsertId, 'activity' => $activity]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function addCards($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_project_cards (
            project_cards_remarks,
            project_cards_modulesId,
            project_cards_cardId
            ) VALUES (
            :project_cards_remarks,
            :project_cards_modulesId,
            :project_cards_cardId)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':project_cards_remarks', $json['project_cards_remarks'], PDO::PARAM_STR);
            $stmt->bindParam(':project_cards_modulesId', $json['project_cards_modulesId'], PDO::PARAM_INT);
            $stmt->bindParam(':project_cards_cardId', $json['project_cards_cardId'], PDO::PARAM_INT);
            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();

            // Fetch the newly inserted card
            $selectSql = "SELECT * FROM tbl_project_cards WHERE project_cards_id = :id";
            $selectStmt = $this->pdo->prepare($selectSql);
            $selectStmt->bindParam(':id', $lastInsertId, PDO::PARAM_INT);
            $selectStmt->execute();
            $card = $selectStmt->fetch(PDO::FETCH_ASSOC);

            return json_encode(['success' => true, 'id' => $lastInsertId, 'card' => $card]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function addOutput($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_outputs (
            outputs_moduleId,
            outputs_remarks,
            outputs_content
            ) VALUES (
            :outputs_moduleId,
            :outputs_remarks,
            :outputs_content)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':outputs_moduleId', $json['outputs_moduleId'], PDO::PARAM_INT);
            $stmt->bindParam(':outputs_remarks', $json['outputs_remarks'], PDO::PARAM_STR);
            $stmt->bindParam(':outputs_content', $json['outputs_content'], PDO::PARAM_STR);
            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();

            // Fetch the newly inserted output
            $selectSql = "SELECT * FROM tbl_outputs WHERE outputs_id = :id";
            $selectStmt = $this->pdo->prepare($selectSql);
            $selectStmt->bindParam(':id', $lastInsertId, PDO::PARAM_INT);
            $selectStmt->execute();
            $output = $selectStmt->fetch(PDO::FETCH_ASSOC);

            return json_encode(['success' => true, 'id' => $lastInsertId, 'output' => $output]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function addInstruction($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_instruction (	
            instruction_remarks,
            instruction_modulesId,
            instruction_content
            ) VALUES (
            :instruction_remarks,
            :instruction_modulesId,
            :instruction_content)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':instruction_remarks', $json['instruction_remarks'], PDO::PARAM_STR);
            $stmt->bindParam(':instruction_modulesId', $json['instruction_modulesId'], PDO::PARAM_INT);
            $stmt->bindParam(':instruction_content', $json['instruction_content'], PDO::PARAM_STR);
            $stmt->execute();
            $lastInsertId = $this->pdo->lastInsertId();

            // Fetch the newly inserted instruction
            $selectSql = "SELECT * FROM tbl_instruction WHERE instruction_id = :id";
            $selectStmt = $this->pdo->prepare($selectSql);
            $selectStmt->bindParam(':id', $lastInsertId, PDO::PARAM_INT);
            $selectStmt->execute();
            $instruction = $selectStmt->fetch(PDO::FETCH_ASSOC);

            return json_encode(['success' => true, 'id' => $lastInsertId, 'instruction' => $instruction]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function addCoachHeader($json)
    {
        $json = json_decode($json, true);
        try {
            $sql = "INSERT INTO tbl_coach_header (	
            coach_header_duration,
            coach_header_moduleId
            ) VALUES (
            :coach_header_duration,
            :coach_header_moduleId)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':coach_header_duration', $json['coach_header_duration'], PDO::PARAM_INT);
            $stmt->bindParam(':coach_header_moduleId', $json['coach_header_moduleId'], PDO::PARAM_INT);
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

    function addCoachDetails($json)
    {
        $json = json_decode($json, true);
        try {
            // Check if coach_detail_content is an array and handle each entry
            if (is_array($json['coach_detail_content'])) {
                foreach ($json['coach_detail_content'] as $content) {
                    $sql = "INSERT INTO tbl_coach_detail (	
                coach_detail_coachheaderId,
                coach_detail_content,
                coach_detail_renarks	
                ) VALUES (
                :coach_detail_coachheaderId,	
                :coach_detail_content,	
                :coach_detail_renarks)";
                    $stmt = $this->pdo->prepare($sql);
                    $stmt->bindParam(':coach_detail_coachheaderId', $json['coach_detail_coachheaderId'], PDO::PARAM_INT);

                    // Bind each content entry separately
                    $stmt->bindParam(':coach_detail_content', $content, PDO::PARAM_STR);

                    $stmt->bindParam(':coach_detail_renarks', $json['coach_detail_renarks'], PDO::PARAM_STR);
                    $stmt->execute();
                }
            } else {
                // If it's not an array, insert it directly
                $sql = "INSERT INTO tbl_coach_detail (	
            coach_detail_coachheaderId,
            coach_detail_content,
            coach_detail_renarks	
            ) VALUES (
            :coach_detail_coachheaderId,	
            :coach_detail_content,	
            :coach_detail_renarks)";
                $stmt = $this->pdo->prepare($sql);
                $stmt->bindParam(':coach_detail_coachheaderId', $json['coach_detail_coachheaderId'], PDO::PARAM_INT);
                $stmt->bindParam(':coach_detail_content', $json['coach_detail_content'], PDO::PARAM_STR);
                $stmt->bindParam(':coach_detail_renarks', $json['coach_detail_renarks'], PDO::PARAM_STR);
                $stmt->execute();
            }

            // Return the last inserted ID for the last entry
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
    function addFolder($json)
    {
        $json = json_decode($json, true);
        try {
            // Check if the project_cardsId already exists for this projectId
            $checkSql = "SELECT COUNT(*) FROM tbl_folder WHERE projectId = :projectId AND project_cardsId = :project_cardsId";
            $checkStmt = $this->pdo->prepare($checkSql);
            $checkStmt->bindParam(':projectId', $json['projectId'], PDO::PARAM_INT);
            $checkStmt->bindParam(':project_cardsId', $json['project_cardsId'], PDO::PARAM_INT);
            $checkStmt->execute();
            $count = $checkStmt->fetchColumn();

            if ($count > 0) {
                // If the project_cardsId already exists for this projectId, don't insert
                return json_encode(['success' => false, 'message' => 'This card has already been added to this project.']);
            }

            // If the project_cardsId doesn't exist for this projectId, proceed with insertion
            $sql = "INSERT INTO tbl_folder(projectId, project_moduleId, activities_detailId, project_cardsId, outputId, instructionId, coach_detailsId)
            VALUES (
                :projectId,
                :project_moduleId,
                :activities_detailId,
                :project_cardsId,
                :outputId,
                :instructionId,
                :coach_detailsId
            )";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':projectId', $json['projectId'], PDO::PARAM_INT);
            $stmt->bindParam(':project_moduleId', $json['project_moduleId'], PDO::PARAM_INT);
            $stmt->bindParam(':activities_detailId', $json['activities_detailId'], PDO::PARAM_INT);
            $stmt->bindParam(':project_cardsId', $json['project_cardsId'], PDO::PARAM_INT);
            $stmt->bindParam(':outputId', $json['outputId'], PDO::PARAM_INT);
            $stmt->bindParam(':instructionId', $json['instructionId'], PDO::PARAM_INT);
            $stmt->bindParam(':coach_detailsId', $json['coach_detailsId'], PDO::PARAM_INT);
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

    function updateData($json)
    {
        $data = json_decode($json, true);
        $type = $data['type'];
        $content = $data['content'];
        $id = $data['id'];

        try {
            switch ($type) {
                case 'activity':
                    $sql = "UPDATE tbl_activities_details SET activities_details_content = :content WHERE activities_details_id = :id";
                    break;
                case 'output':
                    $sql = "UPDATE tbl_outputs SET outputs_content = :content WHERE outputs_id = :id";
                    break;
                case 'instruction':
                    $sql = "UPDATE tbl_instruction SET instruction_content = :content WHERE instruction_id = :id";
                    break;
                case 'coachDetail':
                    $sql = "UPDATE tbl_coach_detail SET coach_detail_content = :content WHERE coach_detail_id = :id";
                    break;
                default:
                    return json_encode(['error' => 'Invalid update type']);
            }

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':content', json_encode($content), PDO::PARAM_STR);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                return json_encode(['success' => true, 'message' => ucfirst($type) . ' updated successfully']);
            } else {
                return json_encode(['success' => false, 'message' => 'No changes made']);
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
    function getFolder($userId)
    {
        try {
            $sql = "SELECT 
                tbl_folder.*,
                tbl_project_modules.*,
                tbl_activities_details.*,
                tbl_project_cards.*,
                tbl_outputs.*,
                tbl_instruction.*,
                tbl_coach_detail.*,
                tbl_project.*,
                tbl_module_master.*,
                tbl_front_cards.*,
                tbl_back_cards_header.*,
                tbl_activities_header.*
            FROM tbl_folder
            LEFT JOIN tbl_project_modules ON tbl_folder.project_moduleId = tbl_project_modules.project_modules_id
            LEFT JOIN tbl_activities_details ON tbl_folder.activities_detailId = tbl_activities_details.activities_details_id
            LEFT JOIN tbl_project_cards ON tbl_folder.project_cardsId = tbl_project_cards.project_cards_id
            LEFT JOIN tbl_outputs ON tbl_folder.outputId = tbl_outputs.outputs_id
            LEFT JOIN tbl_instruction ON tbl_folder.instructionId = tbl_instruction.instruction_id
            LEFT JOIN tbl_coach_detail ON tbl_folder.coach_detailsId = tbl_coach_detail.coach_detail_id
            LEFT JOIN tbl_project ON tbl_project.project_id = tbl_folder.projectId
            LEFT JOIN tbl_activities_header ON tbl_activities_header.activities_header_id = tbl_activities_details.activities_details_headerId
            LEFT JOIN tbl_module_master ON tbl_module_master.module_master_id = tbl_project_modules.project_modules_masterId
            LEFT JOIN tbl_front_cards ON tbl_project_cards.project_cards_cardId = tbl_front_cards.cards_id
            LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_id = tbl_project_cards.project_cards_cardId
            WHERE tbl_project.project_userId = :userId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':userId', $userId, PDO::PARAM_INT);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Group folders by projectId to handle multiple data per project
            $groupedFolders = [];
            foreach ($returnValue as $folder) {
                $projectId = $folder['projectId'];
                
                if (!isset($groupedFolders[$projectId])) {
                    $groupedFolders[$projectId] = $folder;
                    // Initialize arrays for multiple values
                    $groupedFolders[$projectId]['activities_header_durations'] = [];
                    $groupedFolders[$projectId]['cards'] = [];
                }
                
                // Add duration to the durations array if it's not null (removed uniqueness check)
                if ($folder['activities_header_duration'] !== null) {
                    $groupedFolders[$projectId]['activities_header_durations'][] = 
                        $folder['activities_header_duration'];
                }

                // Add card if it's not already added
                if ($folder['cards_id'] && !in_array($folder['cards_id'], 
                    array_column($groupedFolders[$projectId]['cards'], 'cards_id'))) {
                    $groupedFolders[$projectId]['cards'][] = [
                        'cards_id' => $folder['cards_id'],
                        'cards_title' => $folder['cards_title'],
                        'back_cards_header_id' => $folder['back_cards_header_id'],
                        'back_cards_header_title' => $folder['back_cards_header_title']
                    ];
                }
            }

            // Convert arrays to strings where needed
            foreach ($groupedFolders as &$folder) {
                // Keep activities_header_durations as an array and allow duplicates
                $folder['activities_header_duration'] = implode(', ', 
                    $folder['activities_header_durations']);

                $activitiesContent = json_decode($folder['activities_details_content'], true);
                $folder['activities_details_content'] = is_array($activitiesContent) ? 
                    implode("\n", $activitiesContent) : '';

                $outputsContent = json_decode($folder['outputs_content'], true);
                $folder['outputs_content'] = is_array($outputsContent) ? 
                    implode("\n", $outputsContent) : '';

                $instructionContent = json_decode($folder['instruction_content'], true);
                $folder['instruction_content'] = is_array($instructionContent) ? 
                    implode("\n", $instructionContent) : '';

                $coachDetailContent = json_decode($folder['coach_detail_content'], true);
                $folder['coach_detail_content'] = is_array($coachDetailContent) ? 
                    implode("\n", $coachDetailContent) : '';
            }

            return json_encode(['folders' => array_values($groupedFolders)]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . 
                " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . 
                " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }
    function getFolders()
    {
        $projectId = isset($_POST['projectId']) ? $_POST['projectId'] : '';
        try {
            $sql = "SELECT 
                tbl_folder.*,
                tbl_project_modules.*,
                tbl_activities_details.*,
                tbl_project_cards.*,
                tbl_outputs.*,
                tbl_instruction.*,
                tbl_coach_detail.*,
                tbl_project.*,
                tbl_module_master.*,
                tbl_front_cards.*,
                tbl_back_cards_header.*,
                tbl_activities_header.*
            FROM tbl_folder
            LEFT JOIN tbl_project_modules ON tbl_folder.project_moduleId = tbl_project_modules.project_modules_id
            LEFT JOIN tbl_activities_details ON tbl_folder.activities_detailId = tbl_activities_details.activities_details_id
            LEFT JOIN tbl_project_cards ON tbl_folder.project_cardsId = tbl_project_cards.project_cards_id
            LEFT JOIN tbl_outputs ON tbl_folder.outputId = tbl_outputs.outputs_id
            LEFT JOIN tbl_instruction ON tbl_folder.instructionId = tbl_instruction.instruction_id
            LEFT JOIN tbl_coach_detail ON tbl_folder.coach_detailsId = tbl_coach_detail.coach_detail_id
            LEFT JOIN tbl_project ON tbl_project.project_id = tbl_folder.projectId
            LEFT JOIN tbl_activities_header ON tbl_activities_header.activities_header_id = tbl_activities_details.activities_details_headerId
            LEFT JOIN tbl_module_master ON tbl_module_master.module_master_id = tbl_project_modules.project_modules_masterId
            LEFT JOIN tbl_front_cards ON tbl_project_cards.project_cards_cardId = tbl_front_cards.cards_id
            LEFT JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_id = tbl_project_cards.project_cards_cardId
            WHERE tbl_folder.projectId = :projectId
            GROUP BY tbl_folder.project_moduleId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':projectId', $projectId, PDO::PARAM_INT);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Check if any folders were found
            if (empty($returnValue)) {
                return json_encode(['success' => false, 'message' => 'No folders found for this project.']);
            }

            return json_encode(['success' => true, 'folders' => $returnValue]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function getCards1()
    {
        $projectId = isset($_POST['projectId']) ? $_POST['projectId'] : '';
        try {
            $sql = "SELECT *
            FROM tbl_folder
            INNER JOIN tbl_project_cards ON tbl_folder.project_cardsId = tbl_project_cards.project_cards_id
            INNER JOIN tbl_back_cards_header ON tbl_back_cards_header.back_cards_header_id = tbl_project_cards.project_cards_cardId
            INNER JOIN tbl_front_cards ON tbl_front_cards.cards_id = tbl_back_cards_header.back_cards_header_frontId
            WHERE tbl_folder.projectId = :projectId";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':projectId', $projectId, PDO::PARAM_INT);
            $stmt->execute();

            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch all matching records

            error_log("SQL Query: $sql");
            error_log("Result: " . print_r($returnValue, true));

            if (empty($returnValue)) {
                return json_encode(['success' => false, 'message' => 'No data found']);
            }

            return json_encode(['success' => true, 'data' => $returnValue]);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['success' => false, 'error' => 'Database error occurred: ' . $e->getMessage()]);
        } catch (Exception $e) {
            error_log("General error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
            return json_encode(['success' => false, 'error' => 'An error occurred: ' . $e->getMessage()]);
        }
    }

    function addAllData($json)
    {
        $data = json_decode($json, true);
        try {
            $this->pdo->beginTransaction();

            // Check if project already exists
            $checkProjectStmt = $this->pdo->prepare("SELECT project_id FROM tbl_project WHERE project_title = :title");
            $checkProjectStmt->execute([':title' => $data['project']['project_title']]);
            $existingProject = $checkProjectStmt->fetch(PDO::FETCH_ASSOC);

            if ($existingProject) {
                $projectId = $existingProject['project_id'];
                
                // Check if the module already exists for this project
                $checkModuleStmt = $this->pdo->prepare("SELECT project_modules_id FROM tbl_project_modules 
                    WHERE project_modules_projectId = :projectId 
                    AND project_modules_masterId = :masterId");
                $checkModuleStmt->execute([
                    ':projectId' => $projectId,
                    ':masterId' => $data['mode']['project_modules_masterId']
                ]);
                
                if ($checkModuleStmt->fetch(PDO::FETCH_ASSOC)) {
                    $this->pdo->rollBack();
                    return json_encode([
                        'success' => false,
                        'message' => 'This module already exists for this project'
                    ]);
                }
            } else {
                // Insert new project if it doesn't exist
                $projectStmt = $this->pdo->prepare("INSERT INTO tbl_project (
                    project_userId,
                    project_subject_code,
                    project_subject_description,
                    project_title,
                    project_description,
                    project_start_date,
                    project_end_date
                ) VALUES (
                    :userId,
                    :subjectCode,
                    :subjectDesc,
                    :title,
                    :description,
                    :startDate,
                    :endDate
                )");

                $projectStmt->execute([
                    ':userId' => $data['project']['project_userId'],
                    ':subjectCode' => $data['project']['project_subject_code'],
                    ':subjectDesc' => $data['project']['project_subject_description'],
                    ':title' => $data['project']['project_title'],
                    ':description' => $data['project']['project_description'],
                    ':startDate' => $data['project']['project_start_date'],
                    ':endDate' => $data['project']['project_end_date']
                ]);
                $projectId = $this->pdo->lastInsertId();
            }

            // 2. Mode Handling
            $checkModeStmt = $this->pdo->prepare("SELECT project_modules_id FROM tbl_project_modules 
      WHERE project_modules_projectId = :projectId 
      AND project_modules_masterId = :masterId");
            $checkModeStmt->execute([
                ':projectId' => $projectId,
                ':masterId' => $data['mode']['project_modules_masterId']
            ]);
            $existingMode = $checkModeStmt->fetch(PDO::FETCH_ASSOC);

            if ($existingMode) {
                $modeId = $existingMode['project_modules_id'];
            } else {
                $modeStmt = $this->pdo->prepare("INSERT INTO tbl_project_modules 
          (project_modules_projectId, project_modules_masterId) 
          VALUES (:projectId, :masterId)");
                $modeStmt->execute([
                    ':projectId' => $projectId,
                    ':masterId' => $data['mode']['project_modules_masterId']
                ]);
                $modeId = $this->pdo->lastInsertId();
            }

            // 2. Add Duration
            $durationStmt = $this->pdo->prepare("INSERT INTO tbl_activities_header (activities_header_modulesId, activities_header_duration) VALUES (:moduleId, :duration)");
            $durationStmt->execute([
                ':moduleId' => $modeId,
                ':duration' => $data['duration']['activities_header_duration']
            ]);
            $durationId = $this->pdo->lastInsertId();

            // 3. Add Activity
            $activityStmt = $this->pdo->prepare("INSERT INTO tbl_activities_details (activities_details_remarks, activities_details_content, activities_details_headerId) VALUES (:remarks, :content, :headerId)");
            $activityStmt->execute([
                ':remarks' => $data['activity']['activities_details_remarks'],
                ':content' => $data['activity']['activities_details_content'],
                ':headerId' => $durationId
            ]);
            $activityId = $this->pdo->lastInsertId();

            // 4. Add Cards
            $cardIds = [];
            foreach ($data['cards'] as $card) {
                $cardStmt = $this->pdo->prepare("INSERT INTO tbl_project_cards (project_cards_cardId, project_cards_modulesId, project_cards_remarks) VALUES (:cardId, :moduleId, :remarks)");
                $cardStmt->execute([
                    ':cardId' => $card['project_cards_cardId'],
                    ':moduleId' => $modeId,
                    ':remarks' => $card['project_cards_remarks']
                ]);
                $cardIds[] = $this->pdo->lastInsertId();
            }

            // 5. Add Output
            $outputStmt = $this->pdo->prepare("INSERT INTO tbl_outputs (outputs_moduleId, outputs_remarks, outputs_content) VALUES (:moduleId, :remarks, :content)");
            $outputStmt->execute([
                ':moduleId' => $modeId,
                ':remarks' => $data['outputs']['outputs_remarks'],
                ':content' => $data['outputs']['outputs_content']
            ]);
            $outputId = $this->pdo->lastInsertId();

            // 6. Add Instruction
            $instructionStmt = $this->pdo->prepare("INSERT INTO tbl_instruction (instruction_remarks, instruction_modulesId, instruction_content) VALUES (:remarks, :moduleId, :content)");
            $instructionStmt->execute([
                ':remarks' => $data['instructions']['instruction_remarks'],
                ':moduleId' => $modeId,
                ':content' => $data['instructions']['instruction_content']
            ]);
            $instructionId = $this->pdo->lastInsertId();

            // 7. Add Coach Details
            $coachStmt = $this->pdo->prepare("INSERT INTO tbl_coach_detail (coach_detail_coachheaderId, coach_detail_content, coach_detail_renarks) VALUES (:headerId, :content, :remarks)");
            $coachStmt->execute([
                ':headerId' => $data['coachDetails']['coach_detail_coachheaderId'],
                ':content' => $data['coachDetails']['coach_detail_content'],
                ':remarks' => $data['coachDetails']['coach_detail_remarks']
            ]);
            $coachId = $this->pdo->lastInsertId();

            // Check if entry already exists in tbl_folder
            $checkFolderStmt = $this->pdo->prepare("SELECT COUNT(*) FROM tbl_folder 
                WHERE projectId = :projectId 
                AND project_moduleId = :project_moduleId 
                AND activities_detailId = :activities_detailId 
                AND project_cardsId = :project_cardsId 
                AND outputId = :outputId 
                AND instructionId = :instructionId 
                AND coach_detailsId = :coach_detailsId");

            // Iterate through each cardId and create a folder entry
            foreach ($cardIds as $cardId) {
                $checkFolderStmt->execute([
                    ':projectId' => $projectId,
                    ':project_moduleId' => $modeId,
                    ':activities_detailId' => $activityId,
                    ':project_cardsId' => $cardId,  // Use individual cardId instead of array
                    ':outputId' => $outputId,
                    ':instructionId' => $instructionId,
                    ':coach_detailsId' => $coachId
                ]);

                if ($checkFolderStmt->fetchColumn() == 0) {
                    $folderSql = "INSERT INTO tbl_folder (
                        projectId,
                        project_moduleId,
                        activities_detailId,
                        project_cardsId,
                        outputId,
                        instructionId,
                        coach_detailsId
                    ) VALUES (
                        :projectId,
                        :project_moduleId,
                        :activities_detailId,
                        :project_cardsId,
                        :outputId,
                        :instructionId,
                        :coach_detailsId
                    )";

                    $folderStmt = $this->pdo->prepare($folderSql);
                    $folderStmt->execute([
                        ':projectId' => $projectId,
                        ':project_moduleId' => $modeId,
                        ':activities_detailId' => $activityId,
                        ':project_cardsId' => $cardId,  // Use individual cardId instead of array
                        ':outputId' => $outputId,
                        ':instructionId' => $instructionId,
                        ':coach_detailsId' => $coachId
                    ]);
                }
            }

            $this->pdo->commit();
            return json_encode([
                'success' => true,
                'ids' => [
                    'modeId' => $modeId,
                    'durationId' => $durationId,
                    'activityId' => $activityId,
                    'cardIds' => $cardIds,
                    'outputId' => $outputId,
                    'instructionId' => $instructionId,
                    'coachId' => $coachId
                ]
            ]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            return json_encode(['success' => false, 'error' => $e->getMessage()]);
        }
    }
}

// Handle preflight requests for CORS (for OPTIONS request)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Instantiate the Get class with the database connection
$get = new Get1($pdo);

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
    case "addAllData":
        echo $get->addAllData($json);
        break;
    case "getFolder":
        echo $get->getFolder($_POST['userId']);
        break;
    case "getFolders":
        echo $get->getFolders();
        break;
    case "getModuleId":
        echo $get->getModuleId();
        break;
    case "getheaderId":
        echo $get->getModuleId();
        break;
    case "getCards":
        echo $get->getCards();
        break;
    case "projectModeId":
        echo $get->projectModeId();
        break;
    case "addMode":
        echo $get->addMode($json);
        break;
    case "addDuration":
        echo $get->addDuration($json);
        break;
    case "addActivity":
        echo $get->addActivity($json);
        break;
    case "addCards":
        echo $get->addCards($json);
        break;
    case "addOutput":
        echo $get->addOutput($json);
        break;
    case "addInstruction":
        echo $get->addInstruction($json);
        break;
    case "addCoachHeader":
        echo $get->addCoachHeader($json);
        break;
    case "addCoachDetails":
        echo $get->addCoachDetails($json);
        break;
    case "addFolder":
        echo $get->addFolder($json);
        break;
    case "updateData":
        echo $get->updateData($json);
        break;
    case "getCards1":
        echo $get->getCards1();
        break;
}

