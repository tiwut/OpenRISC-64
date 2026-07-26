.section .text
.global _start

_start:
    # 1. Configure mtvec (Machine Trap Vector)
    addi x1, x0, 0x80
    csrrw x0, 0x305, x1
    
    # 2. Setup L2 Page Table at PA = 0x80001000 (PPN = 0x80001)
    lui x1, 0x80001       
    
    # PTE Content = 0x200000DF (PPN=0x80000, V=1, R=1, W=1, X=1, U=0, G=0, A=1, D=1)
    # Using Megapage mapping (1GB)
    lui x2, 0x20000
    addi x2, x2, 0x0DF
    
    # Map VA 0x80000000 (Identity mapping for PC) -> PTE at L2 offset 2 (0x80001010)
    sd x2, 16(x1)
    
    # Map VA 0x40000000 (Alias mapping for Data) -> PTE at L2 offset 1 (0x80001008)
    sd x2, 8(x1)
    
    # 3. Enable SV39 MMU via SATP (satp = 0x180)
    # SATP = (8 << 60) | PPN(0x80001)
    lui x3, 0x80000       
    slli x3, x3, 32       
    
    lui x4, 0x80          
    addi x4, x4, 1        
    
    or x3, x3, x4         
    csrrw x0, 0x180, x3   
    
    # 4. Switch to S-Mode (Supervisor)
    # mstatus.MPP is bits 12:11. Set to 01 for S-Mode.
    addi x5, x0, 1
    slli x5, x5, 11       
    csrrw x0, 0x300, x5
    
    # Set mepc to point to mapped_code
    auipc x6, 0           
    addi x6, x6, 16       
    csrrw x0, 0x341, x6   
    
    mret                  
    
mapped_code:
    # 5. We are now in S-Mode with MMU enabled!
    # Read from aliased VA 0x40000000 -> Should hit L2 Megapage and read from PA 0x80000000
    lui x7, 0x40000
    ld x8, 0(x7)
    
    # 6. Trigger a Page Fault!
    # Read from unmapped VA 0xC0000000 -> Should trap to 0x80
    lui x7, 0xC0000
    ld x9, 0(x7)
    
    # Should never reach here
wait_loop:
    j wait_loop

.org 0x80
trap_handler:
    # 7. Trap Handler
    # We successfully trapped a Page Fault!
    addi x10, x0, 1       
    
end_trap:
    j end_trap

