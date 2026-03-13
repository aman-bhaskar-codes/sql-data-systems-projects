-- ============================================================
-- STUDENT MANAGEMENT SYSTEM — SCHEMA DEFINITION
-- ============================================================
-- This file creates all 10 tables in dependency order.
-- Run this FIRST before seeding data.
-- ============================================================


-- ================================
-- 1. DEPARTMENTS
-- ================================

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL
);


-- ================================
-- 2. SEMESTERS
-- ================================

CREATE TABLE semesters (
    semester_id   SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    year          INT
);


-- ================================
-- 3. STUDENTS
-- ================================

CREATE TABLE students (
    student_id     SERIAL PRIMARY KEY,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    first_name     VARCHAR(50),
    last_name      VARCHAR(50),
    email          VARCHAR(120) UNIQUE,
    age            INT CHECK (age BETWEEN 17 AND 35),
    department_id  INT REFERENCES departments(department_id),
    enrollment_year INT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ================================
-- 4. FACULTY
-- ================================

CREATE TABLE faculties (
    faculty_id    SERIAL PRIMARY KEY,
    faculty_name  VARCHAR(100),
    department_id INT REFERENCES departments(department_id),
    hire_year     INT
);


-- ================================
-- 5. COURSES
-- ================================

CREATE TABLE courses (
    course_id     SERIAL PRIMARY KEY,
    course_name   VARCHAR(120),
    department_id INT REFERENCES departments(department_id),
    credits       INT
);


-- ================================
-- 6. COURSE OFFERINGS
-- ================================

CREATE TABLE course_offerings (
    offering_id SERIAL PRIMARY KEY,
    course_id   INT REFERENCES courses(course_id),
    semester_id INT REFERENCES semesters(semester_id),
    faculty_id  INT REFERENCES faculties(faculty_id)
);


-- ================================
-- 7. SECTIONS
-- ================================

CREATE TABLE sections (
    section_id   SERIAL PRIMARY KEY,
    offering_id  INT REFERENCES course_offerings(offering_id),
    section_name VARCHAR(20),
    capacity     INT
);


-- ================================
-- 8. ENROLLMENTS
-- ================================

CREATE TABLE enrollments (
    enrollment_id   SERIAL PRIMARY KEY,
    student_id      INT REFERENCES students(student_id),
    section_id      INT REFERENCES sections(section_id),
    enrollment_date DATE DEFAULT CURRENT_DATE
);


-- ================================
-- 9. EXAMS
-- ================================

CREATE TABLE exams (
    exam_id    SERIAL PRIMARY KEY,
    section_id INT REFERENCES sections(section_id),
    exam_type  VARCHAR(20),
    exam_date  DATE
);


-- ================================
-- 10. GRADES
-- ================================

CREATE TABLE grades (
    grade_id   SERIAL PRIMARY KEY,
    exam_id    INT REFERENCES exams(exam_id),
    student_id INT REFERENCES students(student_id),
    score      INT CHECK (score BETWEEN 0 AND 100)
);
