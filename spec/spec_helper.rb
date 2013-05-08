$:.unshift File.join(File.dirname(__FILE__), 'lib', )

require 'rubygems'
require 'rspec'
require 'pry'

module StuffedSpecHelpers

  def stuffed(args, hosts_path)
    out = StringIO.new
    Stuffed::CLI.new(out, hosts_path).parse(args.split(/\s+/))
    out.rewind
    out.read
  rescue SystemExit
    out.rewind
    out.read
  end

end
