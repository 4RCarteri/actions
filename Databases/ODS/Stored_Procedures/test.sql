SELECT a.name
FROM sys.procedures AS a INNER JOIN sys.sql_modules AS b ON a.object_id = b.object_id AND a.name = 'ODSCleanup'
