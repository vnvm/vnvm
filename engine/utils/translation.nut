class Translation
{
	translation_file = null;
	texts = null;
	
	function setFile(translation_file)
	{
		this.reset();
		this.translation_file = translation_file;
		if (file_exists(translation_file)) {
			printf("Loaded translation: '%s'\n", translation_file);
			try {
				include(translation_file);
			} catch (e) {
				
			}
		}
	}
	
	function save()
	{
		::copyfile(this.translation_file, this.translation_file + ".bak");
		local f = file(this.translation_file, "wb");
		foreach (text_id, line in this.texts) {
			_writestringz(f, format("translation.add(%d, \"%s\", \"%s\");\n", text_id, ::addcslashes(line.text), ::addcslashes(line.title)), 0);
		}
	}
	
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
	
	function askTranslate(textIn, textOut)
	{
		writefile("input.txt", textIn);
		writefile("output.txt", textOut);
		local result = system("..\\PrompTranslate.exe");
		printf("RESULT: %d\n", result);
		if (result == 0) {
			local resultStr = readfile("output.txt");
			printf("RESULT: '%s'\n", resultStr);
			return resultStr;
		} else {
			return false;
		}
	}
}

translation <- Translation();
