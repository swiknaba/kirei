# typed: true

module Process
  class Status
    sig { params(pid: Integer, flags: Integer).returns(Process::Status) }
    def self.wait(pid = -1, flags = 0); end
  end
end
