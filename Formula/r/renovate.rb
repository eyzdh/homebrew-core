class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-42.4.0.tgz"
  sha256 "33187990d363bf21534335d0b4d4808e4ae50dfddb2415566766b908c06a9b97"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "da7fc9aacd8faa96d43c9dc57029520ad665d0afec6a1439b6faffc70fcb3a55"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e623de933f26e7917ea680235290f71f9aa02ff9ab22d5556330193537d33b7b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "02129b628c5d2c6a20c8694407943706ba957c974f799ec764c3609c4c35f00d"
    sha256 cellar: :any_skip_relocation, sonoma:        "0bea08d06e9fcc4d2d418132f7b67e961f22920ac40fa18de7a78f125b76bcdc"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "14d0f71121cfffd8082d9f39d4eae96cdb9a6d3d8fb1edb0abae743c34162430"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "503cd65f9d42a4c2121a149a311542ee332d50309d0057b4e010630c9e62c0c0"
  end

  depends_on "node@22"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
