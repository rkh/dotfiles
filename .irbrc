module MyIRB

  # cut down #inspect if size >= MAX_ELEMENTS
  MAX_ELEMENTS = 15

  ::RUBY_ENGINE = "ruby" unless defined? ::RUBY_ENGINE
  unless RUBY_ENGINE.frozen?
    RUBY_ENGINE.downcase!
    RUBY_ENGINE.freeze
  end

  %w[
  irb/completion irb/ext/save-history
  yaml English fileutils date open-uri pp
  rubygems map_by_method active_support
  ].each do |lib|
    begin
      require lib
    rescue LoadError
    end
  end

  include Rubinius if defined? Rubinius
  include FileUtils::Verbose

  FG_COLORS = { :black      => "\\033[0;30m", :gray      => "\\033[1;30m",
                :lgray      => "\\033[0;37m", :white     => "\\033[1;37m",
                :red        => "\\033[0;31m", :lred      => "\\033[1;31m",
                :green      => "\\033[0;32m", :lgreen    => "\\033[1;32m",
                :brown      => "\\033[0;33m", :yellow    => "\\033[1;33m",
                :blue       => "\\033[0;34m", :lblue     => "\\033[1;34m",
                :purple     => "\\033[0;35m", :lpurple   => "\\033[1;35m",
                :cyan       => "\\033[0;36m", :lcyan     => "\\033[1;36m"   }
  BG_COLORS = { :black      => "\\033[40m",   :red       => "\\033[41m",
                :green      => "\\033[42m",   :yellow    => "\\033[43m",
                :blue       => "\\033[44m",   :purple    => "\\033[45m",
                :cyan       => "\\033[46m",   :gray      => "\\033[47m"     }
  ANSI_MISC = { :reset      => "\\033[0m",    :bold      => "\\033[1m",
                :underscore => "\\033[4m",    :blink     => "\\033[5m",
                :reverse    => "\\033[7m",    :concealed => "\\033[8m"      }

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
      alias color_inspect to_s
    end
    a_string
  end

  def show_regexp(a, re)
    if (a =~ re)
      direct_output(
        in_green('"' + $`) + in_lgreen(underlined($&)) + in_green($' + '"')
      )
    else
      "no match"
    end
  end

  def self.impl
    return @impl if @impl
    @impl = case RUBY_ENGINE
            when "ruby"  then "Matz Ruby"
            when "jruby" then "JRuby"
            when "rbx"   then "Rubinius"
            else RUBY_ENGINE
            end
    @impl << " " << Object.const_get("#{RUBY_ENGINE.upcase}_VERSION")
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
    normal_prompt
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
    Object.instance_eval { include MyIRB }
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

class Array
  alias nocolor_inspect inspect
  def inspect
    if length >= MyIRB::MAX_ELEMENTS
      in_lblue("[") +
        first.inspect +
        in_lblue(", ") +
        in_lgray("... #{length-2} elements ... ") +
        in_lblue(", ") +
        last.inspect +
        in_lblue("]")
    else
      in_lblue("[") +
        (collect { |e| e.inspect }).join(in_lblue(", ")) +
        in_lblue("]")
    end
  end
end

class Hash
  alias nocolor_inspect inspect
  def inspect
    if length >= MyIRB::MAX_ELEMENTS
      in_lblue("{") +
        keys.first.inspect +
        in_lblue(" => ") +
        values.first.inspect +
        in_lblue(", ... #{length-2} elements ..., ") +
        keys.last.inspect +
        in_lblue(" => ") +
        values.last.inspect +
        in_lblue("}")
    else
      in_lblue("{") +
        (collect do |assoc|
          assoc.collect { |e| e.inspect }.join(in_lblue(" => "))
        end).join(in_lblue(", ")) +
        in_lblue("}")
    end
  end
end

class String
  alias nocolor_inspect inspect
  def inspect
    in_green nocolor_inspect
  end
end

class Symbol
  alias nocolor_inspect inspect
  def inspect
    in_lgreen nocolor_inspect
  end
end

class Numeric
  alias nocolor_inspect inspect
  def inspect
    in_purple nocolor_inspect
  end
end

class Range
  alias nocolor_inspect inspect
  def inspect
    min.inspect + in_lblue("..") + max.inspect
  end
end

if defined? Tuple
  class Tuple
    alias nocolor_inspect inspect
    def inspect
      in_lblue("<< ") +
        (collect { |e| e.inspect }).join(in_lblue(", ")) +
        in_lblue(" >>")
    end
  end
end

class Regexp
  
  alias nocolor_inspect inspect

  def inspect
    out = ""
    escaped = false
    self.nocolor_inspect.each_char do |char|
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

  def show_match(a)
    show_regexp(a, self)
  end

end

[nil, true, false].each do |obj|
  class << obj
    alias nocolor_inspect inspect
    def inspect
      in_cyan nocolor_inspect
    end
  end
end

MyIRB.start