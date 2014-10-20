@echo off
echo 当前盘符：%~d0
echo 当前盘符和路径：%~dp0
echo 当前批处理全路径：%~f0
echo 当前盘符和路径的短文件名格式：%~sdp0
echo 当前CMD默认目录：%cd%

set PATCH=%cd%\proj.win32\Debug\
set BIN=%cd%\proj.win32\Debug\sanguo.exe
echo 当前: %BIN%
start %BIN% -landscape -size 1136x640
rem pause