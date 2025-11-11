class Harsh < Formula
  desc "Habit tracking for geeks"
  homepage "https://github.com/wakatara/harsh"
  url "https://github.com/wakatara/harsh/archive/refs/tags/0.11.8.tar.gz"
  sha256 "2b860af22ef69b4a7fdf9b27670eb5fbe7891c346b7615f97fb0618182ca14db"
  license "MIT"
  head "https://github.com/wakatara/harsh.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "099a208d8b56c0e3fa36e56b56ce95e1923e77ea670681b4a103501f67e84adf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "099a208d8b56c0e3fa36e56b56ce95e1923e77ea670681b4a103501f67e84adf"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "099a208d8b56c0e3fa36e56b56ce95e1923e77ea670681b4a103501f67e84adf"
    sha256 cellar: :any_skip_relocation, sonoma:        "49cda60914be2810049d74ca30ff06e2b9af19646048e84bc3337168756acce0"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8b3f71430b61caadf2992031f75cf32573eedf10a57eb97099624bc451af452f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9f5afc22ae7e8e14a29ad9c099ba500d5297768671977ddf5fe9df3967105396"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/wakatara/harsh/cmd.version=#{version}")
  end

  test do
    assert_match "Welcome to harsh!", shell_output("#{bin}/harsh todo")
    assert_match version.to_s, shell_output("#{bin}/harsh --version")
  end
end
