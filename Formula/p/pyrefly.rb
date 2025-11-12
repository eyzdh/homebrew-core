class Pyrefly < Formula
  desc "Fast type checker and IDE for Python"
  homepage "https://pyrefly.org/"
  url "https://github.com/facebook/pyrefly/archive/refs/tags/0.41.1.tar.gz"
  sha256 "2c31bb14e629c4edc06012742e197782eedcb85a3f24bdf0e25b76bdb7cf76ea"
  license "MIT"
  head "https://github.com/facebook/pyrefly.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2d04ccd96f88549e5c9d93034ef43df99c034af56c0ddc2bac76eb843bf215b8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "51a312fcf97531e514d15294438eafd80fe5268b3d2fc396899f0ac9d0cc2469"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ba5c4571dca48a2956d7dcddac54eadeda4d47c8e67c60b647e60e4e91efbb73"
    sha256 cellar: :any_skip_relocation, sonoma:        "5b8bb6d3e38e0ec36dbdd5a3635336a73c3af18343e897f21d22fa917faf5870"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "68203e6424672006b3db2c7a7008e8d5a1ff4328760faae3d87b9a1badf86dd7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "05caef4abad3cbf85a35daa133575718b75b3bf9afaf98391bf77c59a40648ce"
  end

  depends_on "rust" => :build

  def install
    # Currently uses nightly rust features. Allow our stable rust to compile
    # these unstable features to avoid needing a rustup-downloaded nightly.
    # See https://rustc-dev-guide.rust-lang.org/building/bootstrapping/what-bootstrapping-does.html#complications-of-bootstrapping
    # Remove when fixed: https://github.com/facebook/pyrefly/issues/374
    ENV["RUSTC_BOOTSTRAP"] = "1"
    # Set JEMALLOC configuration for ARM builds
    ENV["JEMALLOC_SYS_WITH_LG_PAGE"] = "16" if Hardware::CPU.arm?

    system "cargo", "install", *std_cargo_args(path: "pyrefly")
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      def hello(name: str) -> int:
          return f"Hello, {name}!"
    PYTHON

    output = shell_output("#{bin}/pyrefly check #{testpath}/test.py 2>&1", 1)
    assert_match "`str` is not assignable to declared return type `int`", output
  end
end
