# Teamcity
Teamcity Server &amp; Agents in win-docker (with servicefabric runtime & sdk)

Server is private (cause now i want not spend time to make login/password secure :( ), but u can create it from dockerfile.
Agent public repo https://hub.docker.com/u/mortal/, that able to publish to ServiceFabric. U can create it too, or download.

But we have workaround, thx to https://github.com/LiamLeane, even we have official answer that "Installation of SF inside windows containers is not supported as they do not allow installation of kernel drivers."

Added components to agent:
* .NET Framework 4.7.2
* .NET CLI 2.1.202
* .NET Core SDK 2.1.202
* Git 2.18.0-64
* Open JDK 1.8.0.161-1
* nuget 4.4.1
* VS2017 test agent, build tools
* Targeting Packs 4.0, 4.5.2, 4.6.2, 4.7.2
* Node.js 8.11.3
* ServiceFabric 6.3.162.9494 & SDK 3.2.162.9494 dirty install (components moved from standalone host) - cause of
  * https://github.com/Azure/service-fabric-issues/issues/637</br>
  * https://github.com/Azure/service-fabric-issues/issues/741

p.s. Thx to https://github.com/LiamLeane
