#! /bin/bash


godot --export-release "Web" ./exports/web/index.html
zip -r ./exports/web.zip ./exports/web
butler push ./exports/web.zip  horryportier/palettelockjam:html5

if [[ $1 == "web" ]]; then
	exit 0
fi

godot --export-release "Linux" ./exports/linux/detention_cleaner.x86_64
zip -r ./exports/detention_cleaner_linux.zip ./exports/linux/
butler push ./exports/detention_cleaner_linux.zip  horryportier/palettelockjam:linux

godot --export-release "Windows Desktop" ./exports/windows/detention_cleaner.exe
zip -r ./exports/detention_cleaner_windows.zip ./exports/windows/
butler push ./exports/detention_cleaner_windows.zip  horryportier/palettelockjam:win
