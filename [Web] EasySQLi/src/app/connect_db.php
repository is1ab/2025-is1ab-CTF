<?php
$db_path = realpath('/db/islab.db');

try {
    $conn = new SQLite3($db_path);
} catch (Exception $e) {
    die("SQLite connection failed: " . $e->getMessage());
}

if (!$conn) {
    die("SQLite connection failed.");
}
?>