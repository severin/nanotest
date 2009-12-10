module Nanotest
  extend self

  @@failures, @@errors, @@dots = [], [], []

  def assert(msg=nil, file=nil, line=nil, &block)
    file ||= caller.first.split(':')[0]
    line ||= caller.first.split(':')[1]
    unless block.call
      @@failures << "(%s:%0.3d) %s" % [file, line, msg || "assertion failed"]
      @@dots << 'F'
    else
      @@dots << '.'
    end
  rescue Exception => e
    @@errors << "(%s:%0.3d) %s" % [file, line, msg || "assertion raised error: #{e.class}: #{e.message}"]
    @@dots << 'E'  
  end

  def self.results #:nodoc:
    @@dots.join + "\n" + @@failures.join("\n") + "\n" + @@errors.join("\n")
  end

  at_exit { puts results unless results.strip.empty? }
end
