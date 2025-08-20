<?php
// This script is included in user_space.php.
// The following line ensures the database connection is available
// and uses a robust path to the config file.
require_once(__DIR__ . '/../connect_db.php');

$search_name = isset($_POST['search_name']) ? $_POST['search_name'] : '';

$sql = "SELECT ss.username, c.course_name, ss.score
        FROM student_scores ss
        JOIN courses c ON ss.course_code = c.course_code";

if (!empty($search_name)) {
    $sql .= " WHERE ss.username = '$search_name'";
}

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
        <h3 class="card-title">所有學生成績</h3>
    </div>
    <div class="card-body">
        <form action="user_space.php" method="post" class="mb-3">
            <div class="input-group">
                <input type="text" name="search_name" class="form-control" placeholder="輸入學生姓名以篩選" value="<?php echo htmlspecialchars($search_name); ?>">
                <button class="btn btn-primary" type="submit">查詢</button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>使用者名稱</th>
                        <th>課程</th>
                        <th>成績</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($scores)): ?>
                        <tr>
                            <td colspan="3" class="text-center">查無紀錄。</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($scores as $score): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($score['username']); ?></td>
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