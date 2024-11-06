<?php

// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}



use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Include necessary PHPMailer files
require 'phpmailer/src/Exception.php';
require_once "phpmailer/src/PHPMailer.php";
require 'phpmailer/src/SMTP.php';

// Database connection (ensure this file exists and has the correct PDO object)
include 'db_connection.php';

class User
{
    private $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    function getEmail($email)
    {
        try {
            $sql = "SELECT user_email FROM tbl_users WHERE user_email = :email";

            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $email, PDO::PARAM_STR);
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

    function generateOTP($email)
    {
        try {
            $otp = rand(100000, 999999); // Generate a 6-digit OTP
            $sql = "UPDATE tbl_users SET otp = :otp WHERE user_email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':otp', $otp, PDO::PARAM_INT);
            $stmt->bindParam(':email', $email, PDO::PARAM_STR);
            $stmt->execute();

            // Send the OTP email
            $this->sendEmail($email, $otp);

            // Return the OTP in the response for testing purposes
            return json_encode(['success' => true, 'otp' => $otp, 'message' => 'OTP sent to email']);
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        }
    }

    function verifyOTPAndUpdatePassword($email, $otp, $newPassword)
    {
        try {
            $sql = "SELECT otp FROM tbl_users WHERE user_email = :email";
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindParam(':email', $email, PDO::PARAM_STR);
            $stmt->execute();
            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result && $result['otp'] == $otp) {
                $sql = "UPDATE tbl_users SET users_password = :password WHERE user_email = :email";
                $stmt = $this->pdo->prepare($sql);
                $stmt->bindParam(':password', $newPassword, PDO::PARAM_STR);
                $stmt->bindParam(':email', $email, PDO::PARAM_STR);
                $stmt->execute();

                return json_encode(['success' => true, 'message' => 'Password updated successfully']);
            } else {
                return json_encode(['error' => 'Invalid OTP']);
            }
        } catch (PDOException $e) {
            error_log("Database error: " . $e->getMessage());
            return json_encode(['error' => 'Database error occurred']);
        }
    }

    function sendEmail($email, $otp)
    {
        $mail = new PHPMailer(true);
        try {
            // Enable verbose debug output
            $mail->SMTPDebug = 0; // Set to 0 in production

            // Server settings
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'calmaj2003@gmail.com'; // Use environment variables
            $mail->Password = 'bxcb afdi ddtj fuxs'; // Use environment variables
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = 587;

            // Recipients
            $mail->setFrom('your-email@gmail.com', 'Your App Name');
            $mail->addAddress($email);

            // Content
            $mail->isHTML(true);
            $mail->Subject = 'OTP for Password Reset';
            $mail->Body    = 'Your OTP is: ' . $otp;

            $mail->send();
            return json_encode(['success' => true, 'message' => 'OTP sent to email']);
        } catch (Exception $e) {
            error_log("Mailer Error: " . $mail->ErrorInfo);
            return json_encode(['error' => 'Email could not be sent. Error: ' . $mail->ErrorInfo]);
        }
    }
}

// Handle preflight requests for CORS (for OPTIONS request)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Instantiate the User class
$user = new User($pdo);

$json = isset($_POST['json']) ? json_decode($_POST['json'], true) : [];
// Determine the request method and check for the operation
$operation = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $operation = isset($_POST['operation']) ? $_POST['operation'] : '';
} else {
    echo json_encode(['error' => 'Invalid request method']);
    exit;
}

// Handle different operations based on the request
try {
    switch ($operation) {
        case 'getEmail':
            $email = isset($json['email']) ? $json['email'] : '';
            echo $user->getEmail($email);
            break;
        case 'generateOTP':
            $email = isset($json['email']) ? $json['email'] : '';
            echo $user->generateOTP($email);
            break;
        case 'verifyOTPAndUpdatePassword':
            $email = isset($json['email']) ? $json['email'] : '';
            $otp = isset($json['otp']) ? $json['otp'] : '';
            $newPassword = isset($json['newPassword']) ? $json['newPassword'] : '';
            echo $user->verifyOTPAndUpdatePassword($email, $otp, $newPassword);
            break;
        case 'sendEmail':
            $email = isset($json['email']) ? $json['email'] : '';
            $otp = isset($json['otp']) ? $json['otp'] : '';
            echo $user->sendEmail($email, $otp);
            break;

        default:
            echo json_encode(['error' => 'Invalid operation']);
            break;
    }
} catch (Exception $e) {
    error_log("Unexpected error: " . $e->getMessage());
    echo json_encode(['error' => 'An unexpected error occurred']);
}
