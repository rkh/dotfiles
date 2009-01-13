module MyIRB

  %w[ls cat ping wget bash].each do |cmd|
    define_method(cmd) { |*args| system "#{cmd} #{args.join ' '}" }
  end

  @@editor_mutex = Mutex.new
  @@editor       = "vi"
  @@editor_stack = []

  def editor(format = nil, default = nil, editor = nil)
    raise RuntimeError, "Does not work with JRuby" if jruby?
    @@editor_mutex.synchronize do
      default, format = format, default unless default or format.is_a? Symbol
      format ||= editor_format_for default
      editor ||= @@editor
      file = "/tmp/vi_irb.#{format}"
      while File.exists? file
        i  ||= -1
        i   += 1
        file = "/tmp/vi_irb_#{i}.#{format}"
      end
      File.write file, editor_preload(format, default)
      system "#{editor} #{file}"
      if File.exists? file
        @@editor_stack << [format, File.read(file), editor]
        result = editor_eval
        FileUtils.rm file
        result
      end
    end
  end

  def editor_preload format, object
    format == :yaml ? object.to_yaml : object
  end

  def editor_eval
    format, source = @@editor_stack.last
    case format
    when :yaml then YAML.load source
    when :rb   then Object.class_eval source
    else source
    end
  end

  def editor_format_for a_value
    return :rb unless a_value
    :yaml
  end

  def last_edit name = nil
    if name
      @@edits ||= {}
      editor(*@@edits[name])
      name_edit name
    else
      editor(*@@editor_stack[-1])
    end
  end

  def name_edit name
    @@edits ||= {}
    @@edits[name] = @@editor_stack.last
    name
  end

  ["vi", "vim", "gvim -f", "evim -f", "joe", "kate"].each do |cmd|
    eval %[
      def #{cmd[/^[^ ]*/]} format = nil, default = nil
        editor format, default, "#{cmd} 2>/dev/null"
      end
    ]
  end
  
  def gem_command *args
    cmd = mri? ? ruby_binary.gsub(/ruby(.*)$/, 'gem\1') : ruby_binary + " gem"
    args.unshift(cmd).flatten.join " "
  end

  def gem_do *args
    system gem_command(*args)
  end

end

class << ENV
  def to_yaml
    to_hash.to_yaml
  end
end

class File
  def self.write file, content
    open(file, "w") { |f| f.write content }
  end
end