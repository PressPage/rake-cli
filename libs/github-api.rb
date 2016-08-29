require 'github_api'

module GithubApi
  @github = Github.new oauth_token: ENV['GITHUB_TOKEN']

  def self.list_releases(owner, repo)
    @github.repos.releases.list owner, repo
  end

  def self.create_release(owner, repo, tag)
    @github.repos.releases.create owner, repo, tag,
         tag_name: tag,
         target_commitish: 'master',
         name: tag,
         body: 'Features and fixes.',
         draft: false,
         prerelease: false
  end
end
