<?php
// This script is included in user_space.php.
// The following line ensures the database connection is available
// and uses a robust path to the config file.
require_once(__DIR__ . '/../connect_db.php');

$username = $_SESSION['username'];

$sql = "SELECT ss.username, c.course_name, ss.score
        FROM student_scores ss
        JOIN courses c ON ss.course_code = c.course_code
        WHERE ss.username = '$username'";

$result = $conn->query($sql);

$scores = [];
if ($result) {
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $scores[] = $row;
    }
}
?>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">您的成績</h3>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>課程</th>
                        <th>成績</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($scores)): ?>
                        <tr>
                            <td colspan="2" class="text-center">找不到您的成績紀錄。</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($scores as $score): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($score['course_name']); ?></td>
                            <td><?php echo htmlspecialchars($score['score']); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>