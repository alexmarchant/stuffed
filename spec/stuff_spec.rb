require 'stuffed/stuff'
require 'spec_helper'
require 'tempfile'

describe Stuffed::Stuff do

  before(:each) do
    @tempfile = Tempfile.new('hosts')
    @tempfile.close
  end

  after(:each) do
    @tempfile.unlink
  end

  describe "#add" do

    it "adds the site to the hosts file" do

      Stuffed::Stuff.new(@tempfile.path).add("alexmarchant.com")
      @tempfile.open.grep(/alexmarchant.com/).length.should > 0

    end

    it "adds the corresponding www/no-www site to the hosts file" do

      Stuffed::Stuff.new(@tempfile.path).add("alexmarchant.com")
      @tempfile.open.grep(/www.alexmarchant.com/).length.should > 0

    end 

    context "when this entry already exists" do

      it "raises an exception" do

        Stuffed::Stuff.new(@tempfile.path).add("alexmarchant.com")
        lambda{Stuffed::Stuff.new(@tempfile.path).add("alexmarchant.com")}.should raise_error(RuntimeError, 'alexmarchant.com is already being blocked.')

      end
    end

    context "when the stuffed section does not exist" do

      it "creates a stuffed section" do

        Stuffed::Stuff.new(@tempfile.path).add("alexmarchant.com")
        @tempfile.open.grep(/# Stuffed Section/).length.should > 0

      end
    end

    context "when stuffed is off" do

      it "comments out sites before adding them" do

        @tempfile.open
        @tempfile.puts "# Stuffed Section"
        @tempfile.puts "# 127.0.0.1       alexmarchant.com"
        @tempfile.puts "# 127.0.0.1       www.alexmarchant.com"
        @tempfile.puts "# End Stuffed Section"
        @tempfile.close

        Stuffed::Stuff.new(@tempfile.path).add("facebook.com")
        @tempfile.open.grep(/facebook\.com/)[0].should == "# 127.0.0.1       facebook.com\n"

      end
    end
  end


  describe "#remove" do

    it "removes the site from the hosts file" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "127.0.0.1       alexmarchant.com"
      @tempfile.puts "127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      Stuffed::Stuff.new(@tempfile.path).remove("alexmarchant.com")
      open(@tempfile).grep(/alexmarchant.com/).length.should == 0

    end

    it "removes the corresponding www/no-www site to the hosts file" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "# 127.0.0.1       alexmarchant.com"
      @tempfile.puts "# 127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      Stuffed::Stuff.new(@tempfile.path).remove("alexmarchant.com")
      open(@tempfile).grep(/www.alexmarchant.com/).length.should == 0

    end

    it "only removes the site from the stuffed section" do

      @tempfile.open
      @tempfile.puts "127.0.0.1       alexmarchant.com"
      @tempfile.puts "127.0.0.1       www.alexmarchant.com"
      @tempfile.close

      lambda{Stuffed::Stuff.new(@tempfile.path).remove("alexmarchant.com")}.should raise_error(RuntimeError, 'alexmarchant.com is not currently being blocked.')

    end

    context "when this entry does not exist" do

      it "raises an exception" do

        lambda{Stuffed::Stuff.new(@tempfile.path).remove("alexmarchant.com")}.should raise_error(RuntimeError, 'alexmarchant.com is not currently being blocked.')

      end
    end

    context "when the stuffed section exist and we removed the last entry" do

      it "removes the stuffed section" do

        @tempfile.open
        @tempfile.puts "# Stuffed Section"
        @tempfile.puts "127.0.0.1       alexmarchant.com"
        @tempfile.puts "127.0.0.1       www.alexmarchant.com"
        @tempfile.puts "# End Stuffed Section"
        @tempfile.close

        Stuffed::Stuff.new(@tempfile.path).remove("alexmarchant.com")
        open(@tempfile).grep(/# Stuffed Section/).length.should == 0
        open(@tempfile).grep(/# End Stuffed Section/).length.should == 0

      end
    end
  end

  describe "#list" do

    it "lists all blocked sites" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "127.0.0.1       alexmarchant.com"
      @tempfile.puts "127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      list = Stuffed::Stuff.new(@tempfile.path).list
      list.should == "Blocked sites:\nalexmarchant.com\nwww.alexmarchant.com\n"

      @tempfile.unlink
    end
  end

  describe "#on" do

    it "uncomments blocked sites" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "# 127.0.0.1       alexmarchant.com"
      @tempfile.puts "# 127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      Stuffed::Stuff.new(@tempfile.path).on
      open(@tempfile).read.should == "# Stuffed Section\n127.0.0.1       alexmarchant.com\n127.0.0.1       www.alexmarchant.com\n# End Stuffed Section\n"

    end
  end

  describe "#off" do

    it "comments out blocked sites" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "127.0.0.1       alexmarchant.com"
      @tempfile.puts "127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      Stuffed::Stuff.new(@tempfile.path).off
      open(@tempfile).read.should == "# Stuffed Section\n# 127.0.0.1       alexmarchant.com\n# 127.0.0.1       www.alexmarchant.com\n# End Stuffed Section\n"

    end

    it "doesn't comment out lines a second time" do

      @tempfile.open
      @tempfile.puts "# Stuffed Section"
      @tempfile.puts "# 127.0.0.1       alexmarchant.com"
      @tempfile.puts "# 127.0.0.1       www.alexmarchant.com"
      @tempfile.puts "# End Stuffed Section"
      @tempfile.close

      Stuffed::Stuff.new(@tempfile.path).off
      open(@tempfile).read.should == "# Stuffed Section\n# 127.0.0.1       alexmarchant.com\n# 127.0.0.1       www.alexmarchant.com\n# End Stuffed Section\n"

    end
  end

  describe "#flush" do

    context "on mac" do

      context "on Lion and greater" do

        it "calls 'killall -HUP mDNSResponder'" do

          RUBY_PLATFORM = "x86_64-darwin12.2.1"
          Stuffed::Stuff.new(@tempfile.path).flush.should == "call killall -HUP mDNSResponder"

        end
      end

      context "on Snow Leapard and lower" do

        it "calls 'dscacheutil -flushcache'" do

          RUBY_PLATFORM = "x86_64-darwin10.0.0"
          Stuffed::Stuff.new(@tempfile.path).flush.should == "call dscacheutil -flushcache"

        end
      end
    end
  end
end

