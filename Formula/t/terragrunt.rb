class Terragrunt < Formula
  desc "Thin wrapper for Terraform e.g. for locking state"
  homepage "https://terragrunt.gruntwork.io/"
  url "https://github.com/gruntwork-io/terragrunt/archive/refs/tags/v0.93.4.tar.gz"
  sha256 "095dea0b1cba074bbd6190f1eb308b9a9554c74c4092aade1185140525b14e40"
  license "MIT"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0c31863b66a0a472a080887a1589b51a733b3ff4fc61fd01b25e2fa26df8701d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0c31863b66a0a472a080887a1589b51a733b3ff4fc61fd01b25e2fa26df8701d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0c31863b66a0a472a080887a1589b51a733b3ff4fc61fd01b25e2fa26df8701d"
    sha256 cellar: :any_skip_relocation, sonoma:        "0c167fa3e2456fcfec8bc9b784b3ad00b1550af80b21b8e5f52a34046f6848eb"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "eaf670bd102a4f2929a0b8f3477b23de8d57481dc488dc470b335d111fc10f65"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "51e81af6859362f34eec30f2c22a6e004ab238ed9ab89333b0ce5b346025b2b2"
  end

  depends_on "go" => :build

  conflicts_with "tenv", because: "both install terragrunt binary"
  conflicts_with "tgenv", because: "tgenv symlinks terragrunt binaries"

  def install
    ldflags = %W[
      -s -w
      -X github.com/gruntwork-io/go-commons/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/terragrunt --version")
  end
end
