require 'stuffed/stuff'
require 'spec_helper'
require 'tempfile'

describe Stuffed::Stuff do

  describe "#add" do

    it "adds the site to the hosts file" do

      tempfile = Tempfile.new('hosts')
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).add("alexmarchant.com")
      tempfile.open.grep(/alexmarchant.com/).length.should > 0

      tempfile.unlink

    end

    it "adds the corresponding www/no-www site to the hosts file" do

      tempfile = Tempfile.new('hosts')
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).add("alexmarchant.com")
      tempfile.open.grep(/www.alexmarchant.com/).length.should > 0

      tempfile.unlink

    end 

    context "when this entry already exists" do

      it "raises an exception" do

        tempfile = Tempfile.new('hosts')
        tempfile.close
        Stuffed::Stuff.new(tempfile.path).add("alexmarchant.com")

        lambda{Stuffed::Stuff.new(tempfile.path).add("alexmarchant.com")}.should raise_error(RuntimeError, 'alexmarchant.com is already being blocked.')

        tempfile.unlink

      end
    end

    context "when the stuffed section does not exist" do

      it "creates a stuffed section" do

        tempfile = Tempfile.new('hosts')
        tempfile.close

        Stuffed::Stuff.new(tempfile.path).add("alexmarchant.com")
        tempfile.open.grep(/# Stuffed Section/).length.should > 0

        tempfile.unlink

      end
    end
  end

  describe "#remove" do

    it "removes the site from the hosts file" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "# Stuffed Section"
      tempfile.puts "127.0.0.1       alexmarchant.com"
      tempfile.puts "127.0.0.1       www.alexmarchant.com"
      tempfile.puts "# End Stuffed Section"
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).remove("alexmarchant.com")

      open(tempfile).grep(/alexmarchant.com/).length.should == 0

      tempfile.unlink

    end

    it "removes the corresponding www/no-www site to the hosts file" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "# Stuffed Section"
      tempfile.puts "127.0.0.1       alexmarchant.com"
      tempfile.puts "127.0.0.1       www.alexmarchant.com"
      tempfile.puts "# End Stuffed Section"
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).remove("alexmarchant.com")

      open(tempfile).grep(/www.alexmarchant.com/).length.should == 0

      tempfile.unlink

    end

    it "only removes the site from the stuffed section" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "127.0.0.1       alexmarchant.com"
      tempfile.puts "127.0.0.1       www.alexmarchant.com"
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).remove("alexmarchant.com")

      open(tempfile).grep(/alexmarchant.com/).length.should > 0

      tempfile.unlink

    end

    context "when this entry does not exist" do

      it "raises an exception" do

        tempfile = Tempfile.new('hosts')
        tempfile.close

        lambda{Stuffed::Stuff.new(tempfile.path).remove("alexmarchant.com")}.should raise_error(RuntimeError, 'alexmarchant.com is not currently being blocked.')

        tempfile.unlink

      end
    end

    context "when the stuffed section exist and we removed the last entry" do

      it "removes the stuffed section" do

        tempfile = Tempfile.new('hosts')
        tempfile.puts "# Stuffed Section"
        tempfile.puts "127.0.0.1       alexmarchant.com"
        tempfile.puts "127.0.0.1       www.alexmarchant.com"
        tempfile.puts "# End Stuffed Section"
        tempfile.close

        Stuffed::Stuff.new(tempfile.path).remove("alexmarchant.com")

        open(tempfile).grep(/# Stuffed Section/).length.should == 0
        open(tempfile).grep(/# End Stuffed Section/).length.should == 0

        tempfile.unlink

      end
    end
  end

  describe "#list" do

    it "lists all blocked sites" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "# Stuffed Section"
      tempfile.puts "127.0.0.1       alexmarchant.com"
      tempfile.puts "127.0.0.1       www.alexmarchant.com"
      tempfile.puts "# End Stuffed Section"
      tempfile.close

      list = Stuffed::Stuff.new(tempfile.path).list
      list.should == "Blocked sites:\nalexmarchant.com\nwww.alexmarchant.com\n"

      tempfile.unlink
    end
  end

  describe "#on" do

    it "uncomments blocked sites" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "# Stuffed Section"
      tempfile.puts "# 127.0.0.1       alexmarchant.com"
      tempfile.puts "# 127.0.0.1       www.alexmarchant.com"
      tempfile.puts "# End Stuffed Section"
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).on
      open(tempfile).read.should == "# Stuffed Section\n127.0.0.1       alexmarchant.com\n127.0.0.1       www.alexmarchant.com\n# End Stuffed Section\n"

      tempfile.unlink

    end
  end

  describe "#off" do

    it "comments out blocked sites" do

      tempfile = Tempfile.new('hosts')
      tempfile.puts "# Stuffed Section"
      tempfile.puts "127.0.0.1       alexmarchant.com"
      tempfile.puts "127.0.0.1       www.alexmarchant.com"
      tempfile.puts "# End Stuffed Section"
      tempfile.close

      Stuffed::Stuff.new(tempfile.path).off
      open(tempfile).read.should == "# Stuffed Section\n# 127.0.0.1       alexmarchant.com\n# 127.0.0.1       www.alexmarchant.com\n# End Stuffed Section\n"

      tempfile.unlink

    end
  end
end

