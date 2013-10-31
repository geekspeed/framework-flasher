--------------------------------------
| Framework Flasher 1.2
| Created by Wes Foster (AKA: wesf90, therealwesfoster)
| Last Update: January 12th, 2012
| URL: http://forum.xda-developers.com/showthread.php?p=21133479
--------------------------------------


CONTENTS
----------------
- HOW TO
- ABOUT
- DONATE
- SUPPORT
- LATEST UPDATES



HOW TO
----------------
1. Place your APK file inside of the 'place-apk-to-edit-here' folder
2. Run this script and choose option 1 to decompile.
3. Go into the 'files-to-edit' folder and begin making your changes.
4. Once finished making changes, open this script and choose option 2 (compile).
5. Once the compile is complete, choose option 3 to sign the APK
6. Once signed, choose option 4 to create the flashable .zip file.
7. You're done! Your flashable file is located in the 'final-zip-file' and is named update.zip
8. Simply load this file onto your sd card, reboot your phone into bootstrap recovery, wipe cache, and install from sd card!

NOTE:
- If you edit any files that contain strings, DO NOT FORGET TO ESCAPE QUOTES
- Make a nandroid backup before flashing. Better safe than sorry when hacking these expensive paper weights.
- If you are editing system APKs, do not resign them unless you want to resign all the APKs that share its shared:uid



ABOUT
----------------
Framework Flasher 1.2
ApkTool v1.4.3
7za v4.6.5
Android Asset Packaging Tool v0.2




SUPPORT
----------------
Need additional help, have a question, or want to get the latest version of Framework Flasher?

Visit the official Framework Flasher idea/support thread here:
http://forum.xda-developers.com/showthread.php?p=21133479

To help others help you with any problems, please be ready to present the section from your Logs.txt file
that pertains to your problem.



LATEST UPDATES
----------------
To see the entire changelog, visit the URL at the top of this ReadME.txt

- Now supports multiple files to be edited
- Save multiple files to zip with custom directory flashing structure
- Removed the need to manually delete files when compiling the APK
- Improved Error logging