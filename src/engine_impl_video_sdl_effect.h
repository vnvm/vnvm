class ShaderProgram { public:
	GLuint program;
	GLuint framentShader;
	//static vector<ShaderProgram*> effects;

	ShaderProgram() {
		framentShader = glCreateShader(GL_FRAGMENT_SHADER);
		program = glCreateProgram();
		glAttachShader(program, framentShader);
	}

	~ShaderProgram() {
		glDeleteProgram(program);
		glDeleteShader(framentShader);
	}
	
	/*void push() {
		effects.push_back(this);
		effects.back()->use();
	}
	
	void pop() {
		if (!effects->empty()) effects.pop_back();
		if (effects->empty()) {
			ShaderProgram::unuse();
		} else {
			effects.back()->use();
		}
	}*/
	
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
				exit(-1);
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
	
	void uniform_i(char *name, int v) {
		GLint location = getUniformLocation(name);
		printf("LOCATION::%d\n", location); fflush(stdout);
		glUniform1iv(location, 1, &v);
	}

	void uniform_f(char *name, float v) {
		GLint location = getUniformLocation(name);
		glUniform1fv(location, 1, &v);
	}
	
	void uniform_t(char *name, float gltex, int index = 1) {
		glActiveTexture(GL_TEXTURE0 + index);
		glBindTexture(GL_TEXTURE_2D, gltex);
		GLint location = getUniformLocation(name);
		glUniform1iv(location, 1, &index);
	}
};

typedef enum { EVT_VOID, EVT_FLOAT, EVT_INT, EVT_BITMAP } EffectValuesType;
class EffectValues
{ public:
	char name[64];
	GLuint location;
	EffectValuesType type;
	int count;
	union {
		float   floats[4];
		int     ints[4];
		Bitmap *bitmaps[4];
	};

	EffectValues()
	{
		type     = EVT_VOID;
		count    = 0;
		sprintf(name, "");
		location = -1;
	}
	
	~EffectValues()
	{
	}
	
	void reset()
	{
	}
	
	void set_location(char *name, GLuint location)
	{
		//scnprintf(this->name, sizeof(this->name), "%s", name); // SECURE!
		sprintf(this->name, "%s", name); // @TODO: INSECURE!
		this->location = location;
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
};

class Effect : public ShaderProgram
{ public:
	char effectName[64];
	map<GLuint, EffectValues*> uniform_values;
	
	Effect(char *effect = "")
	{
		sprintf(effectName, "%s", effect);
		ShaderProgram();
		setEffect(effect);
	}
	
	void set_vars(EffectValuesType type, char *name, int count, void *values)
	{
		GLint location = getUniformLocation(name);
		if (location >= 0) {
			EffectValues *ev = new EffectValues();
			ev->set_location(name, location);
			ev->set_vars(type, count, values);
			uniform_values.erase(location);
			uniform_values[location] = ev;
		}
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
		for (map<GLuint, EffectValues*>::iterator i = uniform_values.begin(); i != uniform_values.end(); i++) {
			if (showDebugParams && first) printf("---  '%s' --------------------------\n", effectName);
			//i->second->set_location(i->second->name, getUniformLocation(i->second->name));
			i->second->send(index, showDebugParams);
			if (first) first = !first;
		}
		glActiveTexture(GL_TEXTURE0);
	}
	
	static void unuse()
	{
		ShaderProgram::unuse();
		glActiveTexture(GL_TEXTURE0);
	}
	
	void setEffectTransition()
	{
		setFragmentShaderAndLink("\
			uniform sampler2D image; \
			uniform sampler2D mask; \
			uniform float     step; \
			uniform bool      reverse; \
			\
			void main() { \
				float a; \
				a = texture2D(mask, gl_TexCoord[0].xy).r; \
				if (reverse) a = 1.0 - a; \
				a = a - 1.0 + step * 2.0; \
				gl_FragColor.rgb = texture2D(image, gl_TexCoord[0].xy).rgb; \
				gl_FragColor.a   = clamp(a, 0.0, 1.0); \
			} \
		");
	}
	
	void setEffectInvert()
	{
		setFragmentShaderAndLink("\
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
		setFragmentShaderAndLink("\
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
		setFragmentShaderAndLink("\
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
			if (strcmp(effectName, "normal") == 0) return setEffectNormal();
			if (strcmp(effectName, "tint") == 0) return setEffectTint();
			if (strcmp(effectName, "invert") == 0) return setEffectInvert();
		}
		return setEffectTransition();
	}
};
