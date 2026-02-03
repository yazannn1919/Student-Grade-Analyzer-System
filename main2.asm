INCLUDE Irvine32.inc

.data
    helloWorldStr BYTE "Hello", 0, "World", 0, 0   ; Null-terminated string
    intValue DWORD 0F1A37CBFh                        ; 32-bit integer value

.code
main PROC
    
main ENDP

  BubbleSort PROC USES eax ecx esi, pArray:PTR WORD, Count: DWORD
  
    MOV ECX, Count
    dec Count ; dec count by 1
    
    L1:
    
      push ECX ; save outer loop count
      MOV ESI, pArray ; point to the first value
      
        L2:
        
          MOV EAX, [ESI] ; EAX = arr[j] 
          CMP [ESI + 4], EAX ; compare arr[j+1], eax
          JGE L3 ; if arr[j] <= arr[j+1], skip
          
          XCHG EAX, [ESI + 4] ; else (arr[j] > arr[j+1]), swap the pair
          MOV [ESI], EAX
          
          L3: 
            ADD ESI, 4 ; mov pointer forward (4 bc dword)
        
        loop L2 ; inner loop
      
      pop ECX ; retrieve outer loop count
    
    loop L1 ; else repeat outer loop
    
    ret
  
  BubbleSort ENDP
  
  BinarySearch PROC USES ebx edx esi edi, pArray:PTR DWORD, Count:DWORD, searchVal:DWORD
    
    LOCAL first:DWORD, last:DWORD, mid:DWORD ; int first, last, mid;
    
    MOV first, 0 ; first = 0
    
    MOV EAX, Count
    dec EAX
    MOV last, EAX ; last = count - 1 
    
    MOV EDI, searchVal ; edi = target
    MOV EBX, pArray ; ebx = arr
    
    L1:
    
    ; while (first <= last)
      MOV EAX, first
      CMP EAX, last
      JG L5 ; if not found inside while then eax = -1
    
    ; mid = (first + last) / 2 
      MOV EAX, last
      ADD EAX, first
      SHR EAX, 1 
    
    ; EDX = arr[mid]
    ; [base + index * 4]
      MOV ESI, mid
      SHL ESI, 2
      MOV EDX, [EBX + ESI] ; EDX = base(ebx) + (index(mid) * element_size(4))
    
    ; if(EDX < searchVal(EDI))
      CMP EDX, EDI
      JGE L2
    ; first = mid + 1 
      MOV EAX, mid
      inc EAX 
      MOV first, EAX
      JMP L4
    
    ; else if(EDX > searchVal(EDI))
      L2:
        CMP EDI, EDI
        JLE L3
    ; last = mid - 1 
        MOV EAX, mid
        dec EAX
        MOV last, EAX
        JMP L4
    
    ; else return mid
      L3:
        MOV EAX, mid
        JMP L9
    
    L4: JMP L1 ; complete while
    L5: MOV EAX, -1 ; element not found
    L9: ret ; return 
    
  BinarySearch ENDP
END main
