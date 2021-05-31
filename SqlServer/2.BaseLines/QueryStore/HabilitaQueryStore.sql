DECLARE @Database VARCHAR(200) = DB_NAME();

DECLARE @query VARCHAR(MAX) = CONCAT('ALTER DATABASE ',QUOTENAME(@Database), ' SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 2048,
      INTERVAL_LENGTH_MINUTES = 15,
      SIZE_BASED_CLEANUP_MODE = AUTO,
      MAX_PLANS_PER_QUERY = 5,
      WAIT_STATS_CAPTURE_MODE = ON,
      QUERY_CAPTURE_MODE = ALL,
      QUERY_CAPTURE_POLICY = (
        STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
        EXECUTION_COUNT = 50,
        TOTAL_COMPILE_CPU_TIME_MS = 60000,
        TOTAL_EXECUTION_CPU_TIME_MS = 60000
      )
    );');

	EXEC(@query)