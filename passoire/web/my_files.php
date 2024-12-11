<?php
// Include database connection and start session
include 'db_connect.php';
session_start();

// Check if the user is logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: connexion.php");
    exit();
}

// Get user ID
$user_id = $_SESSION['user_id'];

// Handle file deletion
if (isset($_POST['delete']) && isset($_POST['file_id'])) {
    $file_id = $_POST['file_id'];

    // Retrieve file path before deletion using prepared statement
    $stmt = $conn->prepare("SELECT path FROM files WHERE id = ? AND ownerid = ?");
    $stmt->bind_param("ii", $file_id, $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $file = $result->fetch_assoc();

    if ($file) {
        // Delete the physical file
        if (file_exists($file['path'])) {
            unlink($file['path']);
        }

        // Delete from database using prepared statements
        $stmt = $conn->prepare("DELETE FROM links WHERE fileid = ?");
        $stmt->bind_param("i", $file_id);
        $stmt->execute();

        $stmt = $conn->prepare("DELETE FROM files WHERE id = ? AND ownerid = ?");
        $stmt->bind_param("ii", $file_id, $user_id);
        $stmt->execute();
    }
}

// Fetch user's files using prepared statement
$stmt = $conn->prepare("
    SELECT f.*, l.hash 
    FROM files f 
    LEFT JOIN links l ON f.id = l.fileid 
    WHERE f.ownerid = ? 
    ORDER BY f.date DESC
");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$files = $result->fetch_all(MYSQLI_ASSOC);

// Rest of the HTML remains unchanged
?>

<!DOCTYPE html>
<html>
	<head>
		<title>Passoire: A simple file hosting server</title>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="./style/w3.css">
		<link rel="stylesheet" href="./style/w3-theme-blue-grey.css">
		<link rel="stylesheet" href="./style/css/fontawesome.css">
		<link href="./style/css/brands.css" rel="stylesheet" />
		<link href="./style/css/solid.css" rel="stylesheet" />
		<style>
			html, body, h1, h2, h3, h4, h5 {font-family: "Open Sans", sans-serif}
			.error { color: red; }
      .success { color: green; }
		</style>
	</head>
	<body class="w3-theme-l5">
	
		<?php include 'navbar.php'; ?>
		
		
		
		<!-- Page Container -->
		<div class="w3-container w3-content" style="max-width:1400px;margin-top:80px">
			<div class="w3-col m12">
		
		
				<div class="w3-card w3-round w3-white">
					<div class="w3-container w3-center center-c">
						<h1>My Files</h1>
						<br>
					
					
						<a href="file_upload.php" class="w3-button w3-theme w3-padding" title="Files"><i class="fa fa-folder-open"></i>Upload File(s)</a>
					</div>
					<br>
					
					
					<div class="w3-container w3-center center-c w3-white  w3-margin-bottom w3-padding-bottom">
					
					<?php if ($files): ?>
						  <table class="w3-table">
						      <tr>
						          <th>File Name</th>
						          <th>Type</th>
						          <th>Date Uploaded</th>
						          <th>Actions</th>
						      </tr>
						      <?php foreach ($files as $file): ?>
						          <tr>
						              <td><a href="link.php?file=<?= $file['hash'] ?>"><?= basename($file['path']) ?></a></td>
						              <td><?= htmlspecialchars($file['type']) ?></td>
						              <td><?= htmlspecialchars($file['date']) ?></td>
						              <td>
						                  <!-- Copy Link Button -->
						                  <button class="w3-button w3-theme w3-padding" onclick="copyLink('<?= $file['hash'] ?>')">Copy Link</button>
						                  
						                  <!-- Delete Button -->
						                  <form method="POST" action="my_files.php" style="display:inline;">
						                      <input type="hidden" name="file_id" value="<?= $file['id'] ?>">
						                      <button type="submit" class="w3-button w3-theme w3-padding" name="delete" onclick="return confirm('Are you sure you want to delete this file?')">Delete</button>
						                  </form>
						              </td>
						          </tr>
						      <?php endforeach; ?>
						  </table>
					<?php else: ?>
						  <p>You have not uploaded any files.</p>
					<?php endif; ?>
				
		<br>
				</div>
					<div class="w3-container w3-center center-c w3-white  w3-margin-bottom w3-padding-bottom">
					</div>
				</div>
			</div>
  	</div>
		<br>
		<!-- Footer -->
		<footer class="w3-container w3-theme-d3 w3-padding-16">
			<h5>About</h5>
		</footer>
  

    <!-- JavaScript for copying link -->
    <script>
        function copyLink(hash) {
            const link = window.location.origin + '/link.php?file=' + hash;
            navigator.clipboard.writeText(link).then(() => {
                alert('Link copied to clipboard: ' + link);
            }).catch(err => {
                alert('Failed to copy link: ' + err);
            });
        }
    </script>
</body>
</html>
