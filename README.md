# ruby-voice-verification
A Ruby interface for easier use of MS Cognitive's Speech API

# Usage:
Instantiate a Recognizer object with your API key. Then, you can create a speech
profile using `create_user()`, train the profile with audio clips using `train()`, and
validate audio clips against a trained speech profile using `validate()`. Sample usage
is below (and in the example.rb file)

```ruby
require 'speech_lib'

api_key = ''
rec = Recognizer.new(api_key)
url1_sample = "https://jagathv.github.io/audio_files/houston_sample_1.wav"
url2_sample = "https://jagathv.github.io/audio_files/houston_sample_2.wav"
url3_sample = "https://jagathv.github.io/audio_files/houston_sample_3.wav"
url4_sample = "https://jagathv.github.io/audio_files/houston_sample_4.wav"

pid = rec.create_user()
rec.train(pid, url1_sample, url2_sample, url3_sample)
puts rec.validate(pid, url4_sample)

```
