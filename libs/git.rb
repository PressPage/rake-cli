require 'git'

class MyGit
  @base = nil
  def initialize(dir, logger)
    @base = Git.open(dir, logger: logger)
  end
  def base
    @base
  end

  def is_branch_contains_commit(branch, commit)
    cmd = "git branch -r --contains #{commit}"
    result = %x(#{cmd})
    result.gsub('origin/', '').split("\n").include? branch
  end

end
