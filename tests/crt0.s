.section .text.init
.global _start

_start:
    # Initialize Stack Pointer. 
    # Our memory array in RTL is 8192 bytes (0x2000) starting at 0x80000000.
    # Therefore, the top of the stack is 0x80002000.
    li sp, 0x80002000
    
    # Jump to C main function
    call main

    # Infinite loop when main returns
end_loop:
    j end_loop

