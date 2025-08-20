<?php
define('NL', PHP_EOL);

$db_file = '/db/islab.db';

echo "====== Database Initialization Script Start ======" . NL;

try {
    if (file_exists($db_file)) {
        unlink($db_file);
        echo "[INFO] Detected old database file, successfully deleted." . NL;
    }

    $pdo = new PDO('sqlite:' . $db_file);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "[INFO] Successfully created/connected to new database: {$db_file}" . NL;

    $sql = <<<'SQL'
    PRAGMA foreign_keys = ON;

    CREATE TABLE members (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('PROFESSOR', 'STUDENT', 'GUEST')),
        join_date TEXT NOT NULL DEFAULT (CURRENT_DATE)
    );

    CREATE TABLE courses (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        course_code TEXT UNIQUE NOT NULL,
        course_name TEXT NOT NULL
    );

    CREATE TABLE student_scores (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        course_code TEXT NOT NULL,
        score INTEGER NOT NULL,
        FOREIGN KEY (username) REFERENCES members(username),
        FOREIGN KEY (course_code) REFERENCES courses(course_code)
    );
    
    CREATE TABLE secrets (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        flag TEXT NOT NULL
    );

    INSERT INTO members (username, password, role, join_date) VALUES
    ('CYSun', 'VlF+cDhtPVVLc0JjIW9aKmNNIXZiZUR5V3JeaEE+ODJNNHNYVWNyK0V5Uilh', 'PROFESSOR', '2022-08-01'),
    ('Paul', 'aGVsbG9ASWFtUEFVTDEyMw==', 'STUDENT', '2024-04-05'),
    ('YPP', 'b3V0aG91c2Utc3Bpbm5pbmctYWxleGlzPT0=', 'STUDENT', '2024-06-20'),
    ('younglee', 'c3VwZXJzZWN1cmV0c2VjcmV0c2VjcmV0', 'STUDENT', '2023-12-30'),
    ('Win', 'aWFtd2luMjAyNA==', 'STUDENT', '2023-12-20'),
    ('Adb2', 'MTIwNDEyMDQ=', 'STUDENT', '2024-01-01'),
    ('WIFI', 'c3VjY2Vzc2Z1bGx5X2xlYWtlZF9zZWNyZXRfZGF0YQ==', 'STUDENT', '2024-01-31'),
    ('robert', 'Z2lQOWNOTlk=', 'STUDENT', '2024-01-31'),
    ('pudding483', 'cHVkZGluZzQ4Mw==', 'GUEST', '2024-08-09');

    INSERT INTO courses (course_code, course_name) VALUES
    ('342798', '安全程式設計'),
    ('350363', '作業系統'),
    ('350371', '軟體安全與逆向工程'),
    ('349994', '密碼學'),
    ('350369', '巨量資料探勘與應用');

    INSERT INTO student_scores (username, course_code, score) VALUES
    ('robert', '342798', 90),
    ('robert', '350363', 76),
    ('robert', '350371', 97),
    ('robert', '349994', 89),
    ('Paul', '342798', 75),
    ('Paul', '350363', 86),
    ('Paul', '349994', 79),
    ('Paul', '350369', 74),
    ('YPP', '350363', 95),
    ('YPP', '349994', 99),
    ('younglee', '349994', 92),
    ('younglee', '350363', 88),
    ('Win', '342798', 85),
    ('Adb2', '350369', 75),
    ('Adb2', '350363', 92),
    ('Adb2', '342798', 99),
    ('WIFI', '350363', 85);
    
    INSERT INTO secrets (flag) VALUES
    ('當你看見此訊息時，表示你已成功找到 flag，恭喜獲得 flag !!!!!!!!'),
    ('is1abCTF{$UcCE5sFu11y_L34KeD_$EcRET_D@7A}');
    SQL;

    $pdo->exec($sql);
    echo "[INFO] Successfully created all tables and imported initial data!" . NL;
    exit(0);
}
catch (PDOException $e) {
    file_put_contents('php://stderr', "[ERROR] Database initialization failed: " . $e->getMessage() . NL);
    exit(1);
}
?>