# Samm YT
Smaller projects that don't need their own repositories specificately shown on YouTube

# Build Requirements
- MAKE https://www.gnu.org/software/make/#download
# Windows:
- MSYS2 https://www.msys2.org/ (contains MinGW, GCC, etc.)

# Setup before build (after installing "Build Requirements")
# Windows:
MSYS2:
1. Find MSYS2's install directory (default is: C:/msys64)
2. In that directory run "ucrt64.exe"
3. In the new command prompt looking window that pops up type in "pacman -Syuu" and hit enter
4. The window will ask you to answer twice (at different times) with "Y/n" type "Y" and hit enter the second time the window will close
5. Re-open the prgram "ucrt64.exe"
6. In that window type in "pacman -S mingw-w64-ucrt-x86_64-toolchain" and hit enter
7. If and when your asked to type "Y/n" type "Y" and hit enter
8. Wait for it to finish installing
9. Go back into the file explorer directory where you opened "ucrt64.exe" and enter the relative directory (folder) "ucrt64"
10. Enter the relative directory (folder) "bin"
11. Copy the current absolute directory
12. Type in the windows search bar "path"
13. Press enter to "Edit the system environment variables"
14. Click "Environment variables"
15. In the "System Variables" (although you can do this in the "User variables for [Your username]" but it's less preferable) click "Path"
16. Click "Edit"
17. Click "New" and paste in the path you copied in step 11
18. Hit enter and click "OK"
19. That window will close but you need to click "OK" on the remaining opened windows on/after step 14
20. Your done setting up MSYS2!

# Building
1. Find the folder name of the project you want to compile within the projects folder
2. Compile that project using the command ```make PROJECT=[project you want to compile] OS=[WIN, LINUX, or MACOS (although i've only tested WIN)] [optional: ARCH=[currently just x86 or x64] STATE=[RELEASE or DEBUG] TYPE=[just SOFTWARE for now]] one```

# Build Example
```make PROJECT=float_compress OS=WIN one```

# Clean Example
```make PROJECT=float_compress OS=WIN clean```

# Rebuild Example
```make PROJECT=float_compress OS=WIN rebuild```

# COPYRIGHT
(c) 2024 Samm

While these projects are licensed under the MIT license (in the LICENSE file) please check all the licenses in the licenses folder and any of it's subdirectories

# Note
none of these projects are done in fact I've been having trouble getting the makefile to work so this is a work in progress
