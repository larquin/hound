class CompletedFileReviewJob
  @queue = :high

  def self.perform(attributes)
    # filename
    # commit_sha
    # patch
    # payload ??
    # violations
    #   [{ line: 123, message: "WAT" }]

    build = Build.find_by!(commit_sha: attributes.fetch("commit_sha"))
    file_review = build.file_reviews.find_by!(filename: attributes.fetch("filename"))

    # save patch with file review?
    file = OpenStruct.new(
      filename: file_review.filename,
      patch: attributes.fetch("patch")
    )
    # nil is GithubApi
    commit = Commit.new(build.repo.full_github_name, build.commit_sha, nil)
    commit_file = commit_file = CommitFile.new(file, commit)

    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))

      file_review.build_violation(line, violation.fetch("message"))
    end

    file_review.save!

    # comment on violations
  end
end
