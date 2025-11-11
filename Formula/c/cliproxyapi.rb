class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v6.3.33.tar.gz"
  sha256 "49f4e47b83bdfb24e7532fa601222a08a7d6e21936f3a3e22e384ccb67a8d27f"
  license "MIT"

  bottle do
    sha256                               arm64_tahoe:   "dd8e3f5205346c052209abcc8d3bc896a9ac230357353795db72e9d2039751f4"
    sha256                               arm64_sequoia: "dd8e3f5205346c052209abcc8d3bc896a9ac230357353795db72e9d2039751f4"
    sha256                               arm64_sonoma:  "dd8e3f5205346c052209abcc8d3bc896a9ac230357353795db72e9d2039751f4"
    sha256 cellar: :any_skip_relocation, sonoma:        "9ced6fe3d14b0da1f104c31997d6b09885364319452cc5d2649b446b04106efe"
    sha256                               arm64_linux:   "034999bb2a8efbcca2fe284f30a459ceb69e80f9f580a3327c2679a381ce30e6"
    sha256                               x86_64_linux:  "42c2ab98e4430f10874cf7e6063eec2f5811808b676b304c5a7c8fa98166e844"
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
