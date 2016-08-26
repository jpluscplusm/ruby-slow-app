require 'sinatra'

get '/' do
  "Hello, World!\n"
end

get '/slow' do
  delay = params.fetch('delay').to_i
  sleep delay
  'I slept!'
end

post '/crash' do
  Process.kill 'KILL', Process.pid
end

post '/exit' do
  Process.kill 'INT', Process.pid
end
