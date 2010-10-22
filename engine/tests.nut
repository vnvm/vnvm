printf("Tests:\n");
printf("  Test encoding (none)                : '%s'\n", "Hello world áéíóú");
printf("  Test encoding (latin1->latin1)      : '%s'\n", iconv("latin1", "latin1", "Hello world áéíóú"));
printf("  Test encoding (latin1->utf8)        : '%s'\n", iconv("latin1", "utf8", "Hello world áéíóú"));
printf("  Test encoding (latin1->utf8->latin1): '%s'\n", iconv("utf8", "latin1", iconv("latin1", "utf8", "Hello world áéíóú")));
printf("  Test encoding (latin1->shiftjis)    : '%s'\n", iconv("latin1", "shift-jis", "Hello world áéíóú"));
printf("  Test encoding (shiftjis->utf8)      : '%s'\n", iconv("shift-jis", "utf-8", file("test_sjis.txt", "rb").readstringz(13)));
