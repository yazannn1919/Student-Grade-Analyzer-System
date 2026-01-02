INCLUDE Irvine32.inc
.data
; ----- Prompts -----
nameMsg BYTE "Enter student name: ", 0
courseNumMsg BYTE "Enter number of courses (1-20): ", 0
courseNumErr BYTE "Invalid number. Please enter a number between 1 and 20.", 0
courseCodeMsg BYTE "  Course code: ", 0
courseCodeErr BYTE "  Invalid course code. Please enter 5 characters.", 0
courseGradeMsg BYTE "  Numeroc grade (0-100): ", 0
courseGradeErr BYTE "  Invalid grade. Please enter a number between 0 and 100.", 0
courseHrsMsg BYTE "  Credit hours (1-4): ", 0
courseHrsErr BYTE "  Invalid hours. Please enter a number between 1 and 4.", 0
systemTitle1 BYTE "===========================================", 0
systemTitle2 BYTE "       STUDENT GRADE ANALYZER SYSTEM       ", 0
systemTitle3 BYTE "===========================================", 0


;----- Variables -----
studentName BYTE 20 + 1 DUP(0)
N DWORD ?
courseCode BYTE 5 + 1 DUP(0)
courseCodeLen DWORD ?
courseCodes BYTE 20 * (5 + 1) DUP(0)
courseGrade DWORD ?
courseGrades DWORD 20 DUP(0)
courseHrs DWORD ?
courseHrsArr DWORD 20 DUP(0)
gradeLetters BYTE 20 DUP(0)
gradePoints REAL4 20 DUP(0.0)
currGrade DWORD ?

;----- Saved Registers -----
savedECX DWORD ?
curIdx DWORD ?


.code
main PROC
	;=============================== users name =============================

	MOV EDX, OFFSET nameMsg
	call writeString

	MOV EDX, OFFSET studentName
	MOV ECX, SIZEOF studentName - 1
	call readString


	;=========== number of courses (while loop validation) =================

	reEnterNum:

	MOV EDX, OFFSET courseNumMsg
	call writeString
	call readInt

	; if(num >= 1 && num <= 20)
	CMP EAX, 1
	JB invalidNum
	CMP EAX, 20
	JA invalidNum

	; valid
	MOV N, EAX
	JMP validNum

	invalidNum:
	MOV EDX, OFFSET courseNumErr
	call writeString
	call Crlf 
	JMP reEnterNum

	validNum:

	;======================== courses input loop ======================
	MOV ECX, N
	MOV ESI, 0

	loopCourses:
		MOV curIdx, ESI

		;call readCourseCode
		;call readGrade
		;call readHrs
		;call decideLetters

		inc ESI
		call Crlf

	LOOP loopCourses


	;======================== output title =============================

	MOV EDX, OFFSET systemTitle1
	call writeString
	call Crlf
	MOV EDX, OFFSET systemTitle2
	call writeString
	call Crlf
	MOV EDX, OFFSET systemTitle3
	call writeString
	call Crlf

	;======================== process ldk fkdmfkda =============================



	exit
main ENDP

; PROCEDURES

;======================== course code =============================
readCourseCode PROC,
	reEnterCode:

	; prompt for course code
		MOV EDX, OFFSET courseCodeMsg
		call writeString

	; save ecx for loop in main
		MOV savedECX, ECX

	; read course code
		MOV ECX, SIZEOF courseCode - 1
		MOV EDX, OFFSET courseCode
		call readString
		MOV courseCodeLen, EAX ; length of input 

	; restore ecx
		MOV ECX, savedECX

	; if(length == 5) -> validCode
		MOV EAX, courseCodeLen
		CMP EAX, 5
		JE validCode

	; invalid
		MOV EDX, OFFSET courseCodeErr
		call writeString
		call Crlf 
		JMP reEnterCode

	validCode:
		;MOV [courseCodes + curIdx * (5 + 1)], courseCode	

ret
readCourseCode ENDP

;======================== read grade =============================
readGrade PROC,
	reEnterGrade:

	; prompt for grade and read
		MOV EDX, OFFSET courseGradeMsg
		call writeString
		call readInt

	; if(grade >= 0 && grade <= 100)
		CMP EAX, 0
		JB invalidGrade
		CMP EAX, 100
		JA invalidGrade

	; valid
		MOV courseGrade, EAX
		JMP validGrade

	invalidGrade:
		MOV EDX, OFFSET courseGradeErr
		call writeString
		call Crlf
		JMP reEnterGrade

	validGrade:
		;MOV [courseGrades + curIdx * 4], courseGrade

ret
readGrade ENDP

;======================== read hours =============================
readHrs PROC,
	reEnterHrs:

	; prompt for hours and read
		MOV EDX, OFFSET courseHrsMsg
		call writeString
		call readInt

	; if(hrs >= 1 && hrs <= 4)
		CMP EAX, 1
		JB invalidHrs
		CMP EAX, 4	
		JA invalidHrs

	; valid
		MOV courseHrs, EAX
		;MOV [courseHrsArr + curIdx * 4], courseHrs
		JMP validHrs

	invalidHrs:
		MOV EDX, OFFSET courseHrsErr
		call writeString
		call Crlf
		JMP reEnterHrs

	validHrs:	

ret
readHrs ENDP

;======================== assign letters and points =============================
decideLetters PROC,

	MOV EBX, [courseGrades + curIdx * 4]
	; if(grade >= 90) -> A
	; if(grade >= 80 && grade < 90) -> B
	; if(grade >= 70 && grade < 80) -> C
	; if(grade >= 60 && grade < 70) -> D
	; if(grade < 60) -> F

	; try A:
	CMP EBX, 90
	JB checkB
	MOV AL, 'A'
	MOV [gradePoints + curIdx * 4], 4.0
	JMP storeLetter

	; try B:
	checkB:
	CMP EBX, 80
	JB checkC
	MOV AL, 'B'
	MOV [gradePoints + curIdx * 4], 3.0
	JMP storeLetter

	; try C:
	checkC:
	CMP EBX, 70
	JB checkD
	MOV AL, 'C'
	MOV [gradePoints + curIdx * 4], 2.0
	JMP storeLetter

	; try D:
	checkD:
	CMP EBX, 60
	JB storeF
	MOV AL, 'D'
	MOV [gradePoints + curIdx * 4], 1.0
	JMP storeLetter

	; store F:
	storeF:
	MOV [gradePoints + curIdx * 4], 0.0
	MOV AL, 'F'

	storeLetter:
	MOV [gradeLetters + curIdx * 4], AL

ret
decideLetters ENDP

;======================== assign letters =============================
	


END main
