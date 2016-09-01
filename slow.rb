require 'sinatra'

get '/slow' do
  delay = params.fetch('delay').to_i
  sleep delay
  'I slept!'
end