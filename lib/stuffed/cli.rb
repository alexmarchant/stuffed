require 'stuffed'

module Stuffed
  class CLI

    attr_accessor :out, :args, :hosts_path

    def initialize(out = STDOUT, hosts_path = "/etc/hosts")
      @out = out
      @hosts_path = hosts_path
    end

    def parse(args = ARGV)
      @args = args
      command = @args[0]
      case command
      when "add"
        add
      when "remove"
        remove
      when "list"
        list
      when "on"
        on
      when "off"
        off
      else
        out.puts <<-eos
USAGE: stuffed <task>

The stuffed tasks are:
  add <site>       Add a site to the block list
  remove <site>    Remove a site from the block list
  list             List all sites being blocked
  on               Toggle blocking on
  off              Toggle blocking off
        eos
      end
    end

    def add
      if @args[1]
        Stuffed::Stuff.new(@hosts_path).add(@args[1])
      else
        out.puts "Which site do you want to add to the blocked list"
      end
    end

    def remove
      if @args[1]
        Stuffed::Stuff.new(@hosts_path).remove(@args[1])
      else
        out.puts "Which site do you want to remove from the blocked list"
      end
    end

    def list
      out.puts Stuffed::Stuff.new(@hosts_path).list
    end

    def on
      Stuffed::Stuff.new(@hosts_path).on
      out.puts "Sites are now being stuffed."
    end

    def off
      Stuffed::Stuff.new(@hosts_path).off
      out.puts "Blocking has been temporarily turned off."
    end
  end
end
