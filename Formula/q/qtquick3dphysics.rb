class Qtquick3dphysics < Formula
  desc "High-level QML module adding physical simulation capabilities to Qt Quick 3D"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtquick3dphysics-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtquick3dphysics-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtquick3dphysics-everywhere-src-6.10.0.tar.xz"
  sha256 "c2b408bfe7ed9d9a7eda371dc657c623789d5086d445b242fda61bd8db054942"
  license all_of: [
    "GPL-3.0-only",
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } }, # cooker
    "BSD-3-Clause", # bundled PhysX; *.cmake
  ]
  head "https://code.qt.io/qt/qtquick3dphysics.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

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
    # https://github.com/qt/qtquick3dphysics/blob/dev/examples/quick3dphysics/simple/main.qml
    (testpath/"test.qml").write <<~QML
      import QtQuick
      import QtQuick3D
      import QtQuick3D.Helpers
      import QtQuick3D.Physics

      Window {
        width: 640
        height: 480
        visible: true

        PhysicsWorld {
          scene: viewport.scene
        }
        View3D {
          id: viewport
          anchors.fill: parent
          environment: SceneEnvironment {
            clearColor: "#d6dbdf"
            backgroundMode: SceneEnvironment.Color
          }
          PerspectiveCamera {
            position: Qt.vector3d(-200, 100, 500)
            eulerRotation: Qt.vector3d(-20, -20, 0)
            clipFar: 5000
            clipNear: 1
          }
          DirectionalLight {
            eulerRotation.x: -45
            eulerRotation.y: 45
            castsShadow: true
            brightness: 1
            shadowFactor: 50
          }
          StaticRigidBody {
            position: Qt.vector3d(0, -100, 0)
            eulerRotation: Qt.vector3d(-90, 0, 0)
            collisionShapes: PlaneShape {}
            Model {
              source: "#Rectangle"
              scale: Qt.vector3d(10, 10, 1)
              materials: PrincipledMaterial {
                baseColor: "green"
              }
              castsShadows: false
              receivesShadows: true
            }
          }
          DynamicRigidBody {
            position: Qt.vector3d(-100, 100, 0)
            collisionShapes: BoxShape {
              id: boxShape
            }
            Model {
              source: "#Cube"
              materials: PrincipledMaterial {
                baseColor: "yellow"
              }
            }
          }
        }
        Timer {
          interval: 2000
          running: true
          onTriggered: Qt.quit()
        }
      }
    QML

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux?
    system Formula["qtdeclarative"].bin/"qml", "test.qml"
  end
end
