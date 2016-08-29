require 'git'

class MyGit
  @base = nil
  def initialize(owner, dir, logger)
    @base = Git.open(dir, logger: logger)
    @base.config('user.name', 'Bamboo')
    @base.config('user.email', ENV['GITHUB_MAIL'])
    set_origin(owner, File.basename(dir)) if @base.remote('origin').url =~ /nothing/
  end

  def base
    @base
  end

  def set_origin(owner, repo)
    @base.remote('origin').remove
    @base.add_remote('origin', "git@github.com:#{owner}/#{repo}.git")
  end

  def is_branch_contains_commit(branch, commit)
    cmd = "git branch -r --contains #{commit}"
    result = %x(#{cmd})
    result.gsub('origin/', '').split("\n").include? branch
  end

end
