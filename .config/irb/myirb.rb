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