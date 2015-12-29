package midi;

import midi.FastFloatBuffer;
import midi.Sequencer;

interface SoftSynth
{	
	
	// VoiceCommon contains most of the key elements of the synth:
	// Envelopes, LFOs, pitch and volume state, the buffer pointer.
	// When the synth runs write() it should update the VoiceCommon data, with a hook for the inner loop of
	// synth processing.
	
	public var common : VoiceCommon;	
	public function write():Bool;
	
}
