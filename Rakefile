Dir.glob('libs/*.rb').each { |lib| require_relative lib }


desc 'Update master branch, create tag and release.'
task :after_release, [:owner, :path, :commit, :release] do |_t, args|
  Dir.chdir("../#{args[:path]}") do
    logger = Logger.new(STDOUT)
    git = MyGit.new(args[:owner], Dir.pwd, logger)
    branch = :master
    opts = {}
    updated = false

    git.base.checkout(branch)
    git.base.fetch('origin', {:tags => 1, :prune => 1})
    git.base.reset_hard
    git.base.clean({:force => 1, :d => 1})

    if (git.base.revparse('HEAD') == args[:commit])
      logger.info('nothing to update')
    elsif(git.is_branch_contains_commit(branch, args[:commit]))
      git.base.reset_hard(args[:commit])
      opts[:force] = true
      logger.info("#{branch} branch will be downgrade to #{args[:commit]}")
    else
      git.base.merge(args[:commit])
      logger.info("#{args[:commit]} merged into #{branch} branch")
      updated = true
    end
    git.base.push('origin', branch, opts)
    if (updated)
      git.base.add_tag(args[:release])
      git.base.push('origin', args[:release])
      GithubApi.create_release(args[:owner], args[:path], args[:release])
    end
  end
end
