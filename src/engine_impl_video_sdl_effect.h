#ifdef USE_OPENGL
	class ShaderProgram { public:
		GLuint program;
		GLuint framentShader;

		ShaderProgram() {
			framentShader = glCreateShader(GL_FRAGMENT_SHADER);
			program = glCreateProgram();
			glAttachShader(program, framentShader);
		}

		~ShaderProgram() {
			glDeleteProgram(program);
			glDeleteShader(framentShader);
		}
		
		void showErrors(GLuint shader) {
			int infologLength = 0;
			int charsWritten  = 0;
			char *infoLog;

			glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infologLength);
			if (infologLength > 0) {
				infoLog = (char *)malloc(infologLength);
				glGetShaderInfoLog(shader, infologLength, &charsWritten, infoLog);
				if (strlen(infoLog)) {
					fprintf(stderr, "ShaderProgram::showErrors('%s')\n", infoLog);
					//exit(-1);
				}
				free(infoLog);
			}
		}
		
		void setFragmentShader(char *string) {
			//printf("-- SHADER ---------------------------------------------------\n");
			//printf("%s\n", string);
			//printf("-------------------------------------------------------------\n");
			glShaderSource(framentShader, 1, (const GLchar **)&string, NULL);
			glCompileShader(framentShader);
			showErrors(framentShader);
		}
		
		void link() {
			glLinkProgram(program);
		}

		void setFragmentShaderAndLink(char *string) {
			setFragmentShader(string);
			link();
		}
		
		void use() {
			glUseProgram(program);
		}
		
		static void unuse() {
			glUseProgram(0);
		}
		
		GLint getUniformLocation(const char *name, bool warning = true) {
			GLint location = glGetUniformLocation(program, name);
			if (location == -1) {
				fprintf(stderr, "ShaderProgram::getUniformLocation('%s') -> Location doesn't not exists.\n", name);
			}
			//printf("POSITION(%d:%d)\n", getUniformLocation("image"), getUniformLocation("step"));
			return location;
		}
	};
#else
	class ShaderProgram { public:
		ShaderProgram() {
		}

		~ShaderProgram() {
		}

		void setFragmentShader(char *string) {
		}
		
		void link() {
		}

		void setFragmentShaderAndLink(char *string) {
		}
		
		void use() {
		}
		
		static void unuse() {
		}
	};
#endif

typedef enum { EVT_VOID, EVT_FLOAT, EVT_INT, EVT_BITMAP } EffectValuesType;
class EffectValues
{ public:
	char name[64];
	unsigned int location;
	ShaderProgram *shader;
	EffectValuesType type;
	int count;
	union {
		float   floats[4];
		int     ints[4];
		Bitmap *bitmaps[4];
	};

	EffectValues(ShaderProgram *shader)
	{
		this->type     = EVT_VOID;
		this->count    = 0;
		this->shader   = shader;
		sprintf(this->name, "");
		this->location = -1;
	}
	
	~EffectValues()
	{
	}
	
	void reset()
	{
	}
	
	void set_name(char *name)
	{
		//scnprintf(this->name, sizeof(this->name), "%s", name); // SECURE!
		sprintf(this->name, "%s", name); // @TODO: INSECURE!
		#ifdef USE_OPENGL
			this->location = this->shader->getUniformLocation(name);
		#endif
	}
	
	void set_vars(EffectValuesType type, int count, void *values) {
		this->type = type;
		this->count = count;
		for (int n = 0; n < count; n++) {
			switch (type) {
				case EVT_INT   : this->ints   [n] = ((int     *)values)[n]; break;
				case EVT_FLOAT : this->floats [n] = ((float   *)values)[n]; break;
				case EVT_BITMAP: this->bitmaps[n] = ((Bitmap **)values)[n]; break;
			}
			
		}
		switch (type) {
		}
	}
	
	void set_ints  (int count, int   *values) { set_vars(EVT_INT  , count, values); }
	void set_floats(int count, float *values) { set_vars(EVT_FLOAT, count, values); }
	void set_bitmaps(int count, Bitmap **values) { set_vars(EVT_BITMAP, count, values); }

	#ifdef USE_OPENGL
	void send(int& index, bool showDebugParams = false)
	{
		switch (this->type)
		{
			case EVT_INT   :
				if (showDebugParams) {
					printf("EffectParam<INTx%d>[%s:%d] = ", count, name, location);
					for (int n = 0; n < count; n++) printf((n == 0) ? "%d" : ", %d", ints[n]);
					printf("\n");
				}
				switch (this->count) {
					case 1: glUniform1iv(this->location, 1, this->ints); break;
					case 2: glUniform2iv(this->location, 1, this->ints); break;
					case 3: glUniform3iv(this->location, 1, this->ints); break;
					case 4: glUniform4iv(this->location, 1, this->ints); break;
				}
			break;
			case EVT_FLOAT :
				if (showDebugParams) {
					printf("EffectParam<FLOATx%d>[%s:%d] = ", count, name, location);
					for (int n = 0; n < count; n++) printf((n == 0) ? "%f" : ", %f", floats[n]);
					printf("\n");
				}
				switch (this->count) {
					case 1: glUniform1fv(this->location, 1, this->floats); break;
					case 2: glUniform2fv(this->location, 1, this->floats); break;
					case 3: glUniform3fv(this->location, 1, this->floats); break;
					case 4: glUniform4fv(this->location, 1, this->floats); break;
				}
			break;
			case EVT_BITMAP:
				glEnable(GL_TEXTURE_2D);
				glActiveTexture(GL_TEXTURE0 + index);
				glBindTexture(GL_TEXTURE_2D, this->bitmaps[0]->gltex);
				if (showDebugParams) {
					printf("EffectParam<TEXTURE>[%s:%d] = %d:%d\n", name, location, index, bitmaps[0]->gltex);
				}
				glUniform1iv(this->location, 1, &index);
				index++;
			break;
		}
	}
	#endif
};

class Effect : public ShaderProgram
{ public:
	char effectName[64];
	map<string, EffectValues*> uniform_values;
	
	Effect(char *effect = "")
	{
		sprintf(effectName, "%s", effect);
		ShaderProgram();
		setEffect(effect);
	}
	
	void set_vars(EffectValuesType type, char *name, int count, void *values)
	{
		EffectValues *ev = new EffectValues(this);
		ev->set_name(name);
		ev->set_vars(type, count, values);
		uniform_values.erase(ev->name);
		uniform_values[ev->name] = ev;
	}
	
	void set_i(char *name, int value) { set_vars(EVT_INT, name, 1, &value); }
	void set_f(char *name, float value) { set_vars(EVT_FLOAT, name, 1, &value); }
	void set_t(char *name, Bitmap *value) { set_vars(EVT_BITMAP, name, 1, &value); }
	
	void use() {
		ShaderProgram::use();
		bool showDebugParams = false;
		//bool showDebugParams = true;
		int index = 0;
		bool first = true;
		for (map<string, EffectValues*>::iterator i = uniform_values.begin(); i != uniform_values.end(); i++) {
			if (showDebugParams && first) printf("---  '%s' --------------------------\n", effectName);
			//i->second->set_location(i->second->name, getUniformLocation(i->second->name));
			#ifdef USE_OPENGL
				i->second->send(index, showDebugParams);
			#endif
			if (first) first = !first;
		}
		#ifdef USE_OPENGL
			glActiveTexture(GL_TEXTURE0);
		#endif
	}
	
	static void unuse()
	{
		ShaderProgram::unuse();
		#ifdef USE_OPENGL
			glActiveTexture(GL_TEXTURE0);
		#endif
	}
	
	void setEffectTransition()
	{
		setFragmentShaderAndLink((char *)"\
			uniform sampler2D image; \
			uniform sampler2D mask; \
			uniform float     step; \
			uniform bool      reverse; \
			uniform bool      blend; \
			\
			void main() { \
				float a; \
				a = texture2D(mask, gl_TexCoord[0].xy).r; \
				if (!reverse) a = 1.0 - a; \
				a = a - 1.0 + step * 2.0; \
				gl_FragColor.rgb = texture2D(image, gl_TexCoord[0].xy).rgb; \
				if (!blend && (a >= 0.0)) a = 1.0; \
				gl_FragColor.a   = clamp(a, 0.0, 1.0); \
			} \
		");
	}
	
	void setEffectInvert()
	{
		setFragmentShaderAndLink((char *)"\
			uniform sampler2D image; \
			uniform float     step; \
			uniform bool      reverse; \
			\
			void main() { \
				gl_FragColor.rgba = texture2D(image, gl_TexCoord[0].xy).rgba; \
				gl_FragColor.rgb = vec3(1.0) - gl_FragColor.rgb; \
				gl_FragColor.a   = step; \
				if (reverse) gl_FragColor.a = 1.0 - gl_FragColor.a; \
			} \
		");
	}

	void setEffectNormal()
	{
		setFragmentShaderAndLink((char *)"\
			uniform sampler2D image; \
			uniform float     step; \
			\
			void main() { \
				gl_FragColor.rgba = texture2D(image, gl_TexCoord[0].xy).rgba; \
				gl_FragColor.a   = step; \
			} \
		");
	}

	void setEffectTint()
	{
		setFragmentShaderAndLink((char *)"\
			uniform vec4 ccolor; \
			uniform sampler2D image; \
			\
			void main() { \
				gl_FragColor.rgba = ccolor.rgba; \
				gl_FragColor.a *= texture2D(image, gl_TexCoord[0].xy).r; \
			} \
		");
	}
	
	void setEffect(char *effectName = NULL)
	{
		if (effectName != NULL) {
			if (strcmp((const char *)effectName, (const char *)"normal") == 0) return setEffectNormal();
			if (strcmp((const char *)effectName, (const char *)"tint") == 0) return setEffectTint();
			if (strcmp((const char *)effectName, (const char *)"invert") == 0) return setEffectInvert();
			if (strcmp((const char *)effectName, (const char *)"transition") == 0) return setEffectTransition();
		}
		return setEffectNormal();
	}
};
