require "octokit"

class Github 
  def self.create_pull_request(name, body, description) 

    repo = "MarchonMilwaukee/test-repo"
    ref = "heads/#{Github.slug(name)}"

    sha_of_latest_commit = Octokit.ref(repo, "heads/master").object.sha
    sha_of_base_tree = Octokit.commit(repo, sha_of_latest_commit).commit.tree.sha
    file_name = File.join("events", "#{Github.slug(name)}.md")

    blob_sha = Octokit.create_blob(repo, Base64.encode64(body), "base64")

    branch_sha = Octokit.create_ref(repo, ref, sha_of_latest_commit).object.sha

    sha_of_new_tree = Octokit.create_tree(repo, [
      {
        path: file_name,
        mode: "100644",
        type: :blob,
        sha: blob_sha,
      }
    ], base_tree: branch_sha).sha

    commit_message = "Added event: #{name}"

    sha_of_new_commit = Octokit.create_commit(repo, commit_message, sha_of_new_tree, branch_sha).sha
    updated_ref = Octokit.update_ref(repo, ref, sha_of_new_commit)
    Octokit.create_pull_request(repo, "master", Github.slug(name), "#{name}", "This is a body")
  end

  def self.slug(str) 
    str.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

end
