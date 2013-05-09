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

    it "tells you the site got added" do

      stuffed("add alexmarchant.com", @tempfile.path).should == "Successfully added alexmarchant.com\n"

    end

    it "tells you if the site already added" do

      stuffed("add alexmarchant.com", @tempfile.path)
      stuffed("add alexmarchant.com", @tempfile.path).should == "alexmarchant.com is already being blocked.\n"

    end
    
    it "tells the user to use sudo if priveledges are insufficient to modify hosts" do

      File.chmod 0007, @tempfile
      
      stuffed("add alexmarchant.com", @tempfile.path).should == "Use 'sudo stuffed <task>'\n"

    end
  end

  describe "#remove" do

    it "gives an error if no command is passed" do

      stuffed("remove", @tempfile.path).should == "Which site do you want to remove from the blocked list\n"

    end
    
    it "tells you the site got removed" do

      stuffed("add alexmarchant.com", @tempfile.path)
      stuffed("remove alexmarchant.com", @tempfile.path).should == "Successfully removed alexmarchant.com.\n"

    end

    it "tells you if the site is not available to remove" do

      stuffed("remove alexmarchant.com", @tempfile.path).should == "alexmarchant.com is not currently being blocked.\n"

    end

    it "tells the user to use sudo if priveledges are insufficient to modify hosts" do

      File.chmod 0007, @tempfile
      
      stuffed("remove alexmarchant.com", @tempfile.path).should == "Use 'sudo stuffed <task>'\n"

    end
  end

  describe "#list" do

    it "lists all blocked sites" do

      stuffed("add alexmarchant.com", @tempfile.path)
      stuffed("list", @tempfile.path).should == "Blocked sites:\nalexmarchant.com\nwww.alexmarchant.com\n"

    end

    context "when the list is empty" do

      it "says the list is empty" do

        stuffed("list", @tempfile.path).should == "You aren't currently blocking any sites.\n"

      end
    end
  end

  describe "#on" do

    it "gives feedback" do

      stuffed("on", @tempfile.path).should == "Sites are now being stuffed.\n"

    end

    it "tells the user to use sudo if priveledges are insufficient to modify hosts" do

      File.chmod 0007, @tempfile
      
      stuffed("remove alexmarchant.com", @tempfile.path).should == "Use 'sudo stuffed <task>'\n"

    end
  end

  describe "#off" do

    it "gives a status message" do

      stuffed("off", @tempfile.path).should == "Blocking has been temporarily turned off.\n"

    end

    it "tells the user to use sudo if priveledges are insufficient to modify hosts" do

      File.chmod 0007, @tempfile
      
      stuffed("remove alexmarchant.com", @tempfile.path).should == "Use 'sudo stuffed <task>'\n"

    end
  end
end
