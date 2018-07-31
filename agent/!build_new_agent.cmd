@echo off
set ver=1.5
echo %ver%
docker build -t mortal/teamcity_agent:%ver% . 
pause
docker run -it --name tc_agent_%ver% -e SERVER_URL="teamcity.%userdnsdomain%" -e AGENT_NAME=%COMPUTERNAME%_v%ver% -v C:/TeamCity_docker/agent/config_%ver%:C:/BuildAgent/conf mortal/teamcity_agent:%ver%
