@echo off
echo ��ǰ�̷���%~d0
echo ��ǰ�̷���·����%~dp0
echo ��ǰ������ȫ·����%~f0
echo ��ǰ�̷���·���Ķ��ļ�����ʽ��%~sdp0
echo ��ǰCMDĬ��Ŀ¼��%cd%

set PATCH=%cd%\proj.win32\Debug\
set BIN=%cd%\proj.win32\Debug\sanguo.exe
echo ��ǰ: %BIN%
start %BIN% -landscape -size 1136x640
rem pause