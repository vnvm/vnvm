namespace PrompTranslate
{
    partial class Form1
    {
        /// <summary>
        /// Variable del diseñador requerida.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpiar los recursos que se estén utilizando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben eliminar; false en caso contrario, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de Windows Forms

        /// <summary>
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido del método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.textInput = new System.Windows.Forms.TextBox();
            this.textOutput = new System.Windows.Forms.TextBox();
            this.acceptButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // textInput
            // 
            this.textInput.Font = new System.Drawing.Font("Courier New", 8F);
            this.textInput.Location = new System.Drawing.Point(12, 12);
            this.textInput.Multiline = true;
            this.textInput.Name = "textInput";
            this.textInput.ReadOnly = true;
            this.textInput.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
            this.textInput.Size = new System.Drawing.Size(380, 125);
            this.textInput.TabIndex = 0;
            this.textInput.TabStop = false;
            this.textInput.WordWrap = false;
            // 
            // textOutput
            // 
            this.textOutput.Font = new System.Drawing.Font("Courier New", 8F);
            this.textOutput.ImeMode = System.Windows.Forms.ImeMode.On;
            this.textOutput.Location = new System.Drawing.Point(398, 12);
            this.textOutput.Multiline = true;
            this.textOutput.Name = "textOutput";
            this.textOutput.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
            this.textOutput.Size = new System.Drawing.Size(380, 125);
            this.textOutput.TabIndex = 1;
            this.textOutput.WordWrap = false;
            // 
            // acceptButton
            // 
            this.acceptButton.Location = new System.Drawing.Point(560, 142);
            this.acceptButton.Name = "acceptButton";
            this.acceptButton.Size = new System.Drawing.Size(106, 23);
            this.acceptButton.TabIndex = 2;
            this.acceptButton.Text = "&Accept";
            this.acceptButton.UseVisualStyleBackColor = true;
            this.acceptButton.Click += new System.EventHandler(this.button1_Click);
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(672, 142);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(106, 23);
            this.cancelButton.TabIndex = 3;
            this.cancelButton.Text = "&Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            this.cancelButton.Click += new System.EventHandler(this.cancelButton_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(786, 175);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.acceptButton);
            this.Controls.Add(this.textOutput);
            this.Controls.Add(this.textInput);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Form1";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Translate";
            this.TopMost = true;
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button acceptButton;
        private System.Windows.Forms.Button cancelButton;
        public System.Windows.Forms.TextBox textInput;
        public System.Windows.Forms.TextBox textOutput;
    }
}

