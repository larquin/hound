module StyleGuide
  class Scss < Base
    LANGUAGE = "scss"

    def file_review(file)
      Resque.enqueue(
        ScssReviewJob,
        filename: file.filename,
        commit_sha: file.sha,
        patch: file.patch_body,
        payload: "",
        content: file.content,
        custom_config: repo_config.raw_for(LANGUAGE)
      )

      FileReview.new(filename: file.filename)
    end

    def file_included?(file)
      true
    end
  end
end
