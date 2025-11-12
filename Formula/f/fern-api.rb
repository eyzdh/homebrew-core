class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.116.0.tgz"
  sha256 "591af7924a1b9e099c801d26de0e568447d4a62b0218507eb3364ff4a87edc9c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "68a08aa4e087d5431748761faadbcd661a17115e13514622001745f8d5e081c8"
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
