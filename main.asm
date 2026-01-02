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

		call readCourseCode
		call readGrade
		call readHrs

		inc ESI
		call Crlf

	LOOP loopCourses

	exit
main ENDP

; PROCEDURES

readCourseCode:
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
		MOV [courseCodes + curIdx * (5 + 1)], courseCode	

ret

readGrade:
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
		MOV [courseGrades + curIdx * 4], courseGrade

ret

readHrs:
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
		MOV [courseHrsArr + curIdx * 4], courseHrs
		JMP validHrs

	invalidHrs:
		MOV EDX, OFFSET courseHrsErr
		call writeString
		call Crlf
		JMP reEnterHrs

	validHrs:	

ret

END main
