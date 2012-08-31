package engines.dividead;

/*
class BotPlayer
{
	static function select(options)
	{
		if (!("bot_options" in BotPlayer)) BotPlayer.bot_options <- {};
		if (!("bot_options_max" in BotPlayer)) BotPlayer.bot_options_max <- 0;
	
		local hash, min = 9999999, min_option = [];
		for (local n = 0; n < options.len(); n++) {
			if (!("text" in options[n])) {
				hash = "map_" + options[n].x1 + "_" + options[n].y1 + "_" + options[n].x2 + "_" + options[n].y2;
			} else {
				hash = options[n].text;
			}

			if (!(hash in BotPlayer.bot_options)) BotPlayer.bot_options[hash] <- 0;

			if (BotPlayer.bot_options[hash] < min) {
				min = BotPlayer.bot_options[hash];
				min_option = [hash, n];
			}
			
			//printf("HASH(%s):%d\n", hash, BotPlayer.bot_options[hash]);
		}
		
		BotPlayer.bot_options_max <- BotPlayer.bot_options_max + 1;
		BotPlayer.bot_options[min_option[0]] <- BotPlayer.bot_options_max;
		//printf("MAX2: %d\n", BotPlayer.bot_options_max);
		return min_option[1];
	}
}
*/
