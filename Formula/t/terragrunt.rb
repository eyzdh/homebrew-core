class Terragrunt < Formula
  desc "Thin wrapper for Terraform e.g. for locking state"
  homepage "https://terragrunt.gruntwork.io/"
  url "https://github.com/gruntwork-io/terragrunt/archive/refs/tags/v0.93.7.tar.gz"
  sha256 "7af39de47257b78e014b7d63968827844ce891059c215f88da101a930b162678"
  license "MIT"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b01916055f57ca5a6ee5497fc1a20f2fb59f6e0745af4ef80502d5df1f9b9bcb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b01916055f57ca5a6ee5497fc1a20f2fb59f6e0745af4ef80502d5df1f9b9bcb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b01916055f57ca5a6ee5497fc1a20f2fb59f6e0745af4ef80502d5df1f9b9bcb"
    sha256 cellar: :any_skip_relocation, sonoma:        "fd1c51f887e9a1bb3a816c858e1bad0fd56641b1c97c2a9b15a43ba278795d18"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9fc06a9bb142d239394bd93caf5b4365dc030d2092d8dc8c8fe7ab0ca10cdc3d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f2c9f9d2be601d3368c433d6ada65610d21767062ad19a5d7da85c84c9312dd4"
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
