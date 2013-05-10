require 'tempfile'

module Stuffed
  class Stuff

    attr_accessor :hosts_path

    def initialize(hosts_path = "/etc/hosts")
      @hosts_path = hosts_path
    end

    def add(site)

      raise "#{site} is already being blocked." if already_blocked site

      s1, s2 = site_variations(site)

      add_stuffed_section if !has_stuffed_section 

      insert_sites_into_stuffed_section s1, s2

      flush
    end

    def remove(site)

      raise "#{site} is not currently being blocked." if !already_blocked site

      s1, s2 = site_variations(site)

      remove_sites_from_stuffed_section s1, s2

      remove_stuffed_section if stuffed_section_empty?

      flush
    end

    def list
      sites = "Blocked sites:\n"

      inside_stuffed_section = false
      File.open(@hosts_path, "r").each do |line|
        inside_stuffed_section = false if line == "# End Stuffed Section\n"

        if inside_stuffed_section
          site = line.gsub(/127.0.0.1\s*/,"").gsub(/# /,"")
          sites += site
        end

        inside_stuffed_section = true if line == "# Stuffed Section\n"
      end

      sites = "You aren't currently blocking any sites." if sites.gsub(/[\n,\s]/,"") == "Blockedsites:"
      sites
    end

    def on
      hosts = File.open(@hosts_path, "r")
      tempfile = Tempfile.new('hosts-copy')
      tempfile.write hosts.read
      tempfile.close
      hosts.close

      inside_stuffed_section = false
      hosts.reopen(hosts, "w")
      tempfile.reopen(tempfile, "r")
      tempfile.each_line do |line|
        inside_stuffed_section = false if line == "# End Stuffed Section\n"
        line = line.gsub("# ","") if inside_stuffed_section
        hosts.puts line
        inside_stuffed_section = true if line == "# Stuffed Section\n"
      end

      tempfile.close
      tempfile.unlink
      hosts.close

      flush
    end

    def off
      hosts = File.open(@hosts_path, "r")
      tempfile = Tempfile.new('hosts-copy')
      tempfile.write hosts.read
      tempfile.close
      hosts.close

      inside_stuffed_section = false
      hosts.reopen(hosts, "w")
      tempfile.reopen(tempfile, "r")
      tempfile.each_line do |line|
        inside_stuffed_section = false if line == "# End Stuffed Section\n"
        line = "# " + line if inside_stuffed_section
        hosts.puts line
        inside_stuffed_section = true if line == "# Stuffed Section\n"
      end

      tempfile.close
      tempfile.unlink
      hosts.close

      flush
    end

    def flush
      if os_is_mac
        if os_is_lion_or_greater
          system( "killall -HUP mDNSResponder" )
        else
          system( "dscacheutil -flushcache" )
        end
      end
    end

    private

    def already_blocked(site)
      hosts_file_contains? site
    end

    def site_variations(site)
      s1 = site
      s2 = is_www(site) ? rm_www(site) : add_www(site)
      [s1, s2]
    end

    def is_www(site)
      site =~ /www./
    end

    def add_www(site)
      "www." + site
    end

    def rm_www(site)
      site.gsub("www.","")
    end

    def has_stuffed_section
      hosts_file_contains? "# Stuffed Section"
    end

    def hosts_file_contains?(string)
      open(@hosts_path).grep(Regexp.new string).length > 0
    end

    def add_stuffed_section
      file = File.open(@hosts_path, "a")
      file.puts ""
      file.puts "# Stuffed Section"
      file.puts "# End Stuffed Section"
      file.close
    end

    def insert_sites_into_stuffed_section(s1, s2)
      hosts = File.open(@hosts_path, "r")
      tempfile = Tempfile.new('hosts-copy')
      tempfile.write hosts.read
      tempfile.close
      hosts.close

      tempfile.reopen(tempfile, "r")
      hosts.reopen(hosts, "w")
      tempfile.each_line do |line|
        hosts.puts line
        if line == "# Stuffed Section\n"
          hosts.puts "127.0.0.1       " + s1
          hosts.puts "127.0.0.1       " + s2
        end
      end

      tempfile.close
      tempfile.unlink
      hosts.close
    end

    def remove_sites_from_stuffed_section(s1, s2)
      hosts = File.open(@hosts_path, "r")
      tempfile = Tempfile.new('hosts-copy')
      tempfile.write hosts.read
      tempfile.close
      hosts.close

      tempfile.reopen(tempfile, "r")
      hosts.reopen(hosts, "w")

      outside_stuffed_section = true
      tempfile.each_line do |line|
        outside_stuffed_section = true if line == "# End Stuffed Section\n"
        if outside_stuffed_section
          hosts.puts line
        elsif !line_includes_sites?(line, s1, s2)
          hosts.puts line
        end
        outside_stuffed_section = false if line == "# Stuffed Section\n"
      end

      tempfile.close
      tempfile.unlink
      hosts.close
    end

    def line_includes_sites?(line, *args)
      args.each do |a|
        return true if line.include? a
      end
      return false
    end

    def remove_stuffed_section
      hosts = File.open(@hosts_path, "r")
      tempfile = Tempfile.new('hosts-copy')
      tempfile.write hosts.read
      tempfile.close
      hosts.close

      record = true
      hosts.reopen(hosts, "w")
      tempfile.reopen(tempfile, "r").each do |line|
        record = false if line == "# Stuffed Section\n"
        hosts.puts line if record
        record = true if line == "# End Stuffed Section\n"
      end

      tempfile.close
      tempfile.unlink
      hosts.close
    end

    def stuffed_section_empty?
      s = ""
      start = false
      File.open(@hosts_path, "r").each do |line|
        start = false if line == "# End Stuffed Section\n"
        s += line if start
        start = true if line == "# Stuffed Section\n"
      end
      s.gsub(/# Stuffed Section/,"")
      s.gsub(/# End Stuffed Section/,"")
      s.gsub(/[\n,\s]/,"")
      s == ""
    end

    def os_is_mac
      RUBY_PLATFORM.match(/darwin/) ? true : false
    end

    def os_is_lion_or_greater
      version = RUBY_PLATFORM.match(/darwin(.*)/)[1]
      major_version = version.split(".")[0]
      major_version.to_i >= 11
    end
  end
end
