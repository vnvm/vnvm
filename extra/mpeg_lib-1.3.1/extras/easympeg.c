/*
 * The World's Easiest MPEG Player -- a demonstration of the MPEG Library,
 * written for Silicon Graphics machines.  Demonstrates basic use of 
 * the MPEG Library, in either true-colour or colour-mapped dithering
 * modes.  Yes, it is possible to write an MPEG player in less than
 * 100 lines of code...
 *
 * Masochists may port to X (or whatever) if desired.
 *
 * By Greg Ward, 94/8/15
 *   modified for colour-mapped modes, March '95.
 */

#include <stdlib.h>
#include <errno.h>
#include <gl.h>
#define BOOLEAN_TYPE_EXISTS
#include "mpeg.h"


int main (int argc, char *argv[])
{
   FILE       *mpeg;
   ImageDesc   img;
   char       *pixels;
   Boolean     moreframes = TRUE;
   Boolean     full_color = TRUE;
   Boolean     loop = TRUE;
   
   if (argc != 2) 
   {
      fprintf (stderr, "Usage: %s mpegfile\n", argv[0]);
      exit (1);
   }

   mpeg = fopen (argv[1], "rb");
   if (!mpeg)
   {
      perror (argv[1]);
      exit (1);
   }
      
   SetMPEGOption (MPEG_DITHER, 
		  (full_color) ? (int) FULL_COLOR_DITHER : 
		                 (int) ORDERED_DITHER);
   if (!OpenMPEG (mpeg, &img))
   {
      fprintf (stderr, "OpenMPEG on %s failed\n", argv[1]);
      exit (1);
   }

   pixels = (char *) malloc (img.Size * sizeof(char));
   printf ("Movie is %d x %d pixels\n", img.Width, img.Height);
   printf ("Required picture rate = %d, required bit rate = %d\n",
	   img.PictureRate, img.BitRate);

   foreground ();
   prefsize (img.Width, img.Height);
   winopen ("Easy MPEG");
   if (full_color) RGBmode ();
   pixmode (PM_SIZE, img.PixelSize);
   pixmode (PM_TTOB, 1);
   gconfig ();
   clear ();

   if (!full_color)
   {
      int  i;

      for (i = 0; i < img.ColormapSize; i++)
      {
	 mapcolor (i, 
		   img.Colormap[i].red, 
		   img.Colormap[i].green, 
		   img.Colormap[i].blue);
      }
      gflush ();
   }
   
   while (loop)			/* play the whole movie forever */
   {
      while (moreframes)	/* play frames until the movie ends */
      {
	 moreframes = GetMPEGFrame (pixels);
	 lrectwrite (0, 0, img.Width-1, img.Height-1,
		     (unsigned long *) pixels);
      }

      RewindMPEG (mpeg, &img);
      moreframes = TRUE;
   }
}
