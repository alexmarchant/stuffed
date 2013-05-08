require 'stuffed/cli'
require 'spec_helper'

describe Stuffed::CLI do
  include StuffedSpecHelpers

  it "displays usage info if no command is passed" do

    stuffed("").should == <<-eos
USAGE: stuffed <task>

The stuffed tasks are:
  add <site>       Add a site to the block list
  remove <site>    Remove a site from the block list
  list             List all sites being blocked
  on               Toggle blocking on
  off              Toggle blocking off
    eos
  end

  describe "add" do

    it "gives an error if no command is passed" do

      stuffed("add").should == "Which site do you want to add to the blocked list\n"

    end
  end

  describe "remove" do

    it "gives an error if no command is passed" do

      stuffed("remove").should == "Which site do you want to remove from the blocked list\n"

    end
  end
end
