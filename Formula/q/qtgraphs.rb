class Qtgraphs < Formula
  desc "Provides functionality for 2D and 3D graphs"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtgraphs-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtgraphs-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtgraphs-everywhere-src-6.10.0.tar.xz"
  sha256 "6ec8f1b3b3bea6636da8846353e170794c76d5833fc908016f911647a6a714ea"
  license all_of: [
    "GPL-3.0-only",
    "BSD-3-Clause", # *.cmake
  ]
  head "https://code.qt.io/qt/qtgraphs.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "qtquick3d"

  on_macos do
    depends_on "qtshadertools"
  end

  # TODO: preserve_rpath # https://github.com/orgs/Homebrew/discussions/2823

  def install
    args = []
    if OS.mac?
      args << "-DQT_EXTRA_RPATHS=#{(HOMEBREW_PREFIX/"lib").relative_path_from(lib)}"
      args << "-DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON"
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args(find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS Graphs)
      qt_standard_project_setup()
      qt_add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::Graphs)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += graphs
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QLineSeries>

      int main(void) {
        QLineSeries series;
        series.append(QList<QPointF>());
        series.append(0.0,0.0);
        series.append(QPointF());
        return 0;
      }
    CPP

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "cmake", "-S", ".", "-B", "cmake", "-DCMAKE_BUILD_RPATH=#{HOMEBREW_PREFIX}/lib"
    system "cmake", "--build", "cmake"
    system "./cmake/test"

    ENV.delete "CPATH" if OS.mac?
    mkdir "qmake" do
      system Formula["qtbase"].bin/"qmake", testpath/"test.pro"
      system "make"
      system "./test"
    end

    flags = shell_output("pkgconf --cflags --libs Qt6Graphs").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags, "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    system "./test"
  end
end
