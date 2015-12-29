============================
Visual Novel Virtual Machine
============================

------------------
SUPPORTED ENGINES:
------------------

- Cs's engine (Dividead) [ingame] (partially implemented, not playable yet)
- Will Engine (Yume Miru Kusuri / Princess Waltz) [broken] (not ported again yet from the squirrel engine)
- ARPG (Brave Soul) [ingame] (partially implemented, not playable yet)
- XYZ (True Love) [menus] (partially implemented)

--------------------
COMPILE FROM SOURCE:
--------------------

1. Download and install Haxe NME: http://www.haxenme.org/download/
2. Download required libraries with haxelib:
	- haxelib install format
	- haxelib install munit	
3. Build the project:
	- cd /path/to/your/repository/clone
	- nme test windows
	- nme test linux
	- nme test mac
	- nme test android
	- nme test ios
	- nme test ios -simulator
	- nme test webos
	- nme test html5
	- nme test flash
	
Currently the project has been tested on: windows, mac, ios and android

------------------------
WHERE TO PUT GAME FILES:
------------------------

* On android: /mnt/sdcard/vnvm/<GAME_ID>
* On iOS: /private/var/mobile/vnvm/<GAME_ID>
* On windows/linux/mac: /path/to/game/executable/assets/<GAME_ID>

---------
GAME IDS:
---------

* tlove    - True Love
* brave    - Brave Soul
* dividead - Divi Dead
* ymk      - Yume Miru Kusuri
* pw       - Princess Waltz