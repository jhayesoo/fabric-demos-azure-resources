-- Step-by-step plan:
-- 1. Create a new table called [Calendar] with the specified columns and data types.
--    a. Use the DATE data type for the [Date] column.
--    b. Use the INT data type for the [Year], [Month], [Day], [Quarter], [WeekOfYear], and [DayOfWeek] columns.
-- 2. Use a WHILE loop to iterate through all the dates between 2013 and 2025.
-- 3. Insert each date into the [Calendar] table, along with the corresponding year, month, day, quarter, week of year, and day of week.
-- 4. Set the initial date to '2013-01-01' and increment it by one day in each iteration of the loop.
-- 5. After the loop finishes, the [Calendar] table will contain data for all days between 2013 and 2025.

-- Create the [Calendar] table
CREATE TABLE starschema.[Calendar] (
    [Date] DATE,
    [Year] INT,
    [Month] INT,
    [Day] INT,
    [Quarter] INT,
    [WeekOfYear] INT,
    [DayOfWeek] INT
);

-- Set the initial date to '2013-01-01'
DECLARE @Date DATE = '2013-01-01';

-- Use a WHILE loop to iterate through all the dates between 2013 and 2025
WHILE @Date <= '2025-12-31'
BEGIN
    -- Insert each date into the [Calendar] table, along with the corresponding year, month, day, quarter, week of year, and day of week
    INSERT INTO starschema.[Calendar] ([Date], [Year], [Month], [Day], [Quarter], [WeekOfYear], [DayOfWeek])
    VALUES (
        @Date,
        YEAR(@Date),
        MONTH(@Date),
        DAY(@Date),
        DATEPART(QUARTER, @Date),
        DATEPART(WEEK, @Date),
        DATEPART(WEEKDAY, @Date)
    );

    -- Increment the date by one day
    SET @Date = DATEADD(DAY, 1, @Date);
END;
