extern "C" {
	#include "mpeg_lib-1.3.1/util.c"
	#include "mpeg_lib-1.3.1/video.c"
	#include "mpeg_lib-1.3.1/parseblock.c"
	#include "mpeg_lib-1.3.1/motionvector.c"
	#include "mpeg_lib-1.3.1/decoders.c"
	#include "mpeg_lib-1.3.1/jrevdct.c"
	#include "mpeg_lib-1.3.1/wrapper.c"
	#include "mpeg_lib-1.3.1/globals.c"
	#include "mpeg_lib-1.3.1/gdith.c"
	#include "mpeg_lib-1.3.1/24bit.c"
	#include "mpeg_lib-1.3.1/mpeg.h"

	/*
	#include "mpeg_lib-1.3.1/fs2.c"
	#include "mpeg_lib-1.3.1/fs2fast.c"
	#include "mpeg_lib-1.3.1/fs4.c"
	#include "mpeg_lib-1.3.1/hybrid.c"
	#include "mpeg_lib-1.3.1/hybriderr.c"
	#include "mpeg_lib-1.3.1/2x2.c"
	#include "mpeg_lib-1.3.1/gray.c"
	#include "mpeg_lib-1.3.1/mono.c"
	#include "mpeg_lib-1.3.1/ordered.c"
	#include "mpeg_lib-1.3.1/ordered2.c"
	#include "mpeg_lib-1.3.1/mb_ordered.c"
	*/
}

//int *(read)(void* context, unsigned char *buffer, int len);

#ifndef INCLUDED_haxe_io_Bytes
#include <haxe/io/Bytes.h>
#endif

int file2_file_read(FILE2* file2, unsigned char *buffer, int len)
{
	//return fread(buffer, len, 1, (FILE*)file2->context);
	return fread(buffer, 1, len, (FILE*)file2->context);
}

FILE2 file2FromFile(FILE* file)
{
	FILE2 file2 = {0};
	file2.context = file;
	file2.read = &file2_file_read;
	return file2;
}

::common::media::video::Mpeg1Native __input;

int input_file_read(FILE2* file2, unsigned char *buffer, int len)
{
	::haxe::io::Bytes bytes = __input->__read(len);
	int length = bytes->length;
	memcpy(buffer, bytes->b->Pointer(), length);
	if (length == 0) return -1;
	return length;
}

ImageDesc img = {0};
FILE2 fileMpeg2 = {0};

void game_mpeg_open(::common::media::video::Mpeg1Native input)
{
	SetMPEGOption(MPEG_DITHER, FULL_COLOR_DITHER);
	
	__input = input;
	fileMpeg2.context = NULL;
	fileMpeg2.read = input_file_read;
	
	OpenMPEG (&fileMpeg2, &img);
}

int game_mpeg_get_width() { return img.Width; }
int game_mpeg_get_height() { return img.Height; }
int game_mpeg_get_size() { return img.Size; }

int game_mpeg_decode_frame(::haxe::io::Bytes imageData)
{
	unsigned char * buffer = imageData->b->Pointer();
	int moreframes = GetMPEGFrame((char *)buffer);
	
	int width = img.Width, height = img.Height;
	int size = width * height * 4;
	for (int n = 0; n < size; n += 4)
	{
		unsigned char r = buffer[n + 0];
		unsigned char g = buffer[n + 1];
		unsigned char b = buffer[n + 2];
		unsigned char a = 0xFF;
		
		buffer[n + 0] = a;
		buffer[n + 1] = r;
		buffer[n + 2] = g;
		buffer[n + 3] = b;
	}
	
	return moreframes;
}

/*
void load_and_play_file()
{
	printf("HELLO WORLD!\n");

	const char *fileName = "c:/temp/angela.m1v";

   FILE       *fileMpeg;
   ImageDesc   img;
   char       *pixels;
   Boolean     moreframes = TRUE;
   Boolean     full_color = TRUE;
   
   printf("!!!!!!!!!!!!\n");
   
   fileMpeg = fopen (fileName, "rb");
   if (!fileMpeg)
   {
      perror (fileName);
      exit (1);
   }
   
   printf("[1]\n");
      
   //SetMPEGOption(MPEG_DITHER, NO_DITHER);
   SetMPEGOption(MPEG_DITHER, FULL_COLOR_DITHER);
   
   printf("[2]\n");
   
   FILE2 fileMpeg2 = file2FromFile(fileMpeg);
   
   if (!OpenMPEG (&fileMpeg2, &img))
   {
      printf ("OpenMPEG on %s failed\n", fileName);
      exit (1);
   }
   
   printf("[3]\n");

   pixels = (char *) malloc (img.Size * sizeof(char));
   printf ("Movie is %d x %d pixels\n", img.Width, img.Height);
   printf ("Required picture rate = %d, required bit rate = %d\n",
	   img.PictureRate, img.BitRate);

   //foreground ();
   //prefsize (img.Width, img.Height);
   //winopen ("Easy MPEG");
   //if (full_color) RGBmode ();
   //pixmode (PM_SIZE, img.PixelSize);
   //pixmode (PM_TTOB, 1);
   //gconfig ();
   //clear ();
   
	FILE* fout = fopen("c:/temp/out.bin", "wb");

	while (moreframes)
	{
		moreframes = GetMPEGFrame (pixels);
		
		fwrite(pixels, 1, img.Size, fout);
		
		break;
		printf("%d,", moreframes);
	}
	
	fclose(fout);
	//RewindMPEG (mpeg, &img);
}

int main() {
	load_and_play_file();
	return 0;
}
*/