#!/usr/bin/env ruby

$: << File.dirname(__FILE__)
$root_dir = File.dirname(File.expand_path(File.dirname(__FILE__)))
%w(lib ext).each do |dir|
  $: << File.join($root_dir, dir)
end

require 'minitest'
require 'minitest/autorun'
require 'net/http'

require 'oj'

require 'agoo'

class RackHandlerTest < Minitest::Test

  class HijackHandler
    def call(env)
      puts "*** env: #{env}"
      puts "*** env['rack.hijack?']: #{env['rack.hijack?']}"
      io = env['rack.hijack'].call()
      puts "*** io: #{io}"

      # TBD check rack.hijack?
      # rack.hijack call
      # rack.hijack_io
      
      [ -1, {}, []]
    end
  end

  def test_hijack
    begin
      Agoo::Log.configure(dir: '',
			  console: true,
			  classic: true,
			  colorize: true,
			  states: {
			    INFO: false,
			    DEBUG: false,
			    connect: false,
			    request: false,
			    response: false,
			    eval: true,
			  })

      Agoo::Server.init(6471, 'root', thread_count: 1)

      handler = HijackHandler.new
      Agoo::Server.handle(:GET, "/hijack", handler)

      Agoo::Server.start()

      jack

    ensure
      Agoo.shutdown
    end
  end

  def jack
    uri = URI('http://localhost:6471/hijack')
    req = Net::HTTP::Get.new(uri)
    # Set the headers the way we want them.
    req['Accept-Encoding'] = '*'
    req['User-Agent'] = 'Ruby'
    req['Host'] = 'localhost:6471'

    res = Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
    content = res.body

    puts "*** content #{content}"

  end

  
end
