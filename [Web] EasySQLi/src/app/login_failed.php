<?php session_start(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login Failed</title>
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            padding: 8px;
        }
    </style>
</head>
<body>
    <h2>Login Failed</h2>
    <p><b>Reason:</b> <?php echo htmlspecialchars(isset($_SESSION['error_message']) ? $_SESSION['error_message'] : 'Invalid username or password.'); ?></p>
    <p><b>SQL Query:</b> <?php echo htmlspecialchars(isset($_SESSION['sql_query']) ? $_SESSION['sql_query'] : 'N/A'); ?></p>
    
    <p><b>Query Result:</b></p>
    <table>
        <thead>
            <tr>
                <th>username</th>
                <th>password</th>
                <th>role</th>
            </tr>
        </thead>
    <?php if (isset($_SESSION['sql_result']) && is_array($_SESSION['sql_result']) && !empty($_SESSION['sql_result'])): ?>
        <tbody>
            <?php foreach ($_SESSION['sql_result'] as $row): ?>
                <tr>
                    <td><?php echo htmlspecialchars($row['username']); ?></td>
                    <td><?php echo htmlspecialchars($row['password']); ?></td>
                    <td><?php echo htmlspecialchars($row['role']); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    <?php endif; ?>
    </table>

    <br>
    <a href="login.html">Back to Login</a>
</body>
</html>
<?php
    unset($_SESSION['error_message']);
    unset($_SESSION['sql_query']);
    unset($_SESSION['sql_result']);
?>