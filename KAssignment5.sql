-- Assignment 5 – SQL Queries
-- United Helpers Database

-- Q1: How many containers of antibiotics are currently available?
SELECT quantityOnHand
FROM item
WHERE itemDescription LIKE '%antibiotics%';

-- Q2: Which volunteer(s), if any, have phone numbers that do not start with the
--     number 2 and whose last name is not Jones?
SELECT volunteerName
FROM volunteer
WHERE volunteerTelephone IS NOT NULL
  AND volunteerTelephone NOT LIKE '2%'
  AND volunteerName NOT LIKE '%Jones';

-- Q3: Which volunteer(s) are working on transporting tasks?
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId = assignment.volunteerId
JOIN task       ON assignment.taskCode   = task.taskCode
JOIN task_type  ON task.taskTypeId       = task_type.taskTypeId
WHERE task_type.taskTypeName = 'transporting';

-- Q4: Which task(s) have yet to be assigned to any volunteers?
SELECT task.taskDescription
FROM task
LEFT JOIN assignment ON task.taskCode = assignment.taskCode
WHERE assignment.taskCode IS NULL;

-- Q5: Which type(s) of package contain some kind of bottle?
SELECT DISTINCT package_type.packageTypeName
FROM item
JOIN package_contents ON item.itemId            = package_contents.itemId
JOIN package          ON package_contents.packageId = package.packageId
JOIN package_type     ON package.packageTypeId  = package_type.packageTypeId
WHERE item.itemDescription LIKE '%bottle%';

-- Q6: Which items, if any, are not in any packages?
SELECT item.itemDescription
FROM item
LEFT JOIN package_contents ON item.itemId = package_contents.itemId
WHERE package_contents.itemId IS NULL;

-- Q7: Which task(s) are assigned to volunteer(s) that live in New Jersey (NJ)?
SELECT DISTINCT task.taskDescription
FROM task
JOIN assignment ON task.taskCode          = assignment.taskCode
JOIN volunteer  ON assignment.volunteerId = volunteer.volunteerId
WHERE volunteer.volunteerAddress LIKE '%NJ%';

-- Q8: Which volunteers began their assignments in the first half of 2021?
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId = assignment.volunteerId
WHERE assignment.startDateTime >= '2021-01-01'
  AND assignment.startDateTime <  '2021-07-01';

-- Q9: Which volunteers have been assigned to tasks that include packing spam?
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment       ON volunteer.volunteerId      = assignment.volunteerId
JOIN task             ON assignment.taskCode        = task.taskCode
JOIN package          ON task.taskCode              = package.taskCode
JOIN package_contents ON package.packageId         = package_contents.packageId
JOIN item             ON package_contents.itemId   = item.itemId
WHERE item.itemDescription = 'can of spam';

-- Q10: Which item(s) have a total value of exactly $100 in one package?
SELECT item.itemDescription
FROM package_contents
JOIN item ON package_contents.itemId = item.itemId
GROUP BY package_contents.packageId, package_contents.itemId
HAVING item.itemValue * package_contents.itemQuantity = 100;

-- Q11: How many volunteers are assigned to tasks with each different status?
--      (sorted from highest to lowest)
SELECT task_status.taskStatusName,
       COUNT(assignment.volunteerId) AS volunteerCount
FROM task_status
JOIN task       ON task_status.taskStatusId = task.taskStatusId
JOIN assignment ON task.taskCode            = assignment.taskCode
GROUP BY task_status.taskStatusName
ORDER BY volunteerCount DESC;

-- Q12: Which task creates the heaviest set of packages and what is the weight?
SELECT taskCode, SUM(packageWeight) AS totalWeight
FROM package
GROUP BY taskCode
ORDER BY totalWeight DESC
LIMIT 1;

-- Q13: How many tasks are there that do not have a type of "packing"?
SELECT COUNT(*) AS nonPackingTasks
FROM task
JOIN task_type ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName != 'packing';

-- Q14: Of those items that have been packed, which item(s) were touched by
--      fewer than 3 volunteers?
SELECT item.itemDescription
FROM package_contents
JOIN package    ON package_contents.packageId  = package.packageId
JOIN task       ON package.taskCode            = task.taskCode
JOIN assignment ON task.taskCode               = assignment.taskCode
JOIN item       ON package_contents.itemId     = item.itemId
GROUP BY package_contents.itemId
HAVING COUNT(DISTINCT assignment.volunteerId) < 3;

-- Q15: Which packages have a total value of more than 100?
--      (sorted from lowest to highest)
SELECT package_contents.packageId,
       SUM(item.itemValue * package_contents.itemQuantity) AS totalValue
FROM package_contents
JOIN item ON package_contents.itemId = item.itemId
GROUP BY package_contents.packageId
HAVING totalValue > 100
ORDER BY totalValue ASC;
