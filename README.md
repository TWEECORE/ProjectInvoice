# AppSource Base

This is a clone - project.
__________________________________
Nötige Anpassungen: 
required changes: 
  1. app -> app.json -> Namen, idRanges
  2. test -> app.json -> Namen, idRanges, dependencies Namen
__________________________________
# How to prepaire this project for AppSource
__________________________________
## 1. Compile the Project
After you finished the changes on the app you need to compile the project.
## 2. Sign the APP - File
1. Copy the APP - File on the Remote Server "BC". Directory "C:\apps"
2. Get the NAV - SIP

    Install-NAVSipCryptoProviderFromBCContainer CONTAINER-NAME
    
3. Open the PowerShell ISE as administrator
4. Open the file "C:\Scripts\AzureSignTool_TWE.ps1"
5. Change the app name at the end of the line to your App Package - Namen
6. Run the Script. 