@echo off
docker build -t mortal/teamcity_server .
docker run -it --name tc_server -p 80:8111 mortal/teamcity_server
