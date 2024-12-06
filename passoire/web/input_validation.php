<?php
/**
 * Validates and sanitizes input parameters for database queries
 * 
 * @param mixed $input The input to be validated
 * @param string $type The expected type of input
 * @param int $max_length Maximum allowed length of the input
 * @param array $options Additional validation options
 * @return mixed Sanitized input or false if validation fails
 */
function validateInput($input, $type = 'string', $max_length = 255, $options = []) {
    // Default options
    $default_options = [
        'allow_empty' => false,
        'regex' => null,
        'trim' => true,
    ];
    $options = array_merge($default_options, $options);

    // Trim if specified
    if ($options['trim'] && is_string($input)) {
        $input = trim($input);
    }

    // Check if input is empty
    if (empty($input)) {
        if ($options['allow_empty']) {
            return $input;
        }
        return false;
    }

    // Type validation
    switch ($type) {
        case 'string':
            if (!is_string($input)) {
                return false;
            }
            break;
        case 'int':
            if (!filter_var($input, FILTER_VALIDATE_INT)) {
                return false;
            }
            break;
        case 'email':
            if (!filter_var($input, FILTER_VALIDATE_EMAIL)) {
                return false;
            }
            break;
        case 'url':
            if (!filter_var($input, FILTER_VALIDATE_URL)) {
                return false;
            }
            break;
        default:
            // Custom type or unknown type
            if (!is_string($input)) {
                return false;
            }
    }

    // Length validation
    if (strlen($input) > $max_length) {
        return false;
    }

    // Regex validation if specified
    if ($options['regex'] && !preg_match($options['regex'], $input)) {
        return false;
    }

    // Sanitize based on type
    switch ($type) {
        case 'string':
            return htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        case 'email':
            return filter_var($input, FILTER_SANITIZE_EMAIL);
        case 'int':
            return filter_var($input, FILTER_SANITIZE_NUMBER_INT);
        default:
            return $input;
    }
}

/**
 * Validates and prepares input for database queries
 * 
 * @param mysqli $conn Database connection
 * @param string $sql SQL query
 * @param array $params Parameters to bind
 * @return mysqli_stmt|false Prepared statement or false if validation fails
 */
function prepareQuery($conn, $sql, $params) {
    // Prepare the statement
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        // Handle preparation error
        error_log("Query preparation failed: " . $conn->error);
        return false;
    }

    // If no parameters, return the statement
    if (empty($params)) {
        return $stmt;
    }

    // Build type string and values array for bind_param
    $types = '';
    $values = [];

    foreach ($params as $param) {
        switch (true) {
            case is_int($param):
                $types .= 'i';
                break;
            case is_double($param):
                $types .= 'd';
                break;
            case is_string($param):
                $types .= 's';
                break;
            default:
                $types .= 'b';
        }
        $values[] = $param;
    }

    // Bind parameters dynamically
    if (!empty($types)) {
        $bind_names = [];
        foreach ($values as $key => $value) {
            $bind_names[$key] = &$values[$key];
        }
        
        // Use call_user_func_array to bind parameters dynamically
        call_user_func_array([$stmt, 'bind_param'], array_merge([$types], $bind_names));
    }

    return $stmt;
}