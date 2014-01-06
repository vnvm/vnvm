extern "C" {
#include "mpeg_lib-1.3.1/util.c"
#include "mpeg_lib-1.3.1/video.c"
#include "mpeg_lib-1.3.1/parseblock.c"
#include "mpeg_lib-1.3.1/motionvector.c"
#include "mpeg_lib-1.3.1/decoders.c"
#include "mpeg_lib-1.3.1/jrevdct.c"
#include "mpeg_lib-1.3.1/wrapper.c"
#include "mpeg_lib-1.3.1/globals.c"
#include "mpeg_lib-1.3.1/24bit.c"
#include "mpeg_lib-1.3.1/gdith.c"
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

void load_and_play_file()
{
	printf("HELLO WORLD!\n");

	char *fileName = "c:/temp/angela.m1v";

   FILE       *mpeg;
   ImageDesc   img;
   char       *pixels;
   Boolean     moreframes = TRUE;
   Boolean     full_color = TRUE;
   
   printf("!!!!!!!!!!!!\n");
   
   mpeg = fopen (fileName, "rb");
   if (!mpeg)
   {
      perror (fileName);
      exit (1);
   }
   
   printf("[1]\n");
      
   SetMPEGOption(MPEG_DITHER, NO_DITHER);
   printf("[2]\n");
   
   if (!OpenMPEG (mpeg, &img))
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

	while (moreframes)	/* play frames until the movie ends */
	{
		moreframes = GetMPEGFrame (pixels);
	}
	RewindMPEG (mpeg, &img);
}
