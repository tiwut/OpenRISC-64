@echo off
echo Cleaning OpenRISC-64 repository...

if exist obj_dir rmdir /s /q obj_dir
if exist CMakeFiles rmdir /s /q CMakeFiles

del /s /q *.vcd 2>nul
del /s /q *.elf 2>nul
del /s /q *.hex 2>nul
del /s /q *.bin 2>nul
del /s /q *.o 2>nul
del /s /q *.a 2>nul
del /s /q *.d 2>nul
del /s /q *.log 2>nul
del /s /q *.tmp 2>nul
del /s /q CMakeCache.txt 2>nul
del /s /q *.pdf 2>nul
del /s /q *.png 2>nul
del /s /q *.jpg 2>nul

echo Clean-up complete.
