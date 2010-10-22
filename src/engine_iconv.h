#include "engine_iconv_table_shiftjis.h"

#define CHARSET_UNKNOWN   -1
#define CHARSET_LATIN1     1
#define CHARSET_UNICODE    2
#define CHARSET_UTF8       3
#define CHARSET_SHIFT_JIS  4

int iconv_get_charset_by_name(char *charset_name) {
	if (charset_name != NULL) {
		if (
			(stricmp(charset_name, "latin1" ) == 0) ||
			(stricmp(charset_name, "latin-1") == 0) ||
		0) return CHARSET_LATIN1;
		if (
			(stricmp(charset_name, "unicode") == 0) ||
			(stricmp(charset_name, "utf16"  ) == 0) ||
			(stricmp(charset_name, "utf-16" ) == 0) ||
			(stricmp(charset_name, "utf_16" ) == 0) ||
		0) return CHARSET_UNICODE;
		if (
			(stricmp(charset_name, "utf8" ) == 0) ||
			(stricmp(charset_name, "utf-8") == 0) ||
			(stricmp(charset_name, "utf_8") == 0) ||
		0) return CHARSET_UTF8;
		if (
			(stricmp(charset_name, "shiftjis" ) == 0) ||
			(stricmp(charset_name, "shift-jis") == 0) ||
			(stricmp(charset_name, "shift_jis") == 0) ||
		0) return CHARSET_SHIFT_JIS;
	}
	return CHARSET_UNKNOWN;
}

int iconv_latin1_to_unicode(unsigned char *in_ptr, int in_len, unsigned short **out_ptr, int *out_len) {
	int errors = 0;
	if (out_len != NULL) *out_len = in_len;
	if (out_ptr != NULL) *out_ptr = new unsigned short[in_len];
	for (int n = 0; n < in_len; n++) {
		if (out_ptr != NULL && *out_ptr != NULL) (*out_ptr)[n] = (unsigned short)in_ptr[n];
	}
	return errors;
}

int iconv_unicode_to_latin1(unsigned short *in_ptr, int in_len, unsigned char **out_ptr, int *out_len) {
	int errors = 0;
	if (out_len != NULL) *out_len = in_len;
	if (out_ptr != NULL) *out_ptr = new unsigned char[in_len];
	for (int n = 0; n < in_len; n++) {
		unsigned short ch = (unsigned short)(int)in_ptr[n];
		if (ch >= 0x100) {
			//printf("%04X\n", ch);
			ch = '?';
			errors++;
		}
		if ((out_ptr != NULL) && (*out_ptr != NULL)) (*out_ptr)[n] = (unsigned char)ch;
	}
	return errors;
}

int iconv_unicode_to_utf8(unsigned short *in_ptr, int in_len, unsigned char **out_ptr, int *out_len) {
	int errors = 0;
	unsigned int cur_out_len = 0;
	if (out_ptr != NULL) *out_ptr = (unsigned char *)malloc(in_len * 3);

	for (int n = 0; n < in_len; n++) {
		unsigned short ch = (unsigned short)in_ptr[n];

		if ((out_ptr != NULL) && (*out_ptr != NULL)) {
			if (ch <= 0x7F) {
				(*out_ptr)[cur_out_len++] = (unsigned char)ch;
			} else if (ch <= 0x7FF) {
				(*out_ptr)[cur_out_len++] = 0xC0 | ((ch >>  6) & 0x1F);
				(*out_ptr)[cur_out_len++] = 0x80 | ((ch >>  0) & 0x3F);
			} else if (ch <= 0xFFFF) {
				(*out_ptr)[cur_out_len++] = 0xE0 | ((ch >> 12) & 0x0F);
				(*out_ptr)[cur_out_len++] = 0x80 | ((ch >>  6) & 0x3F);
				(*out_ptr)[cur_out_len++] = 0x80 | ((ch >>  0) & 0x3F);
			} else {
				(*out_ptr)[cur_out_len++] = '?';
				errors++;
			}
		}
	}
	
	if (out_ptr != NULL) *out_ptr = (unsigned char *)realloc(*out_ptr, cur_out_len);
	if (out_len != NULL) *out_len = cur_out_len;

	return errors;
}

int iconv_unicode_to_unicode(unsigned short *in_ptr, int in_len, unsigned short **out_ptr, int *out_len) {
	if (out_len != NULL) *out_len = in_len;
	if (out_ptr != NULL) {
		*out_ptr = new unsigned short[in_len];
		memcpy(*out_ptr, in_ptr, in_len * 2);
	}
	return 0;
}

int iconv_utf8_to_unicode(unsigned char *in_ptr, int in_len, unsigned short **out_ptr, int *out_len) {
	int errors = 0;
	int cur_out_len = 0;
	if (out_ptr != NULL) *out_ptr = (unsigned short *)malloc(in_len * 2);
	for (int n = 0; n < in_len; n++) {
		if (out_ptr != NULL && *out_ptr != NULL) {
			unsigned short ch = 0;
			// Ascii
			if (!(in_ptr[n] & 0x80)) {
				ch = (unsigned short)in_ptr[n];
			} else {
				// 2 Bytes
				if ((in_ptr[n] & 0xE0) == 0xC0) {
					ch |= ((in_ptr[n + 0] & 0x1F) << 6);
					ch |= ((in_ptr[n + 1] & 0x3F) << 0);
					n += 1;
				}
				// 3 Bytes.
				else if ((in_ptr[n] & 0xF0) == 0xE0) {
					ch |= ((in_ptr[n + 0] & 0x0F) << 12);
					ch |= ((in_ptr[n + 1] & 0x3F) <<  6);
					ch |= ((in_ptr[n + 2] & 0x3F) <<  0);
					n += 2;
				}
				// Unknown.
				else {
					ch = '?';
					errors++;
				}
			}
			(*out_ptr)[cur_out_len++] = ch;
			//(*out_ptr)[n] = (unsigned short)in_ptr[n];
		}
	}
	
	if (out_len != NULL) *out_len = cur_out_len;
	if (out_ptr != NULL) *out_ptr = (unsigned short *)realloc(*out_ptr, cur_out_len * 2);
	
	return errors;
}

int iconv_unicode_to_sjis(unsigned short *in_ptr, int in_len, unsigned char **out_ptr, int *out_len) {
	int errors = 0;
	unsigned int cur_out_len = 0;
	if (out_ptr != NULL) *out_ptr = (unsigned char *)malloc(in_len * 2);

	for (int n = 0; n < in_len; n++) {
		unsigned short ch = (unsigned short)in_ptr[n];

		if ((out_ptr != NULL) && (*out_ptr != NULL)) {
			unsigned short ch_out = table_sjis_translate(table_unicode_to_sjis, ch);
			if (ch_out == -1) {
				ch_out = '?';
				errors++;
			}
			(*out_ptr)[cur_out_len++] = ((ch_out >> 0) & 0xFF);
			if (ch_out & 0xFF00) (*out_ptr)[cur_out_len++] = ((ch_out >> 8) & 0xFF);
		}
	}
	
	if (out_ptr != NULL) *out_ptr = (unsigned char *)realloc(*out_ptr, cur_out_len);
	if (out_len != NULL) *out_len = cur_out_len;

	return errors;
}

int iconv_sjis_to_unicode(unsigned char *in_ptr, int in_len, unsigned short **out_ptr, int *out_len) {
	int errors = 0;
	int cur_out_len = 0;
	if (out_ptr != NULL) *out_ptr = (unsigned short *)malloc(in_len * 2);
	for (int n = 0; n < in_len; n++) {
		unsigned char ch1 = in_ptr[n], ch2 = (n + 1 < in_len) ? in_ptr[n + 1] : 0;
		unsigned short ch = (ch1 << 8) | (ch2 << 0); // @TODO: Endian
		if (out_ptr != NULL && *out_ptr != NULL) {
			unsigned short ch_out;
			ch_out = table_sjis_translate(table_sjis_to_unicode, ch);
			if (ch_out == 0xFFFF) {
				ch_out = table_sjis_translate(table_sjis_to_unicode, ch1);
				//printf("DETECTED SINGLE BYTE (%04X)\n", ch_out);
			} else {
				n++;
				//printf("DETECTED MULTIPLE BYTE (%04X)\n", ch_out);
			}
			if (ch_out == 0xFFFF) {
				ch_out = '?';
				errors++;
			}
			
			(*out_ptr)[cur_out_len++] = ch_out;
		}
	}
	
	if (out_len != NULL) *out_len = cur_out_len;
	if (out_ptr != NULL) *out_ptr = (unsigned short *)realloc(*out_ptr, cur_out_len * 2);
	
	return errors;
}


int iconv(char *in_charset_name, char *out_charset_name, char *in_ptr, int in_len, void **out_ptr, int *out_len) {
	int in_charset  = iconv_get_charset_by_name(in_charset_name);
	int out_charset = iconv_get_charset_by_name(out_charset_name);
	
	unsigned short *temporal_unicode_ptr = NULL;
	int             temporal_unicode_len = 0;
	
	if (out_ptr != NULL) *out_ptr = NULL;
	if (out_len != NULL) *out_len = 0;
	
	//printf("iconv(%d->%d)\n", in_charset, out_charset);

	switch (in_charset) {
		case CHARSET_LATIN1   : iconv_latin1_to_unicode ((unsigned char  *)in_ptr, in_len, &temporal_unicode_ptr, &temporal_unicode_len); break;
		case CHARSET_UTF8     : iconv_utf8_to_unicode   ((unsigned char  *)in_ptr, in_len, &temporal_unicode_ptr, &temporal_unicode_len); break;
		case CHARSET_SHIFT_JIS: iconv_sjis_to_unicode   ((unsigned char  *)in_ptr, in_len, &temporal_unicode_ptr, &temporal_unicode_len); break;
		case CHARSET_UNICODE  : iconv_unicode_to_unicode((unsigned short *)in_ptr, in_len / 2, &temporal_unicode_ptr, &temporal_unicode_len); break;
		
	}

	if (temporal_unicode_ptr != NULL) {
		switch (out_charset) {
			case CHARSET_LATIN1   : iconv_unicode_to_latin1 (temporal_unicode_ptr, temporal_unicode_len, (unsigned char **)out_ptr, out_len); break;
			case CHARSET_UTF8     : iconv_unicode_to_utf8   (temporal_unicode_ptr, temporal_unicode_len, (unsigned char **)out_ptr, out_len); break;
			case CHARSET_SHIFT_JIS: iconv_unicode_to_sjis   (temporal_unicode_ptr, temporal_unicode_len, (unsigned char **)out_ptr, out_len); break;
			case CHARSET_UNICODE  : iconv_unicode_to_unicode(temporal_unicode_ptr, temporal_unicode_len, (unsigned short **)out_ptr, out_len); if (out_len != NULL) *out_len *= 2; break;
		}
		delete temporal_unicode_ptr;
	}
	
	return 0;
}
