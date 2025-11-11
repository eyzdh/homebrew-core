class Envd < Formula
  desc "Reproducible development environment for AI/ML"
  homepage "https://envd.tensorchord.ai"
  url "https://github.com/tensorchord/envd/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "564085e5ac8b97ada2d5474b0596a32f16cee9767551572f1289b85fe54aa338"
  license "Apache-2.0"
  head "https://github.com/tensorchord/envd.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c73f6bc28e2a234238967ff373f260a7154b9afbde6994456574133f078c9877"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e8d5c9eb1af7357d9e07dd467e18824d67b0583069261d6024489b6d295e112f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8eb275bf88c2af3d27600ce0e7fa6af85ca5ccbd8ec6281aba42ff2308b1cf7d"
    sha256 cellar: :any_skip_relocation, sonoma:        "b9ba655aa11cf1846bc4055d29930bdfcd160a1838dc8c9b66c709953c2af81d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7020fa27eedab1a16a6576ce22b0824f908e3b9d4eb2732d34258ec8c123848e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "642a6dc54b1622f1e660265beee50dc374a24edb4ef135d81dfd29acf043b143"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/tensorchord/envd/pkg/version.buildDate=#{time.iso8601}
      -X github.com/tensorchord/envd/pkg/version.version=#{version}
      -X github.com/tensorchord/envd/pkg/version.gitTag=v#{version}
      -X github.com/tensorchord/envd/pkg/version.gitCommit=#{tap.user}
      -X github.com/tensorchord/envd/pkg/version.gitTreeState=clean
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/envd"
    generate_completions_from_executable(bin/"envd", "completion", "--no-install", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/envd version --short")

    ENV["DOCKER_HOST"] = "unix://#{testpath}/invalid.sock"
    expected = /failed to list containers: (Cannot|permission denied while trying to) connect to the Docker daemon/
    assert_match expected, shell_output("#{bin}/envd env list 2>&1", 1)
  end
end
