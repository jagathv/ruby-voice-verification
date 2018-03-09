#A simple Python script to help convert audio to the Cognitive API's preferred
#format.
import librosa
import resampy

x, sr_orig = librosa.load('temp.wav', sr=None)

y_low = resampy.resample(x, sr_orig, 16000)
final_sig = librosa.to_mono(y_low)

librosa.output.write_wav('original.wav', final_sig, sr=16000)
