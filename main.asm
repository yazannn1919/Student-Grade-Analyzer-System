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

	courseCodeBuffer BYTE 32 DUP(0)
	courseCodeMsg BYTE "  Enter course code: ", 0
	courseCodeErr BYTE "  Course code must be 5 characters", 0
	courseCodeArr BYTE 120 DUP(0) ; array for max 20 course codes including null terminators

	courseGradeMsg BYTE "  Enter course grade (0-100): ", 0
	courseGradeErr BYTE "  Grade must be between 0 and 100", 0
	courseGradeArr DWORD 20 DUP(?) 

	courseHrsMsg BYTE "  Enter course hours (1-4): ", 0
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
	minLetter BYTE ?
	maxLetter BYTE ?
	gradesSum DWORD 0
	hrsSum DWORD 0
	gradeAvg DWORD 0

	; =================================== calc GPA ===================================
	gpaInt DWORD ?
	gpaDec DWORD ?
	gpaResult DWORD ?
	pointsSum DWORD 0
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
	courseTitle BYTE "Course Grade Credits Letter Points", 0
	titlesSeperator BYTE "------ ----- ------- ------ ------",0
	printSpace BYTE "   ", 0

	; =================================== statistics report ===================================
	statisticsTitle1 BYTE "STATISTICAL SUMMARY", 0
	highestGradeMsg BYTE "Highest Grade: ", 0
	lowestGradeMsg BYTE "Lowest Grade: ", 0
	avgGradeMsg BYTE "Average Grade: ", 0
	failingMsg BYTE "Failing Courses: ", 0

	; =================================== histogram report ===================================
	histogramTitle BYTE "GRADE DISTRIBUTION:", 0
	gradeAMsg BYTE "A: ", 0
	gradeBMsg BYTE "B: ", 0
	gradeCMsg BYTE "C: ", 0
	gradeDMsg BYTE "D: ", 0
	gradeFMsg BYTE "F: ", 0
	star BYTE '*',0
	lParen BYTE '(',0
	rParen BYTE ')',0
	standingMsg BYTE "ACADEMIC STANDING: ", 0
	endingLine BYTE "-------------------------------------------",0
	

.code
; MAIN
	main PROC
		; =================================== student name ===================================
			call getStudentInfo

		; =================================== number of courses ===================================
			reEnterNumCourses: MOV valid, 0 ; reset valid flag

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
				; "course " 
					MOV EDX, OFFSET currentTitle1
					call writeString

				; idx + 1
					MOV EAX, idx
					inc EAX ; to make it 1 based
					call writeDec

				; ": "
					MOV EDX, OFFSET currentTitle2
					call writeString
					call crlf

				; read input + validation
					push ECX ; save loop counter
					call getCourseData
					call ConvertToLetterGrade
					pop ECX ; restore loop counter

				inc idx

			LOOP courseLoop
			call crlf
			call crlf

		; =================================== calc min, max, sum, avg ===================================
			
			MOV ECX, numberOfCourses
			MOV idx, 0

			calcLoop:
				MOV ESI, idx
				; get current grade	
					MOV EAX, [courseGradeArr + ESI * 4]

				; get curr letter
					MOV DL,  [letteredGrades + ESI]

				; calc min
					; if(curr < min) min = curr
						CMP EAX, minGrade
						JAE skipMin
						MOV minGrade, EAX
						MOV minLetter, DL
				skipMin:

				; calc max
					; if(curr > max) max = curr
						CMP EAX, maxGrade
						JBE skipMax
						MOV maxGrade, EAX
						MOV maxLetter, DL
				skipMax:

				; calc sum
					ADD gradesSum, EAX
					MOV ESI, idx
					MOV EAX, [courseHrsArr + ESI * 4]
					ADD hrsSum, EAX

				inc idx
			LOOP calcLoop

			; calc avg
				MOV EAX, gradesSum
				MOV EBX, numberOfCourses
				XOR EDX, EDX ; clear EDX before
				DIV EBX ; EAX = EAX / EBX
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
		push EBX

		; displaying header
			MOV EDX, OFFSET reportTitle1
			call writeString
			call crlf
			MOV EDX, OFFSET reportTitle2
			call writeString
			call crlf
			MOV EDX, OFFSET reportTitle3
			call writeString
			call crlf
			call crlf

		; basic student info
			; student name:
			MOV EDX, OFFSET giveName
			call writeString
			MOV EDX, OFFSET studentName
			call writeString
			call crlf

			; number of courses:
			MOV EDX, OFFSET giveCoursesNum
			call writeString
			MOV EAX, numberOfCourses
			call writeDec
			call crlf

			; total credits:
			MOV EDX, OFFSET giveTCredits
			call writeString
			MOV EAX, hrsSum
			call writeDec
			call crlf

			; GPA with 2 decimal places (manual)
			MOV EDX, OFFSET giveGPA
			call writeString

			; integer part
			MOV EAX, gpaInt
			call writeDec

			; print '.'
			MOV AL, '.'
			call writeChar

			; print decimals (ensure leading zero)
			MOV EAX, gpaDec
			CMP EAX, 10
			JAE printDec
				MOV AL, '0'
				call writeChar
			printDec:
			call writeDec

			call crlf
			call crlf

		; table:
			; courses titles
				MOV EDX, OFFSET courseTitle
				call writeString
				call crlf
				MOV EDX, OFFSET titlesSeperator
				call writeString
				call crlf

			; courses info (name, grade, credits, letters, points) 
				MOV ECX, numberOfCourses
				MOV idx, 0
				courseReportLoop:
					MOV ESI, idx

					; course code
						MOV EDX, OFFSET courseCodeArr
						MOV EAX, idx
						IMUL EAX, EAX, 6
						ADD EDX, EAX
						call writeString

					; course grade
						MOV EDX, OFFSET printSpace
						call writeString
						MOV EAX, [courseGradeArr + ESI * 4]
						call writeDec

					; course hours
						MOV EDX, OFFSET printSpace
						call writeString
						MOV EAX, [courseHrsArr + ESI * 4]
						call writeDec

					; lettered grade
						MOV EDX, OFFSET printSpace
						call writeString
						MOV AL, [letteredGrades + ESI]
						call writeChar

					; course points
						MOV EDX, OFFSET printSpace
						call writeString
						MOV EAX, [coursePoints + ESI * 4]
						call writeDec

					call crlf
					inc idx
					dec ECX
				JNZ courseReportLoop ;;;;;;;;;;;;;;

				call crlf
				; ending line
					MOV EDX, OFFSET endingLine
					call writeString
					call crlf
					call crlf
		
		pop EBX
		ret
	DisplayReport ENDP 

; =================================== display statistics ===================================
	DisplayStatistics PROC 
		; SUMMARY
			; statistics title
				MOV EDX, OFFSET statisticsTitle1
				call writeString
				call crlf

			; highest grade
				MOV EDX, OFFSET highestGradeMsg
				call writeString
				MOV EAX, maxGrade
				call writeDec
				MOV AL, ' '
				call writeChar
				MOV AL, '('
				call writeChar
				MOV AL, maxLetter
				call writeChar
				MOV AL, ')'
				call writeChar
				call crlf

			; lowest grade
				MOV EDX, OFFSET lowestGradeMsg
				call writeString
				MOV EAX, minGrade
				call writeDec
				MOV AL, ' '
				call writeChar
				MOV AL, '('
				call writeChar
				MOV AL, minLetter
				call writeChar
				MOV AL, ')'
				call writeChar
				call crlf

			; average grade
				MOV EDX, OFFSET avgGradeMsg
				call writeString
				MOV EAX, gradeAvg
				call writeDec

			; print avg letter grade
			; print space + '('
				MOV AL, ' '
				call WriteChar
				MOV AL, '('
				call WriteChar

				; determine avg letter from EAX (gradeAvg)
				MOV EAX, gradeAvg

				CMP EAX, 90
				JB  avgCheckB
				MOV AL, 'A'
				JMP avgPrint

			avgCheckB:
				CMP EAX, 80
				JB  avgCheckC
				MOV AL, 'B'
				JMP avgPrint

			avgCheckC:
				CMP EAX, 70
				JB  avgCheckD
				MOV AL, 'C'
				JMP avgPrint

			avgCheckD:
				CMP EAX, 60
				JB  avgIsF
				MOV AL, 'D'
				JMP avgPrint

			avgIsF:
				MOV AL, 'F'

			avgPrint:
				call WriteChar
				MOV AL, ')'
				call WriteChar
				call Crlf

			; failing courses
				MOV EDX, OFFSET failingMsg
				call writeString
				MOV EAX, countF
				call writeDec
				call crlf
				call crlf

	ret
	DisplayStatistics ENDP 


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
		MOV valid, 0

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
				; prompt
				MOV EDX, OFFSET courseCodeMsg
				call WriteString

				; read into temp buffer 
				MOV EDX, OFFSET courseCodeBuffer
				MOV ECX, SIZEOF courseCodeBuffer
				call ReadString ; EAX = length

				; validation
				; if(length == 5) -> valid
				CMP EAX, 5
				JE  validCourseCode

				; invalid
				MOV EDX, OFFSET courseCodeErr
				call WriteString
				call crlf
				JMP reEnterCourseCode

			validCourseCode:
				; storing in array
				MOV ESI, OFFSET courseCodeBuffer

				MOV EDI, OFFSET courseCodeArr
				MOV EAX, idx
				IMUL EAX, EAX, 6
				ADD EDI, EAX ; EDI -> destination slot

				; copying 5 bytes manually
				MOV AL, [ESI]
				MOV [EDI], AL
				MOV AL, [ESI+1]
				MOV [EDI+1], AL
				MOV AL, [ESI+2]
				MOV [EDI+2], AL
				MOV AL, [ESI+3]
				MOV [EDI+3], AL
				MOV AL, [ESI+4]
				MOV [EDI+4], AL

				MOV BYTE PTR [EDI+5], 0 ; null terminator

		; course grade
			MOV ESI, idx ; bc esi was changed in copying
			reEnterCourseGrade:

			; prompt for course grade
				MOV EDX, OFFSET courseGradeMsg
				call writeString

			; read course grade
				call readInt

			; validation:
				; if(grade >= 0 && grade <= 100) -> valid
				CMP EAX, 0
				JB invalidCourseGrade
				CMP EAX, 100
				JA invalidCourseGrade

				; valid
				MOV [courseGradeArr + ESI * 4], EAX 
				JMP validCourseGrade

				invalidCourseGrade:
					MOV EDX, OFFSET courseGradeErr
					call writeString
					call crlf
					JMP reEnterCourseGrade ; re enter

				; valid + storing
				validCourseGrade:
				

		; course hours
			reEnterCourseHrs:

			; prompt for course hours
				MOV EDX, OFFSET courseHrsMsg
				call writeString

			; read course hours
				call readInt

			; validation:
				; if(hours >= 1 && hours <= 4) -> valid
				CMP EAX, 1
				JB invalidCourseHrs
				CMP EAX, 4
				JA invalidCourseHrs

				; valid
				MOV [courseHrsArr + ESI * 4], EAX 
				JMP validCourseHrs

				invalidCourseHrs:
					MOV EDX, OFFSET courseHrsErr
					call writeString
					call crlf
					JMP reEnterCourseHrs ; re enter

				; valid + storing
				validCourseHrs:
				

		ret
	getCourseData ENDP

	ConvertToLetterGrade PROC
		push EBX ; to preserve EBX used for points calculation
		push EDX

		; get current grade and course hours
			MOV ESI, idx
			MOV EAX, [courseGradeArr + ESI * 4] ; grade
			MOV ECX, [courseHrsArr + ESI * 4] ; hours		
		
		; if(grade >= 90) -> A
			CMP EAX, 90
			JB checkB

			; store letter A
				MOV DL, 'A' 
			; calculate points for A
				MOV EBX, 4
			; increment A count
				inc countA 

			JMP storeLetter

		checkB:
		; else if(grade >= 80) -> B
			CMP EAX, 80
			JB checkC

			; store letter B
				MOV DL, 'B' 
			; calculate points for B
				MOV EBX, 3 
			; increment B count
				inc countB 

			JMP storeLetter

		checkC:
		; else if(grade >= 70) -> C
			CMP EAX, 70
			JB checkD

			; store letter C
				MOV DL, 'C'
			; calculate points for C
				MOV EBX, 2
			; increment C count
				inc countC

			JMP storeLetter

		checkD:
		; else if(grade >= 60) -> D
			CMP EAX, 60
			JB storeF

			; store letter D
				MOV DL, 'D'
			; calculate points for D
				MOV EBX, 1
			; increment D count
				inc countD

			JMP storeLetter

		storeF:
		; else -> F

			; store letter F
				MOV DL, 'F'
			; calculate points for F
				MOV EBX, 0
			; increment F count
				inc countF

		storeLetter:
			; store letter into array
			MOV [letteredGrades + ESI], DL

			; calc points = points * hrs
			MOV EAX, EBX
			XOR EDX, EDX ; clear EDX before	
			MUL ECX
			MOV ESI, idx
			MOV [coursePoints + ESI * 4], EAX

		pop EDX
		pop EBX ; restore EBX
		ret
	ConvertToLetterGrade ENDP

	; =================================== calc GPA ===================================
	CalculateGPA PROC
		push EBX
		MOV pointsSum, 0 ; reset sum

		MOV ECX, numberOfCourses
		MOV idx, 0

		calcPointsSumLoop:
			; get current points
				MOV ESI, idx
				MOV EAX, [coursePoints + ESI * 4]
			; calc sum
				ADD pointsSum, EAX
			inc idx
		LOOP calcPointsSumLoop

		; calc GPA = pointsSum / hrs
			MOV EAX, pointsSum
			MOV EBX, hrsSum
			XOR EDX, EDX ; clear EDX before
			DIV EBX ; EAX = EAX / EBX
			MOV gpaInt, EAX

		; decimals = (remainder * 100) / hrsSum
			MOV EAX, EDX	 ; remainder
			MOV EBX, 100
			MUL EBX ; eax = remainder*100
			MOV EBX, hrsSum
			XOR EDX, EDX ; clearing edx
			DIV EBX ; eax = 2 decimals
			MOV gpaDec, EAX

		; decide gpa result
			; if(gpa >= 3.5) -> Excellent
				CMP gpaInt, 3
				JB checkGood ; gpaInt < 3 => gpa < 3.5
				JA setExcellent ; gpaInt > 3 => gpa >= 3.5
				; gpaInt == 3 -> need decimals >= 50
                CMP gpaDec, 50
                JB  checkGood

			setExcellent:
				MOV EAX, OFFSET excellentMsg 
				MOV gpaResult, EAX 
				JMP endGPA

			checkGood:
			; else if(gpa >= 2) -> Good Standing
				CMP gpaInt, 2
				JB warning
				MOV EAX, OFFSET goodMsg 
				MOV gpaResult, EAX 
				JMP endGPA

			warning:
			; else if(gpa >= 1.5) -> Academic Warning
				CMP gpaInt, 1
				JB probation ; 0.xx < 1.5
				JA setWarning 
				; gpaInt == 1 -> need decimals >= 50
                CMP gpaDec, 50
                JB probation

			setWarning:
				MOV EAX, OFFSET warningMsg 
				MOV gpaResult, EAX 
				JMP endGPA

			probation:
			; else -> Academic Probation
				MOV EAX, OFFSET probationMsg 
				MOV gpaResult, EAX 

			endGPA:
			pop EBX
		ret
	CalculateGPA ENDP

	; =================================== histogram ===================================

	DisplayHistogram PROC
			push EBX
			push ECX

			; title
				MOV EDX, OFFSET histogramTitle   ; "GRADE DISTRIBUTION:"
				call WriteString
				call Crlf

		; A
			MOV EDX, OFFSET gradeAMsg
			call writeString

			MOV ECX, countA
			starLoopA:
				CMP ECX, 0
				JE endStarA
				MOV AL, '*'
				call writeChar
				dec ECX
				JMP starLoopA
			endStarA:

			MOV AL, ' '
			call writeChar
			MOV AL, '('
			call writeChar
			MOV EAX, countA
			call writeDec
			MOV AL, ')'
			call writeChar
			call crlf

		; B
			MOV EDX, OFFSET gradeBMsg
			call writeString

			MOV ECX, countB
			starLoopB:
				CMP ECX, 0
				JE endStarB
				MOV AL, '*'
				call writeChar
				DEC ECX
				JMP starLoopB
			endStarB:

			MOV AL, ' '
			call writeChar
			MOV AL, '('
			call writeChar
			MOV EAX, countB
			call writeDec
			MOV AL, ')'
			call writeChar
			call crlf

		; C
			MOV EDX, OFFSET gradeCMsg
			call writeString

			MOV ECX, countC
			starLoopC:
				CMP ECX, 0
				JE endStarC
				MOV AL, '*'
				call writeChar
				DEC ECX
				JMP starLoopC
			endStarC:

			MOV AL, ' '
			call writeChar
			MOV AL, '('
			call writeChar
			MOV EAX, countC
			call writeDec
			MOV AL, ')'
			call writeChar
			call crlf

		; D
			MOV EDX, OFFSET gradeDMsg
			call writeString

			MOV ECX, countD
			starLoopD:
				CMP ECX, 0
				JE endStarD
				MOV AL, '*'
				call writeChar
				DEC ECX
				JMP starLoopD
			endStarD:

			MOV AL, ' '
			call writeChar
			MOV AL, '('
			call writeChar
			MOV EAX, countD
			call writeDec
			MOV AL, ')'
			call writeChar
			call crlf

		; F
			MOV EDX, OFFSET gradeFMsg
			call writeString

			MOV ECX, countF
			starLoopF:
				CMP ECX, 0
				JE endStarF
				MOV AL, '*'
				call writeChar
				DEC ECX
				JMP starLoopF
			endStarF:

			MOV AL, ' '
			call writeChar
			MOV AL, '('
			call writeChar
			MOV EAX, countF
			call writeDec
			MOV AL, ')'
			call writeChar
			call crlf
			call crlf

			; ACADEMIC STANDING
				MOV EDX, OFFSET standingMsg
				call writeString
				MOV EDX, gpaResult
				call writeString
				call crlf
				call crlf

			; printing ending line
				MOV EDX, OFFSET endingLine
				call writeString
				call crlf

			pop ecx
			pop ebx
			ret
	DisplayHistogram ENDP

END main

