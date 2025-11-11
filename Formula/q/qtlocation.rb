class Qtlocation < Formula
  desc "Provides C++ interfaces to retrieve location and navigational information"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtlocation-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtlocation-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtlocation-everywhere-src-6.10.0.tar.xz"
  sha256 "cbd43e87fb4b2cccd8e01e0c762f951fc3c3d6b99cd2b80d6e526120a25df800"
  license all_of: [
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
    "BSD-3-Clause", # *.cmake
  ]
  head "https://code.qt.io/qt/qtlocation.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "eyzdh/core/qtbase"
  depends_on "eyzdh/core/qtdeclarative"
  depends_on "eyzdh/core/qtpositioning"

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
      find_package(Qt6 REQUIRED COMPONENTS Location)
      qt_standard_project_setup()
      qt_add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::Location)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += location
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QGeoCoordinate>
      #include <QGeoLocation>
      #include <QPlace>
      #include <QPlaceAttribute>
      #include <QStringLiteral>

      int main(void) {
        QPlace testObj;
        testObj.setPlaceId("testId");
        QPlaceAttribute paymentMethods;
        paymentMethods.setLabel("Payment methods");
        paymentMethods.setText("Visa");
        testObj.setExtendedAttribute(QStringLiteral("paymentMethods"), paymentMethods);
        QGeoLocation loc;
        loc.setCoordinate(QGeoCoordinate(10,20));
        testObj.setLocation(loc);
        QPlace *testObjPtr = new QPlace(testObj);
        Q_ASSERT(testObjPtr != NULL);
        Q_ASSERT(*testObjPtr == testObj);
        delete testObjPtr;
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

    flags = shell_output("pkgconf --cflags --libs Qt6Location").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags, "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    system "./test"
  end
end
