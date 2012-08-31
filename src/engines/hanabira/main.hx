include("hanabira/pak.nut");
include("hanabira/mgd.nut");
include("hanabira/msd.nut");

screen <- Screen.init(800, 600, 800, 600);
//Audio.init();

paks <- {};
paks["BGM" ] <- PAK(info.game_data_path + "/BGM");
paks["DATA"] <- PAK(info.game_data_path + "/DATA");
paks["MSD" ] <- PAK(info.game_data_path + "/MSD");
paks["MGD" ] <- PAK(info.game_data_path + "/MGD");

//file("test.bmp", "wb").writeblob(paks["DATA"].get("conf_c.bmp"));

msd <- MSD();
msd.load("S001");
msd.execute();
