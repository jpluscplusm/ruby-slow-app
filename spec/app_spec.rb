require File.expand_path '../spec_helper.rb', __FILE__

require "net/http"
require "uri"

describe 'Hello World app' do
  describe '/' do
    it 'returns Hello, World!' do
      get '/'

      expect(last_response).to be_ok
      expect(last_response.body).to eq("Hello, World!\n")
    end
  end

  describe '/exit' do
    let(:exit_uri) { URI.parse('http://localhost:8117/exit') }

    it 'exits cleanly' do
      Thread.new {
        sleep 1
        expect{ Net::HTTP.post_form(exit_uri, {}) }.to raise_error(EOFError)
      }
      system('rackup -p 8117')
      expect($?.success?).to be_truthy
    end
  end

  describe '/crash' do
    let(:get_uri) { URI.parse('http://localhost:8117/') }
    let(:crash_uri) { URI.parse('http://localhost:8117/crash') }

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

    it 'terminates the app when posted to' do
      response = Net::HTTP.get_response(get_uri)
      expect(response.body).to eq("Hello, World!\n")
      expect{ Net::HTTP.post_form(crash_uri, {}) }.to raise_error(EOFError)
      expect{ Net::HTTP.get_response(get_uri) }.to raise_error(Errno::ECONNREFUSED)
    end
  end
end