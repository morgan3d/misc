@echo off
if %1!==! %0 *.c *.cc *.cpp *.h *.java *.js
for %%P in ( %1 %2 %3 %4 %5 %6 %7 %8 %9 ) do bcpp -fnc indent.cfg %%P
