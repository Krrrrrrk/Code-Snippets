# Code-Snippets
Dumping ground for random code snippets I've written. These are all written/used in a Windows enviroment, unless noted. 

## jpgtopng.py
Searches a folder recursively for any .jpg files, converts them to .png and saves them in the same location. Has the option to exclude a folder from the recursive search. 

## PS-PSEXEC_Remote_App_Deploy.ps1
Uses Powershell to copy a install file to each computer inside an AD OU, then PSEXEC to silently install it. 

## PS-PSEXEC_Remote_DLL_Replace.ps1
Uses PowerShell and PSEXEC to Unregister, rename, and replace UEClientObj.dll. Can be edited to target any .dll/file.

## FLAC_Copy_NoMP3.ps1
Scans a music folder for album directories that contain .flac files at the top level (ignores subfolders). If found, copies the entire album folder—including subdirectories—to a new location. Skips any album folders without top-level .flac files and logs both copied and skipped folders. Has a toggle to do a dry run.
