require 'git'

class MyGit
  @base = nil
  @logger = nil
  def initialize(owner, dir, logger)
    @base = Git.open(dir, logger: logger)
    @logger = logger
    @base.config('user.name', 'Bamboo')
    @base.config('user.email', ENV['GITHUB_MAIL'])
    set_origin(owner, File.basename(dir)) unless @base.remote('origin').url =~ /git@github.com/
  end

  def base
    @base
  end

  def set_origin(owner, repo)
    begin
      @base.remote('origin').remove
    rescue StandardError => e
      @logger.error(e.message)
    end
    @base.add_remote('origin', "#{repo}:#{owner}/#{repo}.git")
    @logger.info("added origin git@github.com:#{owner}/#{repo}.git")
  end

  def is_branch_contains_commit(branch, commit)
    cmd = "git branch -r --contains #{commit}"
    result = %x(#{cmd})
    result.gsub('origin/', '').split("\n").include? branch
  end

end
