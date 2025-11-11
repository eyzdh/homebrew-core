class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v6.3.32.tar.gz"
  sha256 "c7f45369e79ae4e05f6681cea2f4d965c27d64b4cec8ed49ca4eed7caa1c979e"
  license "MIT"

  bottle do
    sha256                               arm64_tahoe:   "81babe0a81c66858ed87aa55b99fabfeb495b9d5e73f92df0a4d479054981b69"
    sha256                               arm64_sequoia: "81babe0a81c66858ed87aa55b99fabfeb495b9d5e73f92df0a4d479054981b69"
    sha256                               arm64_sonoma:  "81babe0a81c66858ed87aa55b99fabfeb495b9d5e73f92df0a4d479054981b69"
    sha256 cellar: :any_skip_relocation, sonoma:        "c49f95752bf5fb9e72795430f874eef907eaa82cb242c3518114ede7e1fcecca"
    sha256                               arm64_linux:   "edb435d428187c42a6690a450a86c51b918e5e071247811dc57f1edfe968ce66"
    sha256                               x86_64_linux:  "841e75156e2aadc0e18687e0264edbff522cfaae8cf917db87c1466dc54e420e"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.Commit=#{tap.user}
      -X main.BuildDate=#{time.iso8601}
      -X main.DefaultConfigPath=#{etc/"cliproxyapi.conf"}
    ]

    system "go", "build", *std_go_args(ldflags:), "cmd/server/main.go"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    require "pty"
    PTY.spawn(bin/"cliproxyapi", "-login", "-no-browser") do |r, _w, pid|
      sleep 5
      Process.kill "TERM", pid
      assert_match "accounts.google.com", r.read_nonblock(1024)
    end
  end
end
