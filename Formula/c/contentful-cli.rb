class ContentfulCli < Formula
  desc "Contentful command-line tools"
  homepage "https://github.com/contentful/contentful-cli"
  url "https://registry.npmjs.org/contentful-cli/-/contentful-cli-3.10.0.tgz"
  sha256 "c18cad715a81d1d61aaed1da08355813ab2239c21e51feb8c22763c8503a0db6"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1aeca81a779c32da50559836ad11d676164802edfcdd3089ed572651dcb93027"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1aeca81a779c32da50559836ad11d676164802edfcdd3089ed572651dcb93027"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "1aeca81a779c32da50559836ad11d676164802edfcdd3089ed572651dcb93027"
    sha256 cellar: :any_skip_relocation, sonoma:        "1aeca81a779c32da50559836ad11d676164802edfcdd3089ed572651dcb93027"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "1aeca81a779c32da50559836ad11d676164802edfcdd3089ed572651dcb93027"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "176a9bbc9e92436906935f142fd159e9c4ee97c7dd39ce9d61ecda6cf170cdfe"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    output = shell_output("#{bin}/contentful space list 2>&1", 1)
    assert_match "🚨  Error: You have to be logged in to do this.", output
    assert_match "You can log in via contentful login", output
    assert_match "Or provide a management token via --management-token argument", output
  end
end
