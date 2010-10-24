<?php
if (!file_exists('SHIFTJIS.TXT')) file_put_contents('SHIFTJIS.TXT', file_get_contents('http://unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/SHIFTJIS.TXT'));

$table = array();

foreach (file('SHIFTJIS.TXT') as $line) {
	$line = trim($line);
	if (preg_match("@(0x[0-9A-Fa-f]{2,4})\\s+(0x[0-9A-Fa-f]{2,4})@", $line, $matches)) {
		$from = hexdec(substr($matches[1], 2));
		$to   = hexdec(substr($matches[2], 2));
		$table[$from] = $to;
	}
}

$f = fopen('../src/engine_iconv_table_shiftjis.h', 'wb');
fprintf($f, "typedef struct { unsigned short from; unsigned short to; } SJIS_COVERT;\n");
fprintf($f, "SJIS_COVERT table_sjis_to_unicode[] = {\n");
ksort($table); foreach ($table as $from => $to) { fprintf($f, "\t{0x%04X, 0x%04X},\n", $from, $to); }
fprintf($f, "};\n");
fprintf($f, "SJIS_COVERT table_unicode_to_sjis[] = {\n");
asort($table); foreach ($table as $from => $to) { fprintf($f, "\t{0x%04X, 0x%04X},\n", $to, $from); }
fprintf($f, "};\n");

fprintf($f, <<<EOF
int table_sjis_translate_cmp(const void *_a, const void *_b) {
	SJIS_COVERT *a = (SJIS_COVERT *)_a;
	SJIS_COVERT *b = (SJIS_COVERT *)_b;
	return (int)a->from - (int)b->from;
}

EOF
);

fprintf($f, <<<EOF
unsigned short table_sjis_translate_ex(SJIS_COVERT *table_ptr, int table_len, unsigned short value) {
	SJIS_COVERT *result = (SJIS_COVERT *)bsearch(&value, table_ptr, table_len, sizeof(table_ptr[0]), table_sjis_translate_cmp);
	return (result != NULL) ? result->to : -1;
}

#define table_sjis_translate(TABLE, VALUE) table_sjis_translate_ex((TABLE), sizeof(TABLE) / sizeof((TABLE)[0]), (VALUE))

EOF
);

$f = fopen('charset.bin', 'wb');
for ($n = 0; $n < 256; $n++) $table[] = $n;
$table = array_unique($table, SORT_NUMERIC);
asort($table);
foreach ($table as $to) fwrite($f, pack('v', $to));
fclose($f);