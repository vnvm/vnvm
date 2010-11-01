using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace PrompTranslate
{
    static class Program
    {
        /// <summary>
        /// Punto de entrada principal para la aplicación.
        /// </summary>
        [STAThread]
        static int Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Form1 form = new Form1();
            Console.Out.WriteLine("Número de argumentos: {0}", args.Length);

            String inputFile = "input.txt", outputFile = "output.txt";
            String encodingName = "latin1";

            if (args.Length >= 1) inputFile = args[0];
            if (args.Length >= 2) outputFile = args[1];
            if (args.Length >= 3) encodingName = args[2];

            //form.textInput.Text = System.IO.File.ReadAllText(inputFile);

            System.Text.Encoding encoding = System.Text.Encoding.GetEncoding(encodingName);

            try { form.textInput.Text = System.IO.File.ReadAllText(inputFile, encoding).Replace("\n", "\r\n"); } catch (Exception) { }
            try { form.textOutput.Text = System.IO.File.ReadAllText(outputFile, encoding).Replace("\n", "\r\n"); } catch (Exception) { }

            Application.Run(form);

            if (form.Result == 0)
            {
                Console.Out.WriteLine("Writting '{0}'", form.OutputText);
                System.IO.File.WriteAllText(outputFile, form.OutputText.Replace("\r\n", "\n"), encoding);
            }

            Console.Out.WriteLine("Salida {0}", form.Result);

            return form.Result;
        }
    }
}
