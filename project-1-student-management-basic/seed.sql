-- ============================================================
-- STUDENT MANAGEMENT SYSTEM — DATA SEEDING
-- ============================================================
-- This file generates synthetic data for all 10 tables.
-- Uses generate_series() and random() for large-scale seeding.
-- Run this AFTER schema.sql and indexes.sql.
-- ============================================================


-- ================================
-- 1. DEPARTMENTS (8 records)
-- ================================

INSERT INTO departments (department_name)
VALUES
    ('Computer Science'),
    ('Mathematics'),
    ('Physics'),
    ('Economics'),
    ('Biology'),
    ('Chemistry'),
    ('Data Science'),
    ('Electrical Engineering');


-- ================================
-- 2. SEMESTERS (6 records)
-- ================================

INSERT INTO semesters (semester_name, year)
VALUES
    ('Spring', 2022),
    ('Fall',   2022),
    ('Spring', 2023),
    ('Fall',   2023),
    ('Spring', 2024),
    ('Fall',   2024);


-- ================================
-- 3. FACULTY (40 records)
-- ================================

INSERT INTO faculties (faculty_name, department_id, hire_year)
SELECT
    'Professor ' || gs,
    (RANDOM() * 7 + 1)::INT,
    1995 + (RANDOM() * 25)::INT
FROM generate_series(1, 40) AS gs;


-- ================================
-- 4. COURSES (100 records)
-- ================================

INSERT INTO courses (course_name, department_id, credits)
SELECT
    'Course ' || gs,
    (RANDOM() * 7 + 1)::INT,
    3 + (RANDOM() * 2)::INT
FROM generate_series(1, 100) AS gs;


-- ================================
-- 5. STUDENTS (100,000 records)
-- ================================

INSERT INTO students (
    student_number,
    first_name,
    last_name,
    email,
    age,
    department_id,
    enrollment_year
)
SELECT
    'UNI' || LPAD(gs::TEXT, 6, '0'),          -- UNI000001 ... UNI100000
    'FirstName' || gs,                         -- FirstName1 ... FirstName100000
    'LastName' || gs,                          -- LastName1 ... LastName100000
    'student' || gs || '@university.edu',      -- Unique email per student
    18 + (RANDOM() * 7)::INT,                 -- Age between 18–25
    (RANDOM() * 7 + 1)::INT,                  -- Random department (1–8)
    2020 + (gs % 5)                            -- Enrollment year 2020–2024
FROM generate_series(1, 100000) AS gs;


-- ================================
-- 6. COURSE OFFERINGS (500 records)
-- ================================

INSERT INTO course_offerings (course_id, semester_id, faculty_id)
SELECT
    (RANDOM() * 99 + 1)::INT,
    (RANDOM() * 5 + 1)::INT,
    (RANDOM() * 39 + 1)::INT
FROM generate_series(1, 500);


-- ================================
-- 7. SECTIONS (1,000 records)
-- ================================

INSERT INTO sections (offering_id, section_name, capacity)
SELECT
    (RANDOM() * 499 + 1)::INT,
    'Section ' || gs,
    30 + (RANDOM() * 40)::INT
FROM generate_series(1, 1000) AS gs;


-- ================================
-- 8. ENROLLMENTS (300,000 records)
-- ================================

INSERT INTO enrollments (student_id, section_id)
SELECT
    (RANDOM() * 99999 + 1)::INT,
    (RANDOM() * 999 + 1)::INT
FROM generate_series(1, 300000);


-- ================================
-- 9. EXAMS (2,000 records)
-- ================================

INSERT INTO exams (section_id, exam_type, exam_date)
SELECT
    (RANDOM() * 999 + 1)::INT,
    CASE
        WHEN RANDOM() < 0.5 THEN 'Midterm'
        ELSE 'Final'
    END,
    CURRENT_DATE - (RANDOM() * 365)::INT
FROM generate_series(1, 2000);


-- ================================
-- 10. GRADES (200,000 records)
-- ================================

INSERT INTO grades (exam_id, student_id, score)
SELECT
    (RANDOM() * 1999 + 1)::INT,
    (RANDOM() * 99999 + 1)::INT,
    (RANDOM() * 100)::INT
FROM generate_series(1, 200000);