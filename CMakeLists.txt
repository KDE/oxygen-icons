cmake_minimum_required(VERSION 3.16)

set(KF_VERSION "5.90.0") # handled by release scripts
project(oxygen-icons VERSION ${KF_VERSION})

# ECM setup
include(FeatureSummary)
find_package(ECM 5.90.0  NO_MODULE)
set_package_properties(ECM PROPERTIES TYPE REQUIRED DESCRIPTION "Extra CMake Modules." URL "https://commits.kde.org/extra-cmake-modules")
feature_summary(WHAT REQUIRED_PACKAGES_NOT_FOUND FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEGitCommitHooks)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)

# Dependencies
set(REQUIRED_QT_VERSION 5.15.2)

set( oxygen_icon_dirs  8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256 )

add_subdirectory(autotests)

########### install files ###############

set(OXYGEN_INSTALL_DIR ${KDE_INSTALL_ICONDIR}/oxygen/base)
install( DIRECTORY ${oxygen_icon_dirs} DESTINATION ${OXYGEN_INSTALL_DIR} PATTERN .svn EXCLUDE PATTERN "*.sh" EXCLUDE )
install( FILES index.theme DESTINATION ${KDE_INSTALL_ICONDIR}/oxygen)

macro (COPY_ICONS _srcdir _srcfile _destdir)
  set(_src "${_srcdir}/${_srcfile}")
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
    foreach(_dest ${ARGN})
      install( FILES "${_src}" DESTINATION ${_destdir}/${_srcdir} RENAME "${_dest}" )
    endforeach()
  endif()
endmacro (COPY_ICONS)

# Copy the msoffice icon to the msoffice-2007 mimetypes (#225507)
foreach(_sizedir ${oxygen_icon_dirs})

#  template/example
#  COPY_ICONS(
#    ${_sizedir}/mimetypes
#    application-msword.png
#    ${OXYGEN_INSTALL_DIR}
#    application-vnd.openxmlformats-officedocument.wordprocessingml.template.png
#    application-vnd.ms-word.template.macroEnabled.12.png)

endforeach()

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)


kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
