module MyIRB

  include Rubinius if defined? Rubinius

  ::RUBY_ENGINE = "ruby" unless defined? ::RUBY_ENGINE
  unless RUBY_ENGINE.frozen?
    RUBY_ENGINE.downcase!
    RUBY_ENGINE.freeze
  end

  ::RUBY_ENGINE_VERSION = const_get("#{RUBY_ENGINE.upcase}_VERSION")

  # This should be changed in other setups / operation systems.
  def ruby_binary
    @@ruby_binary ||= [ "/usr/bin/#{RUBY_ENGINE}#{RUBY_ENGINE_VERSION}",
      "/usr/bin/#{RUBY_ENGINE}#{RUBY_ENGINE_VERSION[/^\d+\.\d+/]}",
      "/usr/bin/#{RUBY_ENGINE}" ].detect do |bin|
      bin.freeze
      File.exists? bin
    end
  end

  def jruby?; RUBY_ENGINE == "jruby"; end
  def mri?;   RUBY_ENGINE == "ruby";  end
  def rbx?;   RUBY_ENGINE == "rbx";   end

  alias rubinius? rbx?

  def self.impl
    return @impl if @impl
    @impl = case RUBY_ENGINE
            when "ruby"  then "MRI"
            when "jruby" then "JRuby"
            when "rbx"   then "Rubinius"
            else RUBY_ENGINE
            end
    @impl << " " << RUBY_ENGINE_VERSION
  end

  require File.join(File.dirname(__FILE__), "engine", RUBY_ENGINE)

end