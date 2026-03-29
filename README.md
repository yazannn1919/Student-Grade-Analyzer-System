# 🎓 Student Grade Analyzer System (Assembly)

## 📌 Overview

This project is a console-based **Student Grade Analyzer System** written in **x86 Assembly (MASM)** using the Irvine32 library.

It allows users to input course data and generates a full academic report including:

* GPA calculation
* Grade statistics
* Letter grade conversion
* Histogram visualization
* Academic standing evaluation

---

## ⚙️ Features

### 🧾 Student Input

* Enter student name
* Enter number of courses (validated: 1–20)

### 📚 Course Data Entry

For each course:

* Course code (must be exactly 5 characters)
* Grade (0–100)
* Credit hours (1–4)

### 🔄 Processing

* Converts numeric grades to letter grades (A–F)
* Calculates:

  * Total credits
  * Average grade
  * Minimum & maximum grades
  * GPA (with 2 decimal precision)
* Computes grade points based on credit hours

### 📊 Output Reports

#### 1. Main Report

* Student info
* Course table:

  * Code, grade, credits, letter, points
* GPA

#### 2. Statistical Summary

* Highest grade (with letter)
* Lowest grade (with letter)
* Average grade (with letter)
* Number of failing courses

#### 3. Histogram

Visual grade distribution:

```
A: **** (4)
B: **   (2)
C: ***  (3)
D: *    (1)
F: *    (1)
```

#### 4. Academic Standing

* Excellent (≥ 3.5)
* Good Standing (≥ 2.0)
* Academic Warning (≥ 1.5)
* Academic Probation (< 1.5)

---

## 🧠 Program Structure

The program is modular and organized into procedures:

* `main` → controls program flow
* `getStudentInfo` → reads student name
* `validateCoursesNum` → validates course count
* `getCourseData` → handles course input + validation
* `ConvertToLetterGrade` → assigns letters + points
* `CalculateGPA` → computes GPA and academic standing
* `DisplayReport` → prints main report
* `DisplayStatistics` → prints summary stats
* `DisplayHistogram` → prints grade distribution

---

## ▶️ How to Run

1. Install MASM and Irvine32 library
2. Open project in Visual Studio (or MASM environment)
3. Assemble and run the `.asm` file

---

## ⚠️ Input Validation Rules

* Courses: 1–20 only
* Course code: exactly 5 characters
* Grade: 0–100
* Credit hours: 1–4

Invalid input forces re-entry.

---

## 🔥 What This Project Demonstrates

* Low-level data handling
* Manual arithmetic (including decimals)
* Control flow and loops
* Structured assembly programming
* Input validation at assembly level
