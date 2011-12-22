@echo off
rd /s /q deploy
md deploy
md deploy\engine
md deploy\game_save
md deploy\game_data
md deploy\game_data\hanabira
md deploy\game_data\pw
md deploy\game_data\ymk
md deploy\game_data\dividead
md deploy\game_data\tlove
copy *.exe deploy
copy *.dll deploy
copy game_data\*.txt deploy\game_data
xcopy /S /D engine deploy\engine