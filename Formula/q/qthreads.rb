class Qthreads < Formula
  desc "Lightweight locality-aware user-level threading runtime"
  homepage "https://www.sandia.gov/qthreads/"
  url "https://github.com/sandialabs/qthreads/archive/refs/tags/1.22.tar.gz"
  sha256 "76804e730145ee26f661c0fbe3f773f2886d96cb8a72ea79666f7714403d48ad"
  license "BSD-3-Clause"
  head "https://github.com/sandialabs/qthreads.git", branch: "main"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "userguide/examples"
    doc.install "userguide"
  end

  test do
    system ENV.cc, pkgshare/"examples/hello_world.c", "-o", "hello", "-I#{include}", "-L#{lib}", "-lqthread"
    assert_equal "Hello, world!", shell_output("./hello").chomp
  end
end
