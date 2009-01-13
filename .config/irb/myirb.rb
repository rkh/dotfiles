module MyIRB

  UNABLE_TO_LOAD = []

  print "Loading Libraries: \033[1m["

  %w[
    irb/completion irb/ext/save-history
    yaml English fileutils date open-uri pp monitor
    rubygems map_by_method what_methods rush
    english/array english/inflect english/string
    english/style english/style_orm
  ].each do |lib|
    begin
      require lib
      print "\033[0;32m|"
    rescue LoadError
      UNABLE_TO_LOAD << lib
      print "\033[0;31m|"
    end
  end

  print "\033[0m\033[1m]\033[0m"
  unless UNABLE_TO_LOAD.empty?
    print "  Unable to load #{UNABLE_TO_LOAD.size} libraries. See UNABLE_TO_LOAD."
  end
  puts

  include FileUtils::Verbose

  def self.prompt
    @normal_prompt ||= {
      :AUTO_INDENT => true,
      :PROMPT_I    => in_red(impl) + in_lred(" >> "),
      :PROMPT_S    => in_red(impl) + in_lred(" %l> "),
      :PROMPT_C    => in_red(impl) + in_lred(" ?> "),
      :PROMPT_N    => in_red(impl) + in_lred(" ?> "),
      :RETURN      => in_red(impl) + in_lred(" => ") + "%s\n"
    }
  end

  def self.start
    IRB.conf[:PROMPT][:MY_PROMPT] = prompt
    IRB.conf.merge!(
      :PROMPT_MODE  => :MY_PROMPT,
      :SAVE_HISTORY => 1000,
      :HISTORY_FILE => "#{ENV['HOME']}/.irb_history_#{RUBY_ENGINE}",
      :AUTO_INDENT  => true
    )
    IRB.conf[:IRB_RC] = Proc.new { rc_procs.each { |proc| proc.call } }
  end

  def self.rc_procs
    @rc_procs ||= []
  end

  def self.when_started &block
    rc_procs << block
  end

end

include MyIRB