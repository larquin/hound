require "rails_helper"

describe StyleGuide::Scss do
  describe "#file_review" do
    it "returns an imcomplete file review" do
      file = build_file("foo")

      result = build_style_guide.file_review(file)

      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      raw_config = "config"
      repo_config = double("RepoConfig", raw_for: raw_config)
      style_guide = StyleGuide::Scss.new(repo_config, "ralph")
      file = build_file("foo")
      allow(Resque).to receive(:enqueue)

      result = style_guide.file_review(file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: file.filename,
        commit_sha: file.sha,
        patch: file.patch_body,
        payload: "",
        content: file.content,
        custom_config: raw_config,
      )
    end
  end

  describe "#file_included?" do
    context "when file is excluded" do
      it "returns false" do
        pending

        config = {
          "exclude" => "lib/**"
        }
        repo_config = double("RepoConfig", for: config)
        style_guide = StyleGuide::Scss.new(repo_config, "ralph")
        file = double("CommitFile", filename: "lib/exclude.scss")

        expect(style_guide.file_included?(file)).to eq false
      end
    end

    context "when file is included" do
      it "returns true" do
        config = {}
        repo_config = double("RepoConfig", for: config)
        style_guide = StyleGuide::Scss.new(repo_config, "ralph")
        file = double("CommitFile", filename: "application.scss")

        expect(style_guide.file_included?(file)).to eq true
      end
    end
  end

  private

  def build_style_guide(config = nil)
    repo_config = double(
      "RepoConfig",
      enabled_for?: true,
      for: config,
      raw_for: "",
    )
    repository_owner_name = "ralph"
    StyleGuide::Scss.new(repo_config, repository_owner_name)
  end

  def build_file(text)
    line = double(
      "Line",
      changed?: true,
      content: "blah",
      number: 1,
      patch_position: 2
    )
    double(
      "CommitFile",
      content: text,
      filename: "lib/a.scss",
      line_at: line,
      patch_body: "",
      sha: "abc123",
    )
  end
end
