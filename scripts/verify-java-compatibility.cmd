@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify-java-compatibility.ps1" %*
