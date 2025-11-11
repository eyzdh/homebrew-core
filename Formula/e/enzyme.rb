class Enzyme < Formula
  desc "High-performance automatic differentiation of LLVM"
  homepage "https://enzyme.mit.edu"
  url "https://github.com/EnzymeAD/Enzyme/archive/refs/tags/v0.0.212.tar.gz"
  sha256 "79d85087228d7925dbdf65ecf61feb8cf879ec0f2bb3695432f2dacc847b9262"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/EnzymeAD/Enzyme.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "3d2480f4081f21512ccaa13515b957300f0e74616b26d73cb8d2ad54b3d6dae9"
    sha256 cellar: :any,                 arm64_sequoia: "689dd20d55ab839ac5bcbd55a6fd5679e00e3234d27be49b0bb22c2d16a5bb96"
    sha256 cellar: :any,                 arm64_sonoma:  "a4d1834284cb8d839bfb267d93d7b6d5d846436ff9eb037796a225af6a461cfb"
    sha256 cellar: :any,                 sonoma:        "ec613f3ce5a0c03af34453be81e1a834264758fb569fcda9cbba23f615a4cee6"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "86bd0df805b10796e9ea615487cc6711b812ca4290861afcc14bcb0e3af4608f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dc12554824040981fbc61538095a972ebc9550464e09e264faaf511c84e02b66"
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  def install
    system "cmake", "-S", "enzyme", "-B", "build", "-DLLVM_DIR=#{llvm.opt_lib}/cmake/llvm", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      extern double __enzyme_autodiff(void*, double);
      double square(double x) {
        return x * x;
      }
      double dsquare(double x) {
        return __enzyme_autodiff(square, x);
      }
      int main() {
        double i = 21.0;
        printf("square(%.0f)=%.0f, dsquare(%.0f)=%.0f\\n", i, square(i), i, dsquare(i));
      }
    C

    ENV["CC"] = llvm.opt_bin/"clang"

    system ENV.cc, testpath/"test.c",
                        "-fplugin=#{lib/shared_library("ClangEnzyme-#{llvm.version.major}")}",
                        "-O1", "-o", "test"

    assert_equal "square(21)=441, dsquare(21)=42\n", shell_output("./test")
  end
end
