$:.unshift File.join(File.dirname(__FILE__), 'lib', )

require 'rubygems'
require 'rspec'
require 'pry'

module StuffedSpecHelpers

  def stuffed(args)
    out = StringIO.new
    Stuffed::CLI.new(out).parse(args.split(/\s+/))
    out.rewind
    out.read
  rescue SystemExit
    out.rewind
    out.read
  end

end
