

-- Generate SQL to create foreign key constraints if both tables exist and the constraint does not already exist
SELECT CONCAT('
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = ''dbo''
      AND TABLE_NAME = ''', FK.TABLE_NAME, '''
)
AND EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = ''dbo''
      AND TABLE_NAME = ''', PK.TABLE_NAME, '''
)
AND NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_TYPE = ''FOREIGN KEY''
      AND TABLE_SCHEMA = ''dbo''
      AND TABLE_NAME = ''', FK.TABLE_NAME, '''
      AND CONSTRAINT_NAME = ''', FK.CONSTRAINT_NAME, '''
)
BEGIN
    ALTER TABLE ', FK.TABLE_NAME, '
    ADD CONSTRAINT ', FK.CONSTRAINT_NAME, '
    FOREIGN KEY (', FK.COLUMN_NAME, ')
    REFERENCES ', PK.TABLE_NAME, '(', PK.COLUMN_NAME, ');
END;'
)
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE FK
    ON RC.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE PK
    ON RC.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
WHERE RC.CONSTRAINT_SCHEMA = 'dbo';