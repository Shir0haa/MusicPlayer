cmake_minimum_required(VERSION 3.16)

project(
  ShirohaPlayer
  VERSION 0.1
  LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Widgets)
find_package(PkgConfig REQUIRED)
pkg_check_modules(TAGLIB REQUIRED taglib)


set(PROJECT_SOURCES
    main.cpp
    qml.qrc
    httputils.cpp
    filemetareader.cpp
    startAPIServer.cpp
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_add_executable(ShirohaPlayer MANUAL_FINALIZATION
                    ${PROJECT_SOURCES}
                    images.qrc
                    httputils.h
                    filemetareader.h
                    startAPIServer.h)
else()
  if(ANDROID)
    add_library(ShirohaPlayer SHARED ${PROJECT_SOURCES})
  else()
    add_executable(ShirohaPlayer ${PROJECT_SOURCES})
  endif()
endif()

# 添加头文件包含路径
target_include_directories(ShirohaPlayer PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${TAGLIB_INCLUDE_DIRS}
)

# 添加 Qt Widgets 模块
target_link_libraries(
  ShirohaPlayer PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Widgets  # 添加 Widgets 模块
    ${TAGLIB_LIBRARIES}
)

# 复制 API 目录到构建目录
add_custom_command(TARGET ShirohaPlayer POST_BUILD
   COMMAND ${CMAKE_COMMAND} -E copy_directory
       ${CMAKE_CURRENT_SOURCE_DIR}/api
       $<TARGET_FILE_DIR:ShirohaPlayer>/api
   COMMENT "Copying API directory to build folder"
)

# 设置可执行权限（仅 Linux）
if(UNIX)
   add_custom_command(TARGET ShirohaPlayer POST_BUILD
       COMMAND chmod +x $<TARGET_FILE_DIR:ShirohaPlayer>/api/netease_api
       COMMENT "Setting executable permissions for API"
   )
endif()


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1. If
# you are developing for iOS or macOS you should consider setting an explicit,
# fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.ShirohaPlayer)
endif()
set_target_properties(
  ShirohaPlayer
  PROPERTIES ${BUNDLE_ID_OPTION} MACOSX_BUNDLE_BUNDLE_VERSION
             ${PROJECT_VERSION} MACOSX_BUNDLE_SHORT_VERSION_STRING
             ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR} MACOSX_BUNDLE
             TRUE WIN32_EXECUTABLE
             TRUE)

include(GNUInstallDirs)
install(
  TARGETS ShirohaPlayer
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
  qt_import_qml_plugins(ShirohaPlayer)
  qt_finalize_executable(ShirohaPlayer)
endif()
