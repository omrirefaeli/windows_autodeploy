# Overview
This PS script is meant for rapid utils installation for newly created machines (VMs/endpoints). It does the following:

1. Using Chocolately installs some utils 
    - 7zip, notepad++, chrome, everything, 010editor, git, sysinternals
    - optional (with prompt): adobereader, obsidian. (Adding/removing more Chocolately packages to the array is of course possible)
2. Replaces the annoying new Windows 11 Right Click menu with the old one. 
3. Creates elevated shortcuts for Windows Terminal (wt.exe) at Ctrl+Alt+T, and non-elevated shortcuts for notepad++ at Ctrl+Alt+P.
4. Enables WSL


# How to run

1. Open Powershell ISE with administrator privileges
2. Open the PS1 script that is in this repo
3. Run it with F5 (running scripting is not enabled by default on newly created machine)
