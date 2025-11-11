class Qtkeychain < Formula
  desc "Platform-independent Qt API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/refs/tags/0.15.0.tar.gz"
  sha256 "f4254dc8f0933b06d90672d683eab08ef770acd8336e44dfa030ce041dc2ca22"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "qtbase"

  on_linux do
    depends_on "glib"
    depends_on "libsecret"
  end

  def install
    args = %w[-DBUILD_TRANSLATIONS=OFF -DBUILD_WITH_QT6=ON]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <qt6keychain/keychain.h>
      int main() {
        QKeychain::ReadPasswordJob job(QLatin1String(""));
        return 0;
      }
    CPP
    flags = ["-I#{Formula["qtbase"].opt_include}"]
    flags += if OS.mac?
      [
        "-F#{Formula["qtbase"].opt_lib}",
        "-framework", "QtCore"
      ]
    else
      [
        "-fPIC",
        "-L#{Formula["qtbase"].opt_lib}", "-lQt6Core",
        "-Wl,-rpath,#{Formula["qtbase"].opt_lib}",
        "-Wl,-rpath,#{lib}"
      ]
    end
    system ENV.cxx, "test.cpp", "-o", "test", "-std=c++17", "-I#{include}",
                    "-L#{lib}", "-lqt6keychain", *flags
    system "./test"
  end
end
