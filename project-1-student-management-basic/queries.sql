-- ============================================================
-- STUDENT MANAGEMENT SYSTEM — ANALYTICAL QUERIES
-- ============================================================
-- 10 analytical SQL queries for insights across the dataset.
-- Demonstrates JOINs, aggregation, filtering, and ranking.
-- ============================================================


-- ================================
-- Query 1: Most Popular Courses (by Enrollment)
-- ================================
-- Finds the top 10 courses with the highest total enrollment
-- by joining courses → offerings → sections → enrollments.

SELECT
    c.course_name,
    COUNT(e.enrollment_id) AS total_students
FROM courses c
JOIN course_offerings co
    ON c.course_id = co.course_id
JOIN sections s
    ON co.offering_id = s.offering_id
JOIN enrollments e
    ON s.section_id = e.section_id
GROUP BY c.course_name
ORDER BY total_students DESC
LIMIT 10;


-- ================================
-- Query 2: Faculty Teaching Most Students
-- ================================
-- Ranks professors by the number of students they teach
-- across all their course offerings and sections.

SELECT
    f.faculty_name,
    COUNT(e.enrollment_id) AS total_students
FROM faculties f
JOIN course_offerings co
    ON f.faculty_id = co.faculty_id
JOIN sections s
    ON co.offering_id = s.offering_id
JOIN enrollments e
    ON s.section_id = e.section_id
GROUP BY f.faculty_name
ORDER BY total_students DESC
LIMIT 10;


-- ================================
-- Query 3: Departments with Most Students
-- ================================
-- Shows student population distribution across all departments.

SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM departments d
JOIN students s
    ON d.department_id = s.department_id
GROUP BY d.department_name
ORDER BY student_count DESC;


-- ================================
-- Query 4: Students Taking the Most Courses
-- ================================
-- Identifies the top 10 most active students by enrollment count.

SELECT
    s.student_id,
    s.first_name,
    COUNT(e.enrollment_id) AS total_courses
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name
ORDER BY total_courses DESC
LIMIT 10;


-- ================================
-- Query 5: Hardest Courses (Lowest Average Grade)
-- ================================
-- Finds courses with the lowest average exam scores
-- by joining courses → offerings → sections → exams → grades.

SELECT
    c.course_name,
    AVG(g.score) AS avg_score
FROM courses c
JOIN course_offerings co
    ON c.course_id = co.course_id
JOIN sections s
    ON co.offering_id = s.offering_id
JOIN exams ex
    ON s.section_id = ex.section_id
JOIN grades g
    ON ex.exam_id = g.exam_id
GROUP BY c.course_name
ORDER BY avg_score ASC
LIMIT 10;


-- ================================
-- Query 6: Top 10 Students by Average Score
-- ================================
-- Ranks students by their average exam performance.

SELECT
    s.student_id,
    s.first_name,
    AVG(g.score) AS avg_score
FROM students s
JOIN grades g
    ON s.student_id = g.student_id
GROUP BY s.student_id, s.first_name
ORDER BY avg_score DESC
LIMIT 10;


-- ================================
-- Query 7: Enrollment Trends by Year
-- ================================
-- Shows how many students enrolled each year.

SELECT
    enrollment_year,
    COUNT(student_id) AS students_joined
FROM students
GROUP BY enrollment_year
ORDER BY enrollment_year;


-- ================================
-- Query 8: Average Grade per Department
-- ================================
-- Calculates the mean exam score for students in each department.

SELECT
    d.department_name,
    AVG(g.score) AS avg_score
FROM departments d
JOIN students s
    ON d.department_id = s.department_id
JOIN grades g
    ON s.student_id = g.student_id
GROUP BY d.department_name
ORDER BY avg_score DESC;


-- ================================
-- Query 9: Courses with Highest Failure Rate
-- ================================
-- Uses FILTER to count students scoring below 40 per course.

SELECT
    c.course_name,
    COUNT(*) FILTER (WHERE g.score < 40) AS failed_students,
    COUNT(*) AS total_students
FROM courses c
JOIN course_offerings co
    ON c.course_id = co.course_id
JOIN sections s
    ON co.offering_id = s.offering_id
JOIN exams ex
    ON s.section_id = ex.section_id
JOIN grades g
    ON ex.exam_id = g.exam_id
GROUP BY c.course_name
ORDER BY failed_students DESC
LIMIT 10;


-- ================================
-- Query 10: Faculty Workload Ranking
-- ================================
-- Counts the number of distinct courses each professor teaches.

SELECT
    f.faculty_name,
    COUNT(DISTINCT co.course_id) AS courses_taught
FROM faculties f
JOIN course_offerings co
    ON f.faculty_id = co.faculty_id
GROUP BY f.faculty_name
ORDER BY courses_taught DESC;
