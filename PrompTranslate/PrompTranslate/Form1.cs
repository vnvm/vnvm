using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace PrompTranslate
{
    public partial class Form1 : Form
    {
        public int Result = -1;
        public String OutputText = "";

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Result = 0;
            OutputText = textOutput.Text;
            Application.Exit();
        }

        private void cancelButton_Click(object sender, EventArgs e)
        {
            Result = -1;
            Application.Exit();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            textOutput.Focus();
        }
    }
}
