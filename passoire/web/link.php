<?php
// Include database connection
include 'db_connect.php';
session_start();

if (!isset($_SESSION['user_id'])) {
    header("Location: connexion.php");
    exit();
}

// Check if 'file' parameter is present in the query string
if (!isset($_GET['file'])) {
    // If not, redirect to home page or show an error message
    header("Location: index.php");
    exit();
}

// Get the hash value from the query string and provide xss protection
$hash = htmlspecialchars($_GET['file'], ENT_QUOTES, 'UTF-8');

// Use prepared statement
$stmt = $conn->prepare("SELECT f.path, f.type FROM links l JOIN files f ON l.fileid = f.id WHERE l.hash = ? LIMIT 1");
$stmt->bind_param("s", $hash);
$stmt->execute();
$result = $stmt->get_result();
$file = $result->fetch_assoc();

if ($file) {
    // File found, prepare the download
    $file_path = $file['path'];
    $file_type = $file['type'];
    $file_name = basename($file_path);  // Get the file name from the path

    // Check if the file exists on the server
    if (file_exists($file_path)) {
        // Set headers to force the file download
        header('Content-Description: File Transfer');
        header('Content-Type: ' . $file_type);
        header('Content-Disposition: attachment; filename="' . $file_name . '"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($file_path));
        header('X-Custom-Info: path="' . $file_path . '"');

        // Clear output buffer and read the file
        ob_clean();
        flush();
        readfile($file_path);
        exit();
    } else {
        echo "File does not exist.";
    }
} else {
    // File not found, display error or redirect
    echo "Invalid or expired link.";
    exit();
}
?>
