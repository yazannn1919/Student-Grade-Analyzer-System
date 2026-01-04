INCLUDE Irvine32.inc
.data

	; =================================== student name ===================================
	studentMsg BYTE "Enter student name: ", 0
	studentName BYTE 21 DUP(0) ; +1 for null terminator

	; =================================== number of courses ===================================
	numberOfCoursesMsg BYTE "Enter number of courses (1-20): ", 0
	numberOfCoursesErr BYTE "The number of courses should be between 1 and 20", 0
	numberOfCourses DWORD ?
	valid BYTE ?

	; =================================== course data ===================================
	currentTitle1 BYTE "Course ", 0
	currentTitle2 BYTE ": ", 0

	idx DWORD ?
	tempECX DWORD ?

	courseCodeMsg BYTE "  Enter course code: ", 0
	courseCodeErr BYTE "  Course code must be 5 characters", 0
	courseCodeBuffer BYTE 21 DUP(0) ; +1 for null terminator, extra size to avoid overflow
	courseCodeLen DWORD ?
	courseCodeArr BYTE 20 DUP(6 DUP(0)) ; array for max 20 course codes including null terminators

	courseGradeMsg BYTE "  Enter course grade (0-100): ", 0
	courseGrade DWORD ?
	courseGradeErr BYTE "  Grade must be between 0 and 100", 0
	courseGradeArr DWORD 20 DUP(?) 

	courseHrsMsg BYTE "  Enter course hours (1-4): ", 0
	courseHrs DWORD ?
	courseHrsErr BYTE "  Course hours must be between 1 and 4", 0
	courseHrsArr DWORD 20 DUP(?)

	;=================================== grades and letters and points ===================================
	letteredGrades BYTE 20 DUP(0)
	countA DWORD 0
	countB DWORD 0
	countC DWORD 0
	countD DWORD 0
	countF DWORD 0
	coursePoints DWORD 20 DUP(?)

	; =================================== calc min, max, sum, avg ===================================
	minGrade DWORD 100
	maxGrade DWORD 0
	gradesSum DWORD 0
	gradeAvg DWORD ?

	; =================================== calc GPA ===================================
	gpa DWORD ?
	pointsSum DWORD 0
	gpaResult BYTE 20 DUP(0)
	excellentMsg BYTE "Excellent", 0
	goodMsg BYTE "Good Standing", 0
	warningMsg BYTE "Academic Warning", 0
	probationMsg BYTE "Academic Probation", 0	

	; =================================== display report ===================================
	reportTitle1 BYTE "===========================================", 0
	reportTitle2 BYTE "       STUDENT GRADE ANALYZER SYSTEM        ", 0
	reportTitle3 BYTE "===========================================", 0
	giveName BYTE "Student: ", 0
	giveCoursesNum BYTE "Courses: ", 0
	giveTCredits BYTE "Total Credits: ", 0
	giveGPA BYTE "GPA: ", 0
	courseTitle BYTE "Course   ", 0
	gradeTitle BYTE "Grade   ", 0
	creditsTitle BYTE "Credits  ", 0
	lettersTitle BYTE "Letter   ", 0
	pointsTitle BYTE "Points", 0
	titlesSeperator BTYE "==========================================", 0
	

.code
; MAIN
	main PROC
		; =================================== student name ===================================
			call getStudentInfo

		; =================================== number of courses ===================================
			reEnterNumCourses:

			; prompt for number of courses
				MOV EDX, OFFSET numberOfCoursesMsg
				call writeString

			; read number of courses
				call readInt

			; validation:
				call validateCoursesNum

				; unvalid:
				CMP valid, 0
				JE reEnterNumCourses

		; =================================== course data ===================================

			MOV ECX, numberOfCourses
			MOV idx, 0

			courseLoop:
			
				; write "Course X: "
					MOV EDX, OFFSET currentTitle1
					call writeString

					inc idx ; to make it one based
					MOV EAX, idx
					call writeDec
					dec idx ; to return to original

					MOV EDX, OFFSET currentTitle2
					call writeString
					call crlf

				; read input + validation
					MOV tempECX, ECX ; save loop counter
					call getCourseData
					call ConvertToLetterGrade
					MOV ECX, tempECX ; restore loop counter

				inc idx

			LOOP courseLoop

		; =================================== calc min, max, sum, avg ===================================
			
			MOV ECX, numberOfCourses
			MOV idx, 0
			calcLoop:
				; get current grade
					MOV EAX, [courseGradeArr + idx * 4]

				; calc min
					; if(curr < min) min = curr
						CMP EAX, minGrade
						JAE skipMin
						MOV minGrade, EAX
				skipMin:

				; calc max
					; if(curr > max) max = curr
						CMP EAX, maxGrade
						JBE skipMax
						MOV maxGrade, EAX
				skipMax:

				; calc sum
					ADD gradesSum, EAX

				inc idx
			LOOP calcLoop

			; calc avg
				MOV EAX, gradesSum
				MOV EBX, numberOfCourses
				XOR EDX, EDX ; clear edx before
				DIV EBX ; eax = eax / ebx
				MOV gradeAvg, EAX


		; =================================== calc GPA ===================================
			call CalculateGPA

		; =================================== report printing ===================================
			call DisplayReport
			call DisplayStatistics
			call DisplayHistogram

		exit
	main ENDP

; PROCEDURES

; =================================== display report ===================================
	DisplayReport PROC
		; displaying header
			MOV EDX, OFFSET reportTitle1
			call writeString
			call crlf
			MOV EDX, OFFSET reportTitle2
			call writeString
			call crlf
			MOV EDX, OFFSET reportTitle2
			call writeString
			call crlf
			call crlf

		; basic student info
		
		
		ret
	ENDP DisplayReport

; =================================== get student info ===================================
	getStudentInfo PROC
		; prompt for name
		MOV EDX, OFFSET studentMsg
		call writeString

		; read name
		MOV EDX, OFFSET studentName
		MOV ECX, SIZEOF studentName - 1
		call readString

		ret
	getStudentInfo ENDP

; =================================== course number validation ===================================
	validateCoursesNum PROC
		; if(num >= 1 && num <= 20) -> valid
			CMP EAX, 1
			JB invalidNumCourses
			CMP EAX, 20
			JA invalidNumCourses

		JMP validNumCourses

		invalidNumCourses:
			MOV EDX, OFFSET numberOfCoursesErr
			call writeString
			call crlf

			; set valid = 0 to re enter in main
			MOV AL, 0
			MOV valid, AL

			ret

		validNumCourses:
			; set valid = 1 to continue in main
			MOV numberOfCourses, EAX 
			MOV AL, 1
			MOV valid, AL

			ret
	validateCoursesNum ENDP

; =================================== get course data ===================================
	getCourseData PROC
		
		; course code
			reEnterCourseCode:

			; prompt for course code
				MOV EDX, OFFSET courseCodeMsg
				call writeString

			; read course code
				MOV EDX, OFFSET courseCodeArr
				MOV ECX, 6
				call readString

			; validation:
				; if(length == 5) -> valid
				CMP EAX, 5 ; eax has length from readString
				JE validCourseCode

				; invalid:
				MOV EDX, OFFSET courseCodeErr
				call writeString
				call crlf
				JMP reEnterCourseCode ; re enter

				; valid + storing
				validCourseCode: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; course grade
			reEnterCourseGrade:

			; prompt for course grade
				MOV EDX, OFFSET courseGradeMsg
				call writeString

			; read course grade
				call readInt
				MOV courseGrade, EAX

			; validation:
				; if(grade >= 0 && grade <= 100) -> valid
				CMP courseGrade, 0
				JB invalidCourseGrade
				CMP courseGrade, 100
				JA invalidCourseGrade

				; valid
				JMP validCourseGrade

				invalidCourseGrade:
					MOV EDX, OFFSET courseGradeErr
					call writeString
					call crlf
					JMP reEnterCourseGrade ; re enter

				; valid + storing
				validCourseGrade:
				MOV EDX, courseGrade
				MOV [courseGradeArr + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; course hours
			reEnterCourseHrs:

			; prompt for course hours
				MOV EDX, OFFSET courseHrsMsg
				call writeString

			; read course hours
				call readInt
				MOV courseHrs, EAX

			; validation:
				; if(hours >= 1 && hours <= 4) -> valid
				CMP courseHrs, 1
				JB invalidCourseHrs
				CMP courseHrs, 4
				JA invalidCourseHrs

				; valid
				JMP validCourseHrs

				invalidCourseHrs:
					MOV EDX, OFFSET courseHrsErr
					call writeString
					call crlf
					JMP reEnterCourseHrs ; re enter

				; valid + storing
				validCourseHrs:
				MOV EDX, courseHrs
				MOV [courseHrsArr + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ret
	getCourseData ENDP

	ConvertToLetterGrade PROC
		; eax = current grade
		; if(grade >= 90) -> A
			CMP EAX, 90
			JB checkB

			; store letter A
				MOV BL, 'A' 
			; calculate points for A
				MOV EDX, 4 * courseHrs  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV [coursePoints + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; increment A count
				inc countA 

			JMP storeLetter

		checkB:
		; else if(grade >= 80) -> B
			CMP EAX, 80
			JB checkC
			; store letter B
				MOV BL, 'B' 
			; calculate points for B
				MOV EDX, 3 * courseHrs  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV [coursePoints + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; increment B count
				inc countB 
			JMP storeLetter

		checkC:
		; else if(grade >= 70) -> C
			CMP EAX, 70
			JB checkD
			; store letter C
				MOV BL, 'C'
			; calculate points for C
				MOV EDX, 2 * courseHrs  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV [coursePoints + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; increment C count
				inc countC
			JMP storeLetter

		checkD:
		; else if(grade >= 60) -> D
			CMP EAX, 60
			JB storeF
			; store letter D
				MOV BL, 'D'
			; calculate points for D
				MOV EDX, 1 * courseHrs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV [coursePoints + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; increment D count
				inc countD
			JMP storeLetter

		storeF:
		; else -> F
			; store letter F
				MOV BL, 'F'
			; calculate points for F
				MOV EDX, 0
				MOV [coursePoints + idx * 4], EDX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; increment F count
				inc countF

		storeLetter:
		MOV [letteredGrades + idx], BL

		ret
	ConvertToLetterGrade ENDP

	; =================================== calc GPA ===================================
	CalculateGPA PROC
		MOV ECX, numberOfCourses
		MOV idx, 0

		calcPointsSumLoop:
			; get current points
				MOV EAX, [coursePoints + idx * 4]
			; calc sum
				ADD pointsSum, EAX
			inc idx
		LOOP calcPointsSumLoop

		; calc GPA
			MOV EAX, pointsSum
			MOV EBX, numberOfCourses
			XOR EDX, EDX ; clear edx before
			DIV EBX ; eax = eax / ebx
			MOV gpa, EAX

		; decide gpa result
			; if(gpa >= 3.5) -> Excellent
				CMP gpa, 3.5
				JB checkGood
				MOV EAX, OFFSET excellentMsg ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV gpaResult, EAX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				JMP endGPA

			checkGood:
			; else if(gpa >= 2) -> Good Standing
				CMP gpa, 2
				JB warning
				MOV EAX, OFFSET goodMsg ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV gpaResult, EAX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				JMP endGPA

			warning:
			; else if(gpa >= 1.5) -> Academic Warning
				CMP gpa, 1.5
				JB probation
				MOV EAX, OFFSET warningMsg ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV gpaResult, EAX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				JMP endGPA

			probation:
			; else -> Academic Probation
				MOV EAX, OFFSET probationMsg ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				MOV gpaResult, EAX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			endGPA:
				
		ret
	CalculateGPA ENDP

END main
