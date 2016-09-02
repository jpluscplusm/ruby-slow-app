require File.expand_path '../lib/counter.rb', __FILE__
require 'sinatra'

get '/slow' do
  $stdout.sync
  concurrent_requests = Counter::increment
  $stdout.puts "Requests in flight: #{concurrent_requests}"

  delay = params.fetch('delay').to_i
  sleep delay
  Counter::decrement
  'I slept!'
end