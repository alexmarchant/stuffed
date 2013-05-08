require 'stuffed/cli'
require 'spec_helper'

describe Stuffed::CLI do
  include StuffedSpecHelpers

  before(:each) do
    @tempfile = Tempfile.new('hosts')
    @tempfile.close
  end

  after(:each) do
    @tempfile.unlink
  end


  it "displays usage info if no command is passed" do

    stuffed("", @tempfile.path).should == <<-eos
USAGE: stuffed <task>

The stuffed tasks are:
  add <site>       Add a site to the block list
  remove <site>    Remove a site from the block list
  list             List all sites being blocked
  on               Toggle blocking on
  off              Toggle blocking off
    eos
  end

  describe "#add" do

    it "gives an error if no command is passed" do

      stuffed("add", @tempfile.path).should == "Which site do you want to add to the blocked list\n"

    end
  end

  describe "#remove" do

    it "gives an error if no command is passed" do

      stuffed("remove", @tempfile.path).should == "Which site do you want to remove from the blocked list\n"

    end
  end

  describe "#list" do

    it "lists all blocked sites" do

      stuffed("add alexmarchant.com", @tempfile.path)
      stuffed("list", @tempfile.path).should == "alexmarchant.com\nwww.alexmarchant.com\n"

    end
  end

  describe "#on" do

    it "gives feedback" do

      stuffed("on", @tempfile.path).should == "Sites are now being stuffed.\n"

    end
  end

  describe "#off" do

    it "gives a status message" do

      stuffed("off", @tempfile.path).should == "Blocking has been temporarily turned off.\n"

    end
  end
end
