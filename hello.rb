require 'sinatra'

get '/' do
  "Hello, World!\n"
end

post '/crash' do
  Process.kill 9, Process.pid
end