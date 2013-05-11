require 'tempfile'

module Stuffed
  class Stuff

    attr_accessor :hosts_path

    def initialize(hosts_path = "/etc/hosts")
      @hosts_path = hosts_path
      @on_state = is_stuffed_on?
    end

    def add(site)

      raise "#{site} is already being blocked." if already_blocked site

      s1, s2 = site_variations site

      add_block_section if !has_block_list?

      insert_sites_into_block_list s1, s2

      flush
    end

    def remove(site)

      raise "#{site} is not currently being blocked." if !already_blocked(site) || !has_block_list?

      s1, s2 = site_variations(site)

      remove_sites_from_block_list s1, s2

      remove_block_section if stuffed_section_empty?

      flush
    end

    def list
      if stuffed_section_empty?
        "You aren't currently blocking any sites."
      else
        sites = get_block_list.split("\n")

        address = @on_state ? "# 127.0.0.1       " : "127.0.0.1       "

        sites.map! do |site|
          site.sub address, ""
        end

        "Blocked sites:\n" + sites.join("\n") + "\n"
      end
    end

    def on
      if !stuffed_section_empty?
        block_list = get_block_list
        block_list.gsub! /# /, ""
        rewrite_block_list block_list

        flush
      end
    end

    def off
      if @on_state || !stuffed_section_empty?
        block_list = get_block_list
        sites = block_list.split "\n"
        sites.map! do |site|
          site.include?("#") ? site : "# " + site
        end

        rewrite_block_list(sites.join("\n") + "\n")

        flush
      end
    end

    def flush
      if os_is_mac?
        if os_is_lion_or_greater?
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
      site.gsub "www.", ""
    end

    def has_block_list?
      hosts_file_contains? "# Stuffed Section"
    end

    def hosts_file_contains?(string)
      open(@hosts_path).grep(Regexp.new string).length > 0
    end

    def add_block_section
      file = File.open(@hosts_path, "a")
      file.puts ""
      file.puts "# Stuffed Section"
      file.puts "# End Stuffed Section"
      file.close
    end

    def remove_block_section
      top = get_top_text
      top.sub! "# Stuffed Section\n", ""
      bottom = get_bottom_text
      bottom.sub! "# End Stuffed Section\n", ""

      File.open(@hosts_path, "w") do |file|
        file.write top
        file.write bottom
      end
    end

    def insert_sites_into_block_list(s1, s2)
      address = @on_state ? "# 127.0.0.1       " : "127.0.0.1       "
      add_to_block_list(address + s1 + "\n")
      add_to_block_list(address + s2 + "\n")
    end

    def is_stuffed_on?
      if has_block_list?
        get_block_list.include? "#"
      end
    end

    def remove_sites_from_block_list(s1, s2)
      block_list = get_block_list
      address = @on_state ? "# 127.0.0.1       " : "127.0.0.1       "
      remove_from_block_list(address + s1 + "\n")
      remove_from_block_list(address + s2 + "\n")
    end

    def add_to_block_list(string)
      block_list = get_block_list
      block_list += string
      rewrite_block_list block_list
    end

    def remove_from_block_list(string)
      block_list = get_block_list
      block_list.sub! string, ""
      rewrite_block_list block_list
    end

    def get_top_text
      text = File.read(@hosts_path)
      if toptext = text.match(/.*# Stuffed Section\n/m)
        toptext[0]
      else
        ""
      end
    end

    def get_bottom_text
      text = File.read(@hosts_path)
      if toptext = text.match(/# End Stuffed Section\n.*/m)
        toptext[0]
      else
        ""
      end
    end

    def get_block_list
      text = File.read(@hosts_path)
      text.gsub! /.*# Stuffed Section\n/m, ""
      text.gsub! /# End Stuffed Section\n.*/m, ""
      text
    end

    def rewrite_block_list(string)
      top_text = get_top_text
      bottom_text = get_bottom_text
      File.open(@hosts_path, "w") do |file|
        file.write top_text
        file.write string
        file.write bottom_text
      end
    end

    def line_includes_sites?(line, *args)
      args.each do |a|
        return true if line.include? a
      end
      return false
    end

    def stuffed_section_empty?
      block_list = get_block_list
      block_list.strip!
      block_list.empty?
    end

    def os_is_mac?
      RUBY_PLATFORM.match(/darwin/) ? true : false
    end

    def os_is_lion_or_greater?
      version = RUBY_PLATFORM.match(/darwin(.*)/)[1]
      major_version = version.split(".")[0]
      major_version.to_i >= 11
    end
  end
end
