#define MAX_NUM_CHANNELS 8

class Sound;

class SoundChannel { public:
	int index;
	Sound *sound;
	int length;
	unsigned int started;
	
	SoundChannel(int index);
	void unsetSound(Sound *sound = NULL);
	void setSound(Sound *sound);
	void play(int loops, int fadein_ms);
	int stop(int fadeout_ms);

	// Query status.
	int progress();
	float fprogress();
	bool playing();
	
	static SoundChannel *get(int channel);
	void gc();
};

class Sound : public RefcountObject { public:
	Mix_Chunk *chunk;

	void deleteObject() {
		delete this;
	}

	Sound();
	~Sound();
	int playing();
	int length();
	int get_memory_size();
	SoundChannel *play(int channel, int loops, int fadein_ms);
	static Sound *loadFromRW(SDL_RWops* rwops, int autorelease);
	static Sound *loadFromData(STRING data);
	static Sound *loadFromSQStream(SQStream* stream);
};

class Music : public RefcountObject { public:
	Mix_Music *handle;
	HSQOBJECT sqobject;
	
	void release();
	
	void deleteObject() {
		delete this;
	}

	Music();
	
	~Music();
	
	int play(int loops, int fadein_ms, double position);
	static int stop(int fadeout_ms);
	static int playing();
	static Music *loadFromFile(char *name);
	static Music *loadFromRW(SDL_RWops* rwops);
	static Music *loadFromSQStream(SQStream* sq);

private:
	void checkHandle(char *source);
};

static SoundChannel* channels[MAX_NUM_CHANNELS] = {NULL};

//class Sound { public:
	Sound::Sound() {
		chunk = NULL;
		//refcount = 0;
		//printf("Sound()\n"); fflush(stdout);
		refcount = 0;
	}
		
	Sound::~Sound() {
		//printf("~Sound()\n"); fflush(stdout);
		/*for (int n = 0; n < MAX_NUM_CHANNELS; n++) {
			channels[n]->unsetSound(this);
		}*/
		if (chunk != NULL) {
			Mix_FreeChunk(chunk);
			chunk = NULL;
		}
	}

	int Sound::length() { // in milliseconds
		int frequency;
		Uint16 format;
		int channels;
		int bytes_per_second;
		if (chunk != NULL) {
			Mix_QuerySpec(&frequency, &format, &channels);
			bytes_per_second = frequency * channels * (((format == AUDIO_U8) || (format == AUDIO_S8)) ? 1 : 2);
			return chunk->alen * 1000 / bytes_per_second;
		} else {
			return 0;
		}
	}
	
	int Sound::get_memory_size() {
		if (chunk != NULL) {
			return chunk->alen;
		} else {
			return 0;
		}
	}
		
	int Sound::playing() {
		int count = 0;
		for (int n = 0; n < 32; n++) if (Mix_Playing(n) && (Mix_GetChunk(n) == chunk)) count++;
		return count;
	}
		
	SoundChannel *Sound::play(int channel = -1, int loops = 1, int fadein_ms = 0) {
		SoundChannel *ch = SoundChannel::get(channel);
		ch->setSound(this);
		//printf("Playing sound at channel: %d\n", ch->index);
		
		ch->play(loops, fadein_ms);
		//Mix_PlayChannel(-1, chunk, 0);
		return ch;
	}
		
	Sound *Sound::loadFromRW(SDL_RWops* rwops, int autorelease = 1) {
		Mix_Chunk *chunk = NULL;
		
		chunk = Mix_LoadWAV_RW(rwops, autorelease);
		
		if (chunk == NULL) {
			fprintf(stderr, "Can't load sound\n");
			//return NULL;
		}

		Sound *sound = new Sound();
		sound->chunk = chunk;

		return sound;
	}

	Sound *Sound::loadFromData(STRING data) {
		return Sound::loadFromRW(SDL_RWFromConstMem(data.data, data.len), 0);
	}

	Sound *Sound::loadFromSQStream(SQStream* stream) {
		return Sound::loadFromRW(SQStream_to_RWops(stream), 1);
	}
//};

//class SoundChannel { public:
	SoundChannel::SoundChannel(int index) {
		this->index = index;
		this->sound = NULL;
		this->started = 0;
	}
	
	void SoundChannel::unsetSound(Sound *sound) {
		if (sound == NULL) {
			sound = this->sound;
		} else if (this->sound != sound) {
			return;
		}
		if (this->sound) {
			Mix_HaltChannel(index);
			this->sound->release();
			this->sound = NULL;
		}
	}
	
	void SoundChannel::setSound(Sound *sound) {
		if (sound != this->sound) {
			unsetSound();
			this->sound = sound;
			this->sound->capture();
		}
	}

	void SoundChannel::play(int loops = 1, int fadein_ms = 0) {
		if ((this->sound == NULL) || (this->sound->chunk == NULL)) return;
		this->started = SDL_GetTicks();
		//printf("Playing channel... %d\n", index);
		if (fadein_ms == 0) {
			Mix_PlayChannel(index, this->sound->chunk, loops - 1);
		} else {
			Mix_FadeInChannel(index, this->sound->chunk, loops - 1, fadein_ms);
		}
	}
	
	int SoundChannel::stop(int fadeout_ms = 0) {
		if (fadeout_ms == 0) {
			return Mix_HaltChannel(index);
		} else {
			return Mix_FadeOutChannel(index, fadeout_ms);
		}
	}

	SoundChannel *SoundChannel::get(int channel) {
		if (channel >= 0 && channel < MAX_NUM_CHANNELS) {
			return channels[channel];
		} else {
			// @TODO: Find a free channel
			return channels[MAX_NUM_CHANNELS - 1];
		}
	}
	
	bool SoundChannel::playing() {
		return (Mix_Playing(index) != 0);
	}

	int SoundChannel::progress() {
		return SDL_GetTicks() - this->started;
	}
	
	float SoundChannel::fprogress() {
		if (!playing() || (this->sound == NULL)) return 1.0;
		return (double)progress() / (double)this->sound->length();
	}
	
	void SoundChannel::gc() {
		if (!playing()) {
			unsetSound();
		}
	}
//};


//class Music : public RefcountObject { public:
	void Music::release() {
		handle = NULL;
		RefcountObject::release();
	}

	Music::Music() {
		refcount = 0;
	}
	
	Music::~Music() {
		if (handle) Mix_FreeMusic(handle);
	}
	
	int Music::play(int loops, int fadein_ms = 0, double position = 0.0) {
		if (this->handle == NULL) return 0;
		int result;
		Mix_HaltMusic();
		if (fadein_ms == 0) {
			result = Mix_PlayMusic(handle, loops - 1);
		} else {
			result = Mix_FadeInMusic(handle, loops - 1, fadein_ms);
		}
		if (position != 0.0) Mix_SetMusicPosition(position);
		return result;
	}
	
	int Music::stop(int fadeout_ms = 0) {
		return Mix_FadeOutMusic(fadeout_ms);
	}
	
	int Music::playing() {
		return Mix_PlayingMusic();
	}
	
	void Music::checkHandle(char *source) {
		if (handle == NULL) {
			fprintf(stderr, "Error loading music from '%s'\n", source);
		}
	}
	
	Music *Music::loadFromRW(SDL_RWops* rwops) {
		Music *music = new Music();
		music->handle = Mix_LoadMUS_RW(rwops);
		music->checkHandle("<unknown>");
		return music;
	}
	
	Music *Music::loadFromFile(char* fileName) {
		Music *music = new Music();
		music->handle = Mix_LoadMUS(fileName);
		music->checkHandle(fileName);
		return music;
	}
	
	Music *Music::loadFromSQStream(SQStream* sq) {
		return Music::loadFromRW(SQStream_to_RWops(sq));
	}
//};

class Audio { public:
	static bool initialized;

	static int init(int frequency) {
		if (!initialized) {
			initialized = true;
			Mix_Init(MIX_INIT_OGG | MIX_INIT_MP3 | MIX_INIT_MOD);
			printf("Audio::init(%d)\n", frequency);
			//frequency = 44100;
			//Mix_Init(MIX_INIT_OGG);
			Mix_OpenAudio(frequency, MIX_DEFAULT_FORMAT, 2, 1024);
			//Mix_AllocateChannels(MAX_NUM_CHANNELS);
			for (int n = 0; n < MAX_NUM_CHANNELS; n++) {
				if (channels[n] == NULL) channels[n] = new SoundChannel(n);
			}
			//printf("aaaaaaaa\n");
		}
		return 0;
	}

	static void gc() {
		if (!Audio::initialized) return;
		for (int n = 0; n < MAX_NUM_CHANNELS; n++) channels[n]->gc();
	}
	
	static int channelPlaying(int channel) {
		if (!Audio::initialized) return 0;
		return SoundChannel::get(channel)->playing();
	}

	static float channelProgress(int channel) {
		if (!Audio::initialized) return 1.0;
		return SoundChannel::get(channel)->fprogress();
	}

	static int channelStop(int channel, int fadeout_ms = 0) {
		if (!Audio::initialized) return 0;
		return SoundChannel::get(channel)->stop(fadeout_ms);
	}
};
bool Audio::initialized = false;