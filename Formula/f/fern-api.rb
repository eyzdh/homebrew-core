class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.115.2.tgz"
  sha256 "52b27a3df48039a4ed3ae31830ae29ea6a2ca4dad5dc6ec5fc4ae5c8cabae15c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "0abbe96f524e5ac74adbffee5f61096f2f8f330b451d32d1dce006f097cbb4ec"
  end

  depends_on "node"

  def install
    # Supress self update notifications
    inreplace "cli.cjs", "await this.nudgeUpgradeIfAvailable()", "await 0"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match '"organization": "brewtest"', (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
