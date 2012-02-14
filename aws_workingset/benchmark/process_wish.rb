require 'fcntl'

def process_wish(command, wish = nil, not_wish = nil, timeout = 30)
  child_in, p_in = IO.pipe
  p_out, child_stdout = IO.pipe
  p_err, child_stderr = IO.pipe
  pid = fork
  unless pid
    p_in.close
    p_out.close
    p_err.close
    $stdin.reopen(child_in)
    $stdout.reopen(child_stdout)
    $stderr.reopen(child_stderr)
    exec command
    exit 0
  end
  child_in.close
  child_stdout.close
  child_stderr.close
  p_in.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
  p_out.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
  p_err.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)

  stdout = ""
  stdout_thread = Thread.new{
    loop do
      begin
        stdout << p_out.sysread(1024).to_s
      rescue EOFError => e
        break
      end
      unless wish.nil?
        break if stdout.match wish
      end
    end
    system "kill -KILL #{pid}"
  }
  stderr = ""
  stderr_thread = Thread.new{
    loop do
      begin
        stderr << p_err.sysread(1024).to_s
      rescue EOFError => e
        break
      end
      unless not_wish.nil?
        break if stderr.match not_wish
      end
    end
    puts "killed #{pid}"
    system "kill -KILL #{pid}"
  }

  began = Time.now
  loop do
    break unless stdout_thread.join(0.1).nil?
    break unless stderr_thread.join(0.1).nil?
    break if timeout < Time.now - began
  end
  system "kill -KILL #{pid}"
  return stdout, stderr
end
