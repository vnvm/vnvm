class Translation
{
	texts = null;
	
	function reset()
	{
		this.texts = {};
	}
	
	function get(text_id, text, title = "")
	{
		if (text_id in this.texts) {
			return this.texts[text_id];
		} else {
			return {
				text  = text,
				title = title,
			};
		}
	}

	function add(text_id, text, title = "")
	{
		this.texts[text_id] <- {
			text  = text,
			title = title,
		};
		//printf("%d: %s, %s", text_id, title, text);
	}
}

translation <- Translation();
