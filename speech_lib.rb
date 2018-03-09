require 'net/http'
require 'uri'
require 'json'
require 'open-uri'
require 'wavefile'
include WaveFile

# Create a user ID from an audio clip. You need to do this before you can train with and/or verify audio samples.
class Recognizer

  def initialize(api_key)
    @api_key = api_key
  end

  def create_user(api_key)
    uri = URI('https://westus.api.cognitive.microsoft.com/spid/v1.0/verificationProfiles')
    uri.query = URI.encode_www_form({
    })
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = api_key
    body_params = {
      "locale":"en-us",
    }
    request.body = body_params.to_json
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    result = {}
    if response.code == "200"
      result = JSON.parse(response.body)
    else
      puts "ERROR!!!"
    end
    return result["verificationProfileId"]
  end



  #You must supply 3 audio clips from a certain list of phrases to train an ID with audio clips
  def train(pid, audio_url1, audio_url2, audio_url3)
    uri = URI('https://westus.api.cognitive.microsoft.com/spid/v1.0/verificationProfiles/' + pid + '/enroll')
    uri.query = URI.encode_www_form({
    })

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'multipart/form-data'
    request['Ocp-Apim-Subscription-Key'] = api_key
    audfile1 = convert_audio(audio_url1)
    request.body = audfile1
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end

    puts response.body #Ensure that everything went alright

    request2 = Net::HTTP::Post.new(uri.request_uri)
    request2['Content-Type'] = 'multipart/form-data'
    request2['Ocp-Apim-Subscription-Key'] = api_key
    audfile2 = convert_audio(audio_url2)
    request2.body = audfile2
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end

    puts response.body #Ensure that everything went alright
    request3 = Net::HTTP::Post.new(uri.request_uri)
    request3['Content-Type'] = 'multipart/form-data'
    request3['Ocp-Apim-Subscription-Key'] = api_key
    audfile3 = convert_audio(audio_url3)
    request3.body = audfile3
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end

    puts response.body #Ensure that everything went alright
  end


  # Once an ID has been trained with 3 audio samples, you can validate an audio clip against it with this method
  def validate(pid, sample_audio)
    uri = URI('https://westus.api.cognitive.microsoft.com/spid/v1.0/verify')
    uri.query = URI.encode_www_form({
      "verificationProfileId"=> pid
    })

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'multipart/form-data'
    request['Ocp-Apim-Subscription-Key'] = api_key
    audfile1 = convert_audio(sample_audio)
    request.body = audfile1

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    result = {}
    if response.code == "200"
      result = JSON.parse(response.body)
    else
      puts "ERROR!!!"
    end
    return result
  end


  #The Cognitive API can only process a very specific kind of audio clip (.wav, 16000 samples, mono, pcm 16)
  #This converts a .wav audio sample to the required specifications (a bit of a convoluted method involving terminal
  #calls to another Python function that I needed for the audio library). Python3 is necessary to use this.
  def convert_audio(audio_url)
    data = open(audio_url).read
    File.write('temp.wav', data)
      Writer.new("original.wav", Format.new(:mono, :pcm_16, 44100)) do |writer|
        Reader.new('temp.wav').each_buffer do |buffer|
          writer.write(buffer)
        end
      end
      `python3 resample.py`
      Writer.new("original2.wav", Format.new(:mono, :pcm_16, 16000)) do |writer|
        Reader.new('original.wav').each_buffer do |buffer|
          writer.write(buffer)
        end
      end
      audfile1 = open("original2.wav").read
      return audfile1
  end
end


# url1_sample = "https://jagathv.github.io/audio_files/houston_sample_1.wav"
# url2_sample = "https://jagathv.github.io/audio_files/houston_sample_2.wav"
# url3_sample = "https://jagathv.github.io/audio_files/houston_sample_3.wav"
# url4_sample = "https://jagathv.github.io/audio_files/houston_sample_4.wav"
#
# pid = create_user()
# train(pid, url1_sample, url2_sample, url3_sample)
# validate(pid, url4_sample)
