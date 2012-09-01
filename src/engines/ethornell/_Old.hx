/*
// This program is realeased AS IT IS. Without any warranty and responsibility from the author.
import std.file, std.string, std.stdio, std.stream, std.c.stdio, std.c.string, std.intrinsic, std.c.stdlib;

// Version of the utility.
const char[] _version = "0.3";

int main(char[][] args) {
	// Shows the help for the usage of the program.
	void show_help() {
		writefln("Ethornell utility %s - soywiz - 2009 - Build %s", _version, __TIMESTAMP__);
		writefln("Knows to work with English Shuffle! with Ethornell 1.69.140");
		writefln();
		writefln("ethornell <command> <parameters>");
		writefln();
		writefln("  -l       List the contents of an arc pack");
		writefln("  -x[0-9]  Extracts the contents of an arc pack (uncompressing when l>0)");
		writefln("  -p[0-9]  Packs and compress a folder");
		writefln();
		writefln("  -d       Decompress a single file");
		writefln("  -c[0-9]  Compress a single file");
		writefln("  -t[0-9]  Test the compression");
		writefln();
		writefln("  -h       Show this help");
	}

	// Throws an exception if there are less parameters than the required.
	void expect_params(int count) {
		if (args.length < (count + 2)) throw(new ShowHelpException(format("Expected '%d' params and '%d' received", count, args.length - 2)));
	}
	
	try {
		if (args.length < 2) throw(new ShowHelpException);

		char[][] params = [];
		if (args.length > 2) params = args[2..args.length];
		
		struct ImageHeader {
			short width, height;
			int bpp;
			int zpad[2];
		}

		bool check_image(ImageHeader i) {
			return (
				((i.bpp % 8) == 0) && (i.bpp > 0) && (i.bpp <= 32) && 
				(i.width > 0) && (i.height > 0) &&
				(i.width < 8096) && (i.height < 8096) &&
				(i.zpad[0] == 0) && (i.zpad[1] == 0)
			);
		}
		
		void write_image(ImageHeader ih, char[] out_file, void[] data) {
			if (ih.bpp != 32 && ih.bpp != 24) throw(new Exception("Unknown bpp"));
			//scope f = new BufferedFile(out_file, FileMode.OutNew);
			TGA.write32(out_file, ih.width, ih.height, data, ih.bpp);
			//f.close();
		}
		
		switch (args[1][0..2]) {
			// List.
			case "-l": {
				expect_params(1);
				auto arc_name = params[0];

				// Check if the arc actually exists.
				assert(std.file.exists(arc_name), format("File '%s' doesn't exists", arc_name));

				// Writes a header with the arc file that we are processing.
				writefln("----------------------------------------------------------------");
				writefln("ARC: %s", arc_name);
				writefln("----------------------------------------------------------------");
				// Iterate over the ARC file and write the files.
				foreach (e; ARC(arc_name)) printf("%s\n", std.string.toStringz(e.name));
			} break;
			// Extact + uncompress.
			case "-x":
				int level = 9;
				if (args[1].length == 3) level = args[1][2] - '0';
				expect_params(1);
				auto arc_name = params[0];

				// Check if the arc actually exists.
				assert(std.file.exists(arc_name), format("File '%s' doesn't exists", arc_name));

				// Determine the output path and create the folder if it doesn't exists already.
				auto out_path = arc_name ~ ".d";
				try { mkdir(out_path); } catch {}

				// Iterate over the arc file.
				foreach (e; ARC(arc_name)) {
					if (params.length >= 2) {
						bool found = false;
						foreach (filter; params[1..params.length]) {
							if (filter == e.name) { found = true; break; }
						}
						if (!found) continue; 
					}
					scope s = e.open;
					printf("%s...", std.string.toStringz(e.name));
					char[] out_file;
					if (params.length >= 2) {
						out_file = e.name;
					} else {
						out_file = out_path ~ "/" ~ e.name;
					}
					
					try {
						// Check the first 0x10 bytes to determine the magic of the file.
						switch ((new SliceStream(s, 0)).readString(0x10)) {
							// Encrypted+Static Huffman+LZ
							case "DSC FORMAT 1.00\0": {
								writef("DSC...");
								if (std.file.exists(out_file)) throw(new Exception("Exists"));
								ubyte[] data;
								if (level == 0) {
									data = cast(ubyte[])s.readString(s.size);
								} else {
									scope dsc = new DSC(s);
									data = dsc.data;
								}
								ImageHeader ih;
								ih = *cast(ImageHeader *)data;
								if (check_image(ih)) {
									writef("Image...BPP(%d)...", ih.bpp);
									out_file ~= ".tga";
									if (std.file.exists(out_file)) throw(new Exception("Exists"));
									write_image(ih, out_file, data[0x10..data.length]);
								} else {
									std.file.write(out_file, data);
								}
							} break;
							// Encrypted+Dynamic Huffman+RLE+LZ+Unpacking+Row processing
							case "CompressedBG___\0": {
								out_file ~= ".tga";
								writef("CBG...");
								if (std.file.exists(out_file)) throw(new Exception("Exists"));
								scope cbg = new CompressedBG(s);
								cbg.write_tga(out_file);
							} break;
							// Uncompressed/Unknown.
							default: {
								auto ss = new SliceStream(s, 6);
								short width, height; uint bpp;
								ImageHeader ih;
								ss.readExact(&ih, ih.sizeof);
								if (check_image(ih)) {
									writef("Image...BPP(%d)...", ih.bpp);
									out_file ~= ".tga";
									if (std.file.exists(out_file)) throw(new Exception("Exists"));
									s.position = 0x10;
									write_image(ih, out_file, s.readString(s.size - s.position));
								} else {
									writef("Uncompressed...");
									if (std.file.exists(out_file)) throw(new Exception("Exists"));
									scope f = new BufferedFile(out_file, FileMode.OutNew);
									f.copyFrom(s);
									f.close();
								}
							} break;
						}
						writefln("Ok");
					}
					// There was an error, write it.
					catch (Exception e) {
						writefln(e);
					}
				}
			break;
			// Packs and compress a file.
			case "-p": {
				int level = 9;
				if (args[1].length == 3) level = args[1][2] - '0';

				expect_params(1);
				auto folder_in = params[0];
				auto arc_out   = folder_in[0..folder_in.length - 2];
				
				// Check if the file actually exists.
				assert(std.file.exists(folder_in), format("Folder '%s' doesn't exists", folder_in));
				assert(folder_in[folder_in.length - 6..folder_in.length] == ".arc.d", format("Folder '%s', should finish by .arc.d", folder_in));
				int count = listdir(folder_in).length;
				scope s = new BufferedFile(arc_out, FileMode.OutNew);
				s.writeString("PackFile    ");
				s.write(cast(uint)count);
				int pos = 0;

				foreach (k, file_name; listdir(folder_in)) {
					writef("%s...", file_name);
					scope data = cast(ubyte[])std.file.read(folder_in ~ "/" ~ file_name);
					scope ubyte[] cdata;
					// Already compressed.
					if (data[0..0x10] == cast(ubyte[])"DSC FORMAT 1.00\0") {
						cdata = data;
						writefln("Already compressed");
					}
					// Not compressed.
					else {
						cdata = compress(data, level);
						writefln("Compressed");
					}
					s.position = 0x10 + count * 0x20 + pos;
					s.write(cdata);
					s.position = 0x10 + k * 0x20;
					s.writeString(file_name);
					while (s.position % 0x10) s.write(cast(ubyte)0);
					s.write(cast(uint)pos);
					s.write(cast(uint)cdata.length);
					s.write(cast(uint)0);
					s.write(cast(uint)0);
					pos += cdata.length;
				}
				s.close();
			} break;
			// Decompress a single file.
			case "-d":
				expect_params(1);
				auto file_name = params[0];
				auto out_file = file_name ~ ".u";

				// Check if the file actually exists.
				assert(std.file.exists(file_name), format("File '%s' doesn't exists", file_name));

				scope dsc = new DSC(file_name);
				dsc.save(out_file);
			break;
			// Compress a single file.
			case "-c":
				int level = 9;
				if (args[1].length == 3) level = args[1][2] - '0';
				expect_params(1);
				auto file_name = params[0];
				auto out_file = file_name ~ ".c";

				// Check if the file actually exists.
				assert(std.file.exists(file_name), format("File '%s' doesn't exists", file_name));

				std.file.write(out_file, compress(cast(ubyte[])std.file.read(file_name), level));
			break;
			// Test the compression.
			case "-t": {
				int level = 9;
				if (args[1].length == 3) level = args[1][2] - '0';
				expect_params(1);
				auto file_name = params[0];

				// Check if the file actually exists.
				assert(std.file.exists(file_name), format("File '%s' doesn't exists", file_name));

				auto uncompressed0 = cast(ubyte[])std.file.read(file_name);
				auto compressed    = compress(uncompressed0, level);
				scope dsc = new DSC(new MemoryStream(compressed));
				auto uncompressed1 = dsc.data;
				
				assert(uncompressed0 == uncompressed1, "Failed");
				writefln("Ok");
			} break;
			// Help command.
			case "-h":
				throw(ShowHelpException());
			break;
			// Unknown command.
			default:
				throw(ShowHelpException(format("Unknown command '%s'", args[1])));
			break;
		}

		return 0;
	}
	// Catch a exception to show the help/usage.
	catch (ShowHelpException e) {
		show_help();
		if (e.toString.length) writefln(e);
		return 0;
	}
	// Catch a generic unhandled exception.
	catch (Exception e) {
		writefln("Error: %s", e);
		return -1;
	}
}

import std.stdio;
import std.stream;
import std.string;
import std.file;
import std.math;

void fcap_extract_all() {
	fcap_extract("bg");
	fcap_extract("bgm");
	fcap_extract("graphic");
	fcap_extract("script");
	fcap_extract("se");
	fcap_extract("sg");
	fcap_extract("system");
	fcap_extract("visual");
	fcap_extract("voice");
}

void gpd_save_folder(char[] path) {
	foreach (file; listdir(path)) {
		if (file.length >= 4 && file[file.length - 4..file.length] != ".GPD") continue;
		char[] ffile = path ~ "/" ~ file;
		printf("%s...", std.file.toStringz(file));
		if (std.file.exists(ffile ~ ".tga")) { writefln("Exists"); continue; }
		gpd_save(ffile);
		writefln("Ok");
	}
}

ubyte[] scr_extract(ubyte[] data) {
	return lz_decompress(data[0x80..data.length]);
}

void scr_extract_all(char[] path) {
	//char[] path;
	foreach (file; listdir(path)) {
		char[] ffile = path ~ "/" ~ file;
		if (file.length >= 4 && file[file.length - 4..file.length] != ".BIN") continue;
		writefln("%s", ffile);
		write(ffile ~ ".u",  scr_extract(cast(ubyte[])read(ffile)));
	}
}

void main() {
	//fcap_extract_all();
	
	//gpd_save_folder("extract/bg");
	//gpd_save_folder("extract/graphic");
	//gpd_save_folder("extract/sg");
	//gpd_save_folder("extract/visual");
	//gpd_save_folder("extract/system");
	
	scr_extract_all("script");
	//scr_extract_all("extract/script");
}

*/