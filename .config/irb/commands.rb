module MyIRB

  %w[ls cat ping wget bash].each do |cmd|
    define_method(cmd) { |*args| system "#{cmd} #{args.join ' '}" }
  end

end
