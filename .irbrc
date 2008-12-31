%w[
  irb/completion irb/ext/save-history
  yaml English fileutils date open-uri pp monitor
  rubygems map_by_method what_methods active_support
].each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

module MyIRB

  include Rubinius if defined? Rubinius
  include FileUtils::Verbose

  ::RUBY_ENGINE = "ruby" unless defined? ::RUBY_ENGINE
  unless RUBY_ENGINE.frozen?
    RUBY_ENGINE.downcase!
    RUBY_ENGINE.freeze
  end

  ::RUBY_ENGINE_VERSION = const_get("#{RUBY_ENGINE.upcase}_VERSION")

  # This should be changed in other setups / operation systems.
  def ruby_binary
    [ "/usr/bin/#{RUBY_ENGINE}#{RUBY_ENGINE_VERSION[/^\d+\.\d+/]}",
      "/usr/bin/#{RUBY_ENGINE}#{RUBY_ENGINE_VERSION[/^\d+\.\d+/]}",
      "/usr/bin/#{RUBY_ENGINE}"].detect do |bin|
      File.exists? bin
    end
  end

  def jruby?; RUBY_ENGINE == "jruby"; end
  def mri?;   RUBY_ENGINE == "ruby";  end
  def rbx?;   RUBY_ENGINE == "rbx";   end

  alias rubinius? rbx?

  %w[ls cat ping wget bash].each do |cmd|
    define_method(cmd) { |*args| system "#{cmd} #{args.join ' '}" }
  end

  @@color_inspect = false

  FG_COLORS = { :black      => "\033[0;30m", :gray      => "\033[1;30m",
                :lgray      => "\033[0;37m", :white     => "\033[1;37m",
                :red        => "\033[0;31m", :lred      => "\033[1;31m",
                :green      => "\033[0;32m", :lgreen    => "\033[1;32m",
                :brown      => "\033[0;33m", :yellow    => "\033[1;33m",
                :blue       => "\033[0;34m", :lblue     => "\033[1;34m",
                :purple     => "\033[0;35m", :lpurple   => "\033[1;35m",
                :cyan       => "\033[0;36m", :lcyan     => "\033[1;36m"   }
  BG_COLORS = { :black      => "\033[40m",   :red       => "\033[41m",
                :green      => "\033[42m",   :yellow    => "\033[43m",
                :blue       => "\033[44m",   :purple    => "\033[45m",
                :cyan       => "\033[46m",   :gray      => "\033[47m"     }
  ANSI_MISC = { :reset      => "\033[0m",    :bold      => "\033[1m",
                :underscore => "\033[4m",    :blink     => "\033[5m",
                :reverse    => "\033[7m",    :concealed => "\033[8m"      }

  def underlined *params
    return ANSI_MISC[:underscore] + params.join("\n") + ANSI_MISC[:reset]
  end

  FG_COLORS.each do |color, ansi|
    define_method("in_#{color}") do |*params|
      FG_COLORS[color] + params.join("\n") + ANSI_MISC[:reset]
    end
    module_function "in_#{color}"
  end

  def is_rails?
    ENV.include? 'RAILS_ENV'
  end

  module_function :is_rails?

  def direct_output(a_string)
    a_string = a_string.dup
    class << a_string
      alias inspect to_s
    end
    a_string
  end

  module_function :direct_output

  def show_regexp(a, re)
    if (a =~ re)
      direct_output(
        in_green('"' + $`) + in_lgreen(underlined($&)) + in_green($' + '"')
      )
    else
      "no match"
    end
  end

  module_function :show_regexp

  def color_inspect?
    @@color_inspect
  end

  def in_color
    (@@color_monitor ||= Monitor.new).synchronize do
      @@color_inspect = true
      yield
      @@color_inspect = false
    end
  end

  def color_inspect &block
    return if @color_inspect
    if self.is_a? Class
      @color_inspect = block
      self.class_eval do
        alias nocolor_inspect inspect
        def inspect
          block = self.class.instance_variable_get("@color_inspect")
          if color_inspect? and block
            block.call(self)
          else
            nocolor_inspect
          end
        end
      end
    else
      a_class = class << self; self; end
      a_class.color_inspect(&block)
    end
  end

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
  
  def self.normal_prompt
    @normal_prompt ||= {
      :AUTO_INDENT => true,
      :PROMPT_I    => in_red(impl) + in_lred(" >> "),
      :PROMPT_S    => in_red(impl) + in_lred(" %l> "),
      :PROMPT_C    => in_red(impl) + in_lred(" ?> "),
      :PROMPT_N    => in_red(impl) + in_lred(" ?> "),
      :RETURN      => in_red(impl) + in_lred(" => ") + "%s\n"
    }
  end

  # to be overwritten
  def self.rails_prompt
    pre = in_red(impl) + in_brown(" #{ENV['RAILS_ENV']}")
    @normal_prompt ||= {
      :AUTO_INDENT => true,
      :PROMPT_I    => pre + in_lred(" >> "),
      :PROMPT_S    => pre + in_lred(" %l> "),
      :PROMPT_C    => pre + in_lred(" ?> "),
      :PROMPT_N    => pre + in_lred(" ?> "),
      :RETURN      => pre + in_lred(" => ") + "%s\n"
    }
  end

  def self.prompt
    is_rails? ? rails_prompt : normal_prompt
  end

  def self.start
    start_normal
    start_rails if is_rails?
  end
  
  def self.rc_procs
    @rc_procs ||= []
  end

  def self.when_started &block
    rc_procs << block
  end

  def self.start_normal
    IRB.conf[:PROMPT][:MY_PROMPT] = prompt
    IRB.conf.merge!(
      :PROMPT_MODE  => :MY_PROMPT,
      :SAVE_HISTORY => 1000,
      :HISTORY_FILE => "#{ENV['HOME']}/.irb_history_#{RUBY_ENGINE}",
      :AUTO_INDENT  => true
    )
    IRB.conf[:IRB_RC] = Proc.new { rc_procs.each { |proc| proc.call } }
  end

  def self.start_rails
    when_started do
      ActiveRecord::Base.logger = Logger.new STDOUT
      ActiveRecord::Base.instance_eval { alias :[] :find }
    end
  end

end

include MyIRB

module Enumerable
  def smart_inspect(open, close, &block)
    block ||= proc { |e| e.inspect }
     if length >= 15
      in_lblue(open) +
        block.call(first).to_s +
        in_lblue(", ") +
        in_lgray("... #{length-1} elements") +
        in_lblue(close)
    else
      in_lblue(open) +
        collect(&block).join(in_lblue(", ")) +
        in_lblue(close)
    end
  end
end

# For some reasons String.color_inspect makes "foo".inspect retrun
# #<String:...> instead of "\"foo\"", same for Symbol.
if rubinius?
  class String
    alias orig_inspect inspect
    def inspect; in_green orig_inspect; end
  end
  class Symbol
    alias orig_inspect inspect
    def inspect; in_lgreen orig_inspect; end
  end
  [nil, false, true].each do |var|
    class << var
      alias orig_inspect inspect
      def inspect; in_cyan orig_inspect; end
    end
  end
else
  String.color_inspect  { |o| in_green o.nocolor_inspect  }
  Symbol.color_inspect  { |o| in_lgreen o.nocolor_inspect }
  [NilClass, TrueClass, FalseClass].each do |a_class|
    a_class.color_inspect { |o| in_cyan o.nocolor_inspect }
  end
end

Array.color_inspect   { |o| o.smart_inspect "[", "]"   }
Numeric.color_inspect { |o| in_purple o.nocolor_inspect }
Range.color_inspect   { |o| o.min.inspect + in_lblue("..") + o.max.inspect }
Tuple.color_inspect   { |o| o.smart_inspect "<< ", " >>" } if defined? Tuple

Hash.color_inspect do |o|
  o.smart_inspect "{", "}" do |element|
    element.collect { |e| e.inspect }.join in_lblue(" => ")
  end
end

Regexp.color_inspect do |o|
  out = ""
  escaped = false
  o.nocolor_inspect.each_char do |char|
    if escaped
      escaped = false
      out << in_gray(char)
    elsif char == '\\'
      escaped = true
      out << in_gray(char)
    elsif %w{* ? + [ ] ^ $ | .}.include? char
      out << in_white(ANSI_MISC[:bold] + char)
    elsif %w{/ ( )}.include? char
      out << in_yellow(ANSI_MISC[:bold] + char)
    else
      out << in_gray(char)
    end
  end
  out
end

class << ENV
  def inspect
    to_hash.inspect
  end
end

class PrettyPrint
  alias orig_text text
  def text obj, *whatever
    orig_text in_lblue(obj), *whatever
  end
end

class << PP
  alias orig_pp pp
  def pp *args
    in_color { orig_pp(*args) }
  end
end

class IRB::Irb
  alias orig_output_value output_value
  def output_value
    in_color { orig_output_value }
  end
end

MyIRB.start