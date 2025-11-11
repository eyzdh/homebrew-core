class Pedump < Formula
  desc "Dump Windows PE files using Ruby"
  homepage "https://pedump.me"
  url "https://github.com/zed-0xff/pedump/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "aadbfc49e33f0e77501ebfb5fd231ea50737918e862092feb683e3e3f522a95d"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "3ce28d732a7b725eeb43ccee3c05cab2d36cc0b680fe2a19c20a366833c1370e"
  end

  depends_on "ruby"

  conflicts_with "mono", because: "both install `pedump` binaries"

  def install
    ENV["BUNDLE_VERSION"] = "system" # Avoid installing Bundler into the keg
    ENV["GEM_HOME"] = libexec

    system "bundle", "config", "set", "without", "development", "test"
    system "bundle", "install"
    system "gem", "build", "#{name}.gemspec"
    system "gem", "install", "#{name}-#{version}.gem"

    bin.install libexec/"bin/#{name}"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pedump --version")

    resource "notepad.exe" do
      url "https://github.com/zed-0xff/pedump/raw/master/samples/notepad.exe"
      sha256 "e4dce694ba74eaa2a781f7696c44dcb54fed5aad337dac473ac8a6b77291d977"
    end

    resource("notepad.exe").stage testpath
    assert_match "2008-04-13 18:35:51", shell_output("#{bin}/pedump --pe notepad.exe")
  end
end
