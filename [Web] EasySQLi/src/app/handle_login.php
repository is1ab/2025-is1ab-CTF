<?php
session_start();
require_once(__DIR__ . '/connect_db.php');

$username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT username, password, role FROM members WHERE username = '$username'";
$result = $conn->query($sql);

$query_result_data = [];
if ($result) {
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $query_result_data[] = $row;
    }
}

if (count($query_result_data) === 1) {
    $user = $query_result_data[0];
    if (base64_encode($password) === $user['password']) {
        $_SESSION['username'] = $user['username'];
        $_SESSION['role'] = $user['role'];
        header("Location: user_space.php");
        exit;
    } else {
        $_SESSION['error_message'] = 'Invalid password.';
        $_SESSION['sql_query'] = $sql;
        $_SESSION['sql_result'] = $query_result_data;
        header("Location: login_failed.php");
        exit;
    }
} else {
    $_SESSION['error_message'] = 'User not found.';
    $_SESSION['sql_query'] = $sql;
    $_SESSION['sql_result'] = $query_result_data;
    header("Location: login_failed.php");
    exit;
}

$conn->close();
?>