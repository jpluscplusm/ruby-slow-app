require File.expand_path '../spec_helper.rb', __FILE__

require "net/http"
require "uri"

describe 'running the app with rackup' do
  before(:each) do
    @server = fork {
      exec 'rackup -p 8117'
    }

    Process.detach(@server)

    sleep 1
  end

  after(:each) do
    Process.kill(9, @server) rescue nil
  end

  it 'only processes one request at a time' do
    Thread.new do
      response = Net::HTTP.get_response(URI.parse('http://localhost:8117/slow?delay=5'))
      expect(response.body).to eq("I slept!")
    end

    sleep 1

    beforeGet = Time.now
    response = Net::HTTP.get_response(URI.parse('http://localhost:8117/slow?delay=0'))
    afterGet = Time.now
    expect(response.body).to eq("I slept!")
    expect(afterGet - beforeGet).to be > 4
  end
end