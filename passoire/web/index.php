<?php
// Start the session to check for login status
session_start();

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
		
		
			<!-- The Grid -->
			<div class="w3-row">
				
		<?php
		include 'db_connect.php';
		$user = "";
		// Check if the user is logged in
		if (isset($_SESSION['user_id'])) {

			// Get user ID
			$user_id = $_SESSION['user_id'];

			// Use prepared statement
			$sql = "SELECT u.login, u.email, ui.birthdate, ui.location, ui.bio, ui.avatar 
					FROM users u 
					LEFT JOIN userinfos ui ON u.id = ui.userid 
					WHERE u.id = ?";
			$stmt = $conn->prepare($sql);
			$stmt->bind_param("i", $user_id);
			$stmt->execute();
			$result = $stmt->get_result();

			if ($result->num_rows > 0) {
					// Fetch the first row of results into an array
					$user = $result->fetch_assoc();
			} else {
					echo "No results found.";
			}
		}
		?>
		
			<!-- Left Column -->
			<div class="w3-col m3">
				<!-- Profile -->
				<div class="w3-card w3-round w3-white">
					<div class="w3-container">
					
				<?php if (isset($_SESSION['user_id'])): ?>
						
					 <h4 class="w3-center"><?php echo htmlspecialchars($user['login'], ENT_QUOTES, 'UTF-8'); ?></h4>
					 <p class="w3-center"><img src="<?php echo $user['avatar']?>" class="w3-circle" style="height:106px;width:106px" alt="Avatar"></p>
					 <hr>
					 <p><i class="fa fa-pencil fa-fw w3-margin-right w3-text-theme"></i> <?php echo htmlspecialchars($user['bio'], ENT_QUOTES, 'UTF-8'); ?></p>
					 <p><i class="fa fa-home fa-fw w3-margin-right w3-text-theme"></i> <?php echo htmlspecialchars($user['location'], ENT_QUOTES, 'UTF-8'); ?></p>
					 <p><i class="fa fa-birthday-cake fa-fw w3-margin-right w3-text-theme"></i> <?php echo htmlspecialchars($user['birthdate'], ENT_QUOTES, 'UTF-8'); ?></p>
				<?php else: ?>
					 <h4 class="w3-center">Not Connected</h4>
					 <hr>
					 <p><a href="connexion.php">Log in here.</a></p>
				<?php endif; ?>
			
					
					 
					</div>
				</div>
			</div>
		
		
			<!-- Middle Column -->
			<div class="w3-col m7">

				<?php include 'message_board.php' ?>
				
			<!-- End Middle Column -->
			</div>
		
			<!-- Right Column -->
			<div class="w3-col m2">
				<div class="w3-card w3-round w3-white w3-center">
					<div class="w3-container">
						<h5>Deadlines Riminder:</h5>
						<hr>
						<p><strong>Deadline 1</strong></p>
						<p>Friday 2024-11-22 23:59</p>
						<hr>
						<p><strong>Deadline 2</strong></p>
						<p>Friday 2024-12-06 23:59</p>
						<hr>
						<p><strong>Deadline 3</strong></p>
						<p>Friday 2024-12-20 23:59</p>
					</div>
				</div>
			</div>
			
			
		</div>
		<br>
		<!-- Footer -->
		<footer class="w3-container w3-theme-d3 w3-padding-16">
			<h5>About</h5>
			v-0.1.0
		</footer>
		 
		<script>
		// Accordion
		function toggleHideShow(id) {
			var x = document.getElementById(id);
			if (x.className.indexOf("w3-show") == -1) {
				x.className += " w3-show";
				x.previousElementSibling.className += " w3-theme-d1";
			} else { 
				x.className = x.className.replace("w3-show", "");
				x.previousElementSibling.className = 
				x.previousElementSibling.className.replace(" w3-theme-d1", "");
			}
		}

		// Used to toggle the menu on smaller screens when clicking on the menu button
		function openNav() {
			var x = document.getElementById("navDemo");
			if (x.className.indexOf("w3-show") == -1) {
				x.className += " w3-show";
			} else { 
				x.className = x.className.replace(" w3-show", "");
			}
		}
		</script>
	</body>
</html>
