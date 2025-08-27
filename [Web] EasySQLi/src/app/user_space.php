<?php
session_start();

if (!isset($_SESSION['username'])) {
    header("Location: login.html");
    exit;
}

$role = $_SESSION['role'];
$username = $_SESSION['username'];

// Rate Limiting Logic for professor's search
if ($role === 'PROFESSOR' && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['search_name'])) {
    $rate_limit_seconds = 3;
    if (isset($_SESSION['last_search_time']) && (time() - $_SESSION['last_search_time']) < $rate_limit_seconds) {
        header("Location: rate_limit_error.php");
        exit;
    }
    $_SESSION['last_search_time'] = time();
}

?>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>儀表板 - 成績查詢系統</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">成績查詢系統</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link">歡迎, <?php echo htmlspecialchars($username); ?> (<?php echo htmlspecialchars($role); ?>)</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="logout.php">登出</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <?php
        if ($role === 'PROFESSOR') {
            include 'query_score/all_student.php';
        } elseif ($role === 'STUDENT') {
            include 'query_score/personal.php';
        } else {
            echo "<div class='alert alert-info'>為什麼程式設計師常常分不清處萬聖節和聖誕節？<br>因為 OCT 31 = DEC 25</div>";
        }
        ?>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>