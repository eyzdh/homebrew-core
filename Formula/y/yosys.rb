class Yosys < Formula
  desc "Framework for Verilog RTL synthesis"
  homepage "https://yosyshq.net/yosys/"
  url "https://github.com/YosysHQ/yosys/releases/download/v0.59/yosys.tar.gz"
  sha256 "5e80ea92d7f88a50600b57716226ea0496b8d08e4e135551862bb7f52ea391c5"
  license "ISC"
  head "https://github.com/YosysHQ/yosys.git", branch: "main"

  bottle do
    sha256 arm64_tahoe:   "91ccaf59e2dcdcbe21ab029bd28940e0f806b6792c30fae8f021ef7b0e35f1dd"
    sha256 arm64_sequoia: "c30f939715b1e0d93fd5ebb89cd2725b6677828443c545ec4bf416462828dd04"
    sha256 arm64_sonoma:  "12266e847b52c497c0e52f5f334558523826c4e3d12dcbd5ba0ad9a529f225b3"
    sha256 sonoma:        "6f0491064eb0da1366ca947c66e7bf1cd634c0be6fbb11342936b9c6fd675954"
    sha256 arm64_linux:   "3700f19bfe309751d504e86ba588408869aa9b33c4230acde620fae44dfe7a16"
    sha256 x86_64_linux:  "74680db3b1ebb33b0bd9dc1124c3daee212ccdc18ab96bc20ed55d8405db8890"
  end

  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "pkgconf" => :build
  depends_on "libtommath"
  depends_on "readline"
  depends_on "tcl-tk"

  uses_from_macos "libffi"
  uses_from_macos "python"
  uses_from_macos "zlib"

  def install
    ENV.append "LINKFLAGS", "-L#{Formula["readline"].opt_lib}"
    system "make", "install", "PREFIX=#{prefix}", "PRETTY=0"
  end

  test do
    system bin/"yosys", "-p", "hierarchy; proc; opt; techmap; opt;", "-o", "synth.v", pkgshare/"adff2dff.v"
  end
end
