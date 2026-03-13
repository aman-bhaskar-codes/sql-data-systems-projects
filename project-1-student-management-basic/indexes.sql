-- ============================================================
-- STUDENT MANAGEMENT SYSTEM — PERFORMANCE INDEXES
-- ============================================================
-- Strategic indexes on frequently joined columns to optimize
-- query performance on large tables (300K+ enrollments, 200K+ grades).
-- Run this AFTER schema.sql, BEFORE seed.sql.
-- ============================================================


-- Index on students.department_id
-- Speeds up department-level student aggregations
CREATE INDEX idx_students_department
    ON students(department_id);

-- Index on enrollments.student_id
-- Speeds up student enrollment lookups
CREATE INDEX idx_enrollments_student
    ON enrollments(student_id);

-- Index on enrollments.section_id
-- Speeds up section-level enrollment joins
CREATE INDEX idx_enrollments_section
    ON enrollments(section_id);

-- Index on sections.offering_id
-- Speeds up offering → section joins
CREATE INDEX idx_sections_offering
    ON sections(offering_id);

-- Index on grades.exam_id
-- Speeds up exam → grade joins
CREATE INDEX idx_grades_exam
    ON grades(exam_id);

-- Index on grades.student_id
-- Speeds up student performance queries
CREATE INDEX idx_grades_student
    ON grades(student_id);