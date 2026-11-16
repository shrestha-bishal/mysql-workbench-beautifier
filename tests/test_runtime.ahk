#SingleInstance Force

keywordsFile := A_ScriptDir . "\..\config\keywords.txt"
#Include %A_ScriptDir%\..\src\beautifier.ahk
runtimeTestMode := true

resultsFile := A_Temp . "\mysql-workbench-beautifier-runtime-tests.txt"
FileDelete, %resultsFile%
failures := 0

RunCase("keyword followed by space", "select", " ", "SELECT ")
RunCase("keyword followed by comma", "create", ",", "CREATE,")
RunCase("digits prevent partial match", "select1", " ", "select1 ")
RunCase("identifier suffix prevents partial match", "myselect", " ", "myselect ")
RunCase("underscore remains part of identifier", "select_name", " ", "select_name ")
RunBackspaceCase()
RunControlBackspaceCase()
RunSqlCase("select query with joins and aggregates"
    , "select u.id, u.name, count(o.id) as order_count from users u left join orders o on o.user_id = u.id where u.active = 1 group by u.id, u.name having count(o.id) > 0 order by order_count desc limit 10;"
    , "SELECT u.id, u.name, COUNT(o.id) AS order_count FROM users u LEFT JOIN orders o ON o.user_id = u.id WHERE u.active = 1 GROUP BY u.id, u.name HAVING COUNT(o.id) > 0 ORDER BY order_count DESC LIMIT 10;")
RunSqlCase("wildcard select"
    , "select * from users;"
    , "SELECT * FROM users;")
RunSqlCase("repeated wildcard selects"
    , "select * from`nselect * from`nselect * from`nselect * from"
    , "SELECT * FROM`nSELECT * FROM`nSELECT * FROM`nSELECT * FROM")
RunSqlCase("quoted value resumes formatting on same line"
    , "select 'select from', ""as"" as title, ``from`` from users where name = 'it''s ok' and active = true;"
    , "SELECT 'select from', ""as"" AS title, ``from`` FROM users WHERE name = 'it''s ok' AND active = TRUE;")
RunSqlCase("comments, strings, and multiple statements"
    , "-- select this comment stays lowercase`nselect id from users; # update this comment too`nupdate users set active = false where id = 1;"
    , "-- select this comment stays lowercase`nSELECT id FROM users; # update this comment too`nUPDATE users SET active = FALSE WHERE id = 1;")
RunSqlCase("create table with types and constraints"
    , "create table audit_log (id bigint unsigned not null auto_increment primary key, created_at datetime default current_timestamp, message varchar(255), constraint audit_log_check check (id > 0));"
    , "CREATE TABLE audit_log (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, message VARCHAR(255), CONSTRAINT audit_log_check CHECK (id > 0));")
RunSqlCase("transaction and case expression"
    , "start transaction; update accounts set balance = case when id = 1 then balance - 10 else balance end; commit;"
    , "START TRANSACTION; UPDATE accounts SET balance = CASE WHEN id = 1 THEN balance - 10 ELSE balance END; COMMIT;")
RunSqlCase("mixed case keywords"
    , "SeLeCt id FrOm users WhErE active = true;"
    , "SELECT id FROM users WHERE active = TRUE;")
RunSqlCase("user variables do not block later keywords"
    , "select @select as current_value from users where id = $select;"
    , "SELECT @select AS current_value FROM users WHERE id = $select;")
RunSqlCase("CTE and window function"
    , "with ranked_orders as (select user_id, row_number() over (partition by user_id order by created_at desc) as rn from orders) select user_id from ranked_orders where rn = 1;"
    , "WITH ranked_orders AS (SELECT user_id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn FROM orders) SELECT user_id FROM ranked_orders WHERE rn = 1;")
RunSqlCase("multiline quote and block comment"
    , "select 'select`nfrom users' as note, id /* where this comment`nupdate stays lowercase */ from users where active = true;"
    , "SELECT 'select`nfrom users' AS note, id /* where this comment`nupdate stays lowercase */ FROM users WHERE active = TRUE;")
RunKeywordDictionaryCase()

FileAppend, % "Failures: " . failures . "`n", %resultsFile%
ExitApp, %failures%

RunCase(name, text, delimiter, expected)
{
    global runtimeTestBuffer
    ResetTestState()
    runtimeTestBuffer := ""
    TypeTracked(text)
    if (delimiter != "")
        HandleDelimiter(delimiter)
    RecordResult(name, runtimeTestBuffer, expected)
}

RunBackspaceCase()
{
    global runtimeTestBuffer
    ResetTestState()
    runtimeTestBuffer := ""
    TypeTracked("selecX")
    EmitKey("Backspace")
    HandleBackspace()
    TypeTracked("t")
    HandleDelimiter(" ")
    RecordResult("backspace correction", runtimeTestBuffer, "SELECT ")
}

RunControlBackspaceCase()
{
    global runtimeTestBuffer
    ResetTestState()
    runtimeTestBuffer := "oldword"
    ResetWord()
    HandleBackspace(true)
    runtimeTestBuffer := ""
    TypeTracked("select")
    HandleDelimiter(" ")
    RecordResult("Ctrl+Backspace then new keyword", runtimeTestBuffer, "SELECT ")
}

RunSqlCase(name, input, expected)
{
    global runtimeTestBuffer
    ResetTestState()
    runtimeTestBuffer := ""
    TypeSql(input)
    RecordResult(name, runtimeTestBuffer, expected)
}

RunKeywordDictionaryCase()
{
    global keywords, failures, resultsFile, runtimeTestBuffer
    checked := 0
    failedWords := ""

    for keyword, value in keywords {
        ResetTestState()
        runtimeTestBuffer := ""
        TypeTracked(keyword)
        HandleDelimiter(" ")
        StringUpper, expected, keyword

        if (runtimeTestBuffer != expected . " ") {
            failures += 1
            if (failedWords = "")
                failedWords := keyword . " (got [" . runtimeTestBuffer . "])"
            else
                failedWords .= ", " . keyword . " (got [" . runtimeTestBuffer . "])"
        }

        checked += 1
    }

    if (failedWords = "")
        FileAppend, % "PASS all " . checked . " dictionary entries`n", %resultsFile%
    else
        FileAppend, % "FAIL dictionary entries: " . failedWords . "`n", %resultsFile%
}

TypeSql(text)
{
    Loop, Parse, text
    {
        character := A_LoopField
        if (RegExMatch(character, "^[a-zA-Z0-9_]$")) {
            EmitText(character)
            AppendKey(character)
        } else if (character = "'" || character = Chr(34) || character = "``") {
            HandleQuotedDelimiter(character)
        } else if (character = "@" || character = "$") {
            HandleVariablePrefix(character)
        } else if (character = "-" || character = "/" || character = "*" || character = "#") {
            HandleCommentCharacter(character)
        } else {
            HandleDelimiter(character)
        }
    }
}

TypeTracked(text)
{
    Loop, Parse, text
    {
        character := A_LoopField
        EmitText(character)
        AppendKey(character)
    }
}

ResetTestState()
{
    global unsafeUntilNewline, inBlockComment, quoteDelimiter, quoteBackslashCount, variableName, beautifierEnabled
    ResetWord()
    unsafeUntilNewline := false
    inBlockComment := false
    quoteDelimiter := ""
    quoteBackslashCount := 0
    variableName := false
    beautifierEnabled := true
}

RecordResult(name, actual, expected)
{
    global failures, resultsFile
    if (actual = expected)
        FileAppend, % "PASS " . name . "`n", %resultsFile%
    else {
        failures += 1
        FileAppend, % "FAIL " . name . ": expected [" . expected . "], got [" . actual . "]`n", %resultsFile%
    }
}
