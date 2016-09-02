require File.expand_path '../spec_helper.rb', __FILE__

require "net/http"
require 'thwait'
require "uri"

describe 'running the app with rackup' do
  context 'when running on a single thread' do
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

  context 'when running on more than one thread' do
    before(:each) do
      @read_out, @write_out = IO.pipe
      @read_err, @write_err = IO.pipe
      @server = Process.spawn('rackup -s puma -O Threads=10:10 -p 8117', :out => @write_out, :err => @write_err)
      Process.detach(@server)
      sleep 1
    end

    it 'outputs concurrent request count to STDOUT' do
      begin
        threads = 2.times.collect do
          Thread.new do
            response = Net::HTTP.get_response(URI.parse('http://localhost:8117/slow?delay=5'))
            expect(response.body).to eq("I slept!")
          end
        end

        ThreadsWait.all_waits(threads)
      ensure
        Process.kill(9, @server) rescue nil
      end

      @write_out.close
      @write_err.close

      stdout = @read_out.readlines.join("\n")
      stderr = @read_err.readlines.join("\n")
      @read_out.close
      @read_err.close
      expect(stdout).to include("Requests in flight: 2")
    end

    it 'only logs 1 concurrent request when requests are serial' do
      begin
        2.times do
          response = Net::HTTP.get_response(URI.parse('http://localhost:8117/slow?delay=2'))
          expect(response.body).to eq("I slept!")
        end

      ensure
        Process.kill(9, @server) rescue nil
      end

      @write_out.close
      @write_err.close

      stdout = @read_out.readlines.join("\n")
      stderr = @read_err.readlines.join("\n")
      @read_out.close
      @read_err.close
      expect(stdout).to_not include("Requests in flight: 2")
    end
  end
end