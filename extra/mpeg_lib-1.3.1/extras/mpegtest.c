/*
 * mpegtest.c - decode an MPEG without displaying anything; just used
 * for benchmarking the MPEG Library.  Based on easympeg.c
 *
 * This is Unix-specific; it requires either the BSD-style getrusage()
 * system call, or the SysV/POSIX-style times() system call.
 *
 * By Greg Ward, 1995/05/27
 */

#include <config.h>

#include <stdlib.h>
#if HAVE_GETRUSAGE
# include <sys/time.h>
# include <sys/resource.h>
#else
# include <sys/types.h>
# include <sys/times.h>
# include <time.h>		/* for CLK_TCK */
#endif
#include <unistd.h>
#include <errno.h>
#include "ParseArgv.h"
#include "mpeg.h"

int   checksum;

#if (ENABLE_DITHER)
char *dither_name = NULL;
char *DitherNames [] = 
{
   "hybrid",
   "hybrid2",
   "fs4",
   "fs2",
   "fs2fast",
   "2x2",
   "gray",
   "fullcolor",
   "none",
   "ordered",
   "mono",
   "mono_threshold",
   "ordered2",
   "mbordered"
};
#define NUM_DITHER_TYPES 14
#endif  /* ENABLE_DITHER */

/*
 * Command-line options
 */
static ArgvInfo ArgTable [] = 
{
#if (ENABLE_DITHER)
   { "-dither", ARGV_STRING, NULL, (char *) &dither_name, "" },
#endif
   { "-checksum", ARGV_CONSTANT, (char *) 1, (char *) &checksum, "" },
   { NULL, ARGV_END, 0, 0, NULL }
};


void usage (char *name, char *msg)
{
#if (ENABLE_DITHER)
   fprintf (stderr, "Usage: %s [-dither <mode>] [-checksum] mpegfile\n", name);
#else
   fprintf (stderr, "Usage: %s [-checksum] mpegfile\n", name);
#endif
   if (strlen (msg) > 0)
      fprintf (stderr, "%s\n", msg);
   
   exit (1);
}   


/* ----------------------------- MNI Header -----------------------------------
@NAME       : SearchStringTable
@INPUT      : s - string to search for
              Table - table of strings in which to search
	      TableSize - number of strings in Table[]
	      MinUniqueLen - the minimum length, over all strings in
                             the table, required to determine uniqueness
	      ErrMsg - a format string for fprintf to print if s is not
	               found in Table.  ErrMsg should contain two instances
		       of "%s"; the first will be replaced with either 
		       "ambiguous" or "unknown" (depending on the nature
		       of the error), and the second will be replaced with
		       the search string s.
@OUTPUT     : 
@RETURNS    : The position of s in Table, or -1 if not found, or -2 if
              s is an ambiguous match.  Will print an error message
              (constructed from ErrMsg and s) to stderr if s not found
              in Table.
@DESCRIPTION: Searches a list of strings for a specific string.  The
              search string only has to match enough characters to be
	      non-ambiguous.
@METHOD     : (inspired by (i.e. stolen from) ParseArgv.c)
@GLOBALS    : (none)
@CALLS      : 
@CREATED    : 94/6/22, Greg Ward
@MODIFIED   : 94/7/29, GW: added MinUniqueLen arg and changed strcmp
                           to strncmp
              95/3/5, GW: finally changed so that it always finds non-
                          ambiguous matches without any help from caller
@COMMENTS   : This should be modified so that s just has to have enough
              characters to uniquely match one of the strings in Table[].
---------------------------------------------------------------------------- */
int SearchStringTable (char *s, char *Table[], int TableSize, char *ErrMsg)
{
   int	  i, match, len;

   /* Loop through the entire string table */

   match = -1;			/* indicate no match (yet) */
   len = strlen (s);
   
   for (i = 0; i < TableSize; i++) 
   {
      /* Skip to next table entry if this is definitely not a match */

      if (strncmp (s, Table [i], len) != 0)
	 continue;

      /* If we have an *exact* match, then get outta here now */

      if (Table[i][len] == (char) 0)
      {
	 match = i;
	 break;
      }
      
      /* If we found a match in a previous iteration, then it's ambiguous */
      
      if (match != -1)
      {
	 fprintf (stderr, ErrMsg, "ambiguous", s);
	 return (-2);
      }
              
      /* Otherwise record the current entry as a match. */

      match = i;
   }

   if (match == -1)
   {
      fprintf (stderr, ErrMsg, "unknown", s);
   }
   return (match);
}     /* SearchStringTable () */



int Checksum (ImageDesc *img, char *pixels)
{
   int   i;
   unsigned int   s = 0;
   
   for (i = 0; i < img->Size; i++)
   {
/*
      if (i % (img->Size/16) == 0) printf ("%02x ", (unsigned int) pixels[i]);
      if (i < 16) printf ("%02x ", (unsigned int) pixels[i]);
*/
      s += (unsigned int) pixels[i];
   }
   return s;
}   


float current_cpu_usage ()
{
#if HAVE_GETRUSAGE
   struct rusage  usage;

   getrusage (RUSAGE_SELF, &usage);
   return (float) usage.ru_utime.tv_sec + (usage.ru_utime.tv_usec / 1e6);
#else
   struct tms tms;
   
   times (&tms);
   return (float) tms.tms_utime / CLK_TCK;
#endif
}


int main (int argc, char *argv[])
{
   FILE       *mpeg;
   ImageDesc   img;
   char       *pixels;
   Boolean     moreframes = TRUE;
#if (ENABLE_DITHER)
   DitherEnum  dither_mode;
#endif
   int         num_frames;
   float       prev_time;	/* all times are in seconds */
   float       cur_time;
   float       frame_elapsed;
   float       total_time;

   if (ParseArgv (&argc, argv, ArgTable, ARGV_NO_DEFAULTS))
   {
      usage (argv[0], "");
   }

   if (argc != 2) 
   {
      usage (argv[0], "Wrong number of arguments");
   }

#if (ENABLE_DITHER)
   if (dither_name != NULL)
   {
      dither_mode = (DitherEnum)
	 SearchStringTable (dither_name, DitherNames,
			    NUM_DITHER_TYPES, "%s dithering type: %s\n");
      if (dither_mode < 0)
	 usage (argv[0], "");
   }
   else
   {
      dither_mode = FULL_COLOR_DITHER;
   }
#endif  /* ENABLE_DITHER */
   
   mpeg = fopen (argv[1], "rb");
   if (!mpeg)
   {
      perror (argv[1]);
      exit (1);
   }
      
#if (ENABLE_DITHER)
   SetMPEGOption (MPEG_DITHER, dither_mode);
#endif
   if (!OpenMPEG (mpeg, &img))
   {
      fprintf (stderr, "OpenMPEG on %s failed\n", argv[1]);
      exit (1);
   }

#if (ENABLE_DITHER)
   if (img.Colormap != NULL)	/* will images be colour-mapped? */
   {
      int  i;
      ColormapEntry *entry;
      
      printf ("Colour map:\n");
      
      for (i = 0; i < img.ColormapSize; i++)
      {
	 entry = img.Colormap + i;
	 
	 printf ("%3d: %u %u %u\n", i, 
		 (int) entry->red, 
		 (int) entry->green,
		 (int) entry->blue);
      }
   }
#endif
		 

   pixels = (char *) malloc (img.Size * sizeof(char));
   printf ("Movie is %d x %d pixels\n", img.Width, img.Height);
   printf ("Required picture rate = %d, required bit rate = %d\n",
	   img.PictureRate, img.BitRate);
#if (ENABLE_DITHER)
   printf ("Requested dithering mode = %s\n", DitherNames[dither_mode]);
#endif

   prev_time = current_cpu_usage ();
   total_time = 0.0;
   num_frames = 0;

   while (moreframes)	/* play frames until the movie ends */
   {
      moreframes = GetMPEGFrame (pixels);
      num_frames++;
      if (checksum)
      {
	 printf ("frame %d: 0x%08x\n", 
		 num_frames, Checksum (&img, pixels));
      }
      else
      {
	 putchar ('.'); fflush (stdout);
      }
	 

      cur_time = current_cpu_usage ();
      frame_elapsed = cur_time - prev_time;
      prev_time = cur_time;
/*
      printf ("time for frame %d: %g sec\n",
	      num_frames, frame_elapsed);
*/
      total_time += frame_elapsed;
   }

   /* 
    * Calling RewindMPEG() here has two purposes: 1) to assure me that a
    * former memory corruption bug is gone, and 2) to remind me that the
    * library leaks memory like a sieve when you use RewindMPEG().  Sigh.
    */
   RewindMPEG (mpeg, &img);
   CloseMPEG ();
   fclose (mpeg);
   free (pixels);

   total_time /= num_frames;
   printf ("\nAverage time per frame: %g sec ");
   if (total_time > 0)
      printf ("(%g frames/sec)\n", total_time, 1/total_time);
   else
      printf ("\n");

   return 0;
}
