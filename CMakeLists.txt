project(oxygen-icons NONE)
cmake_minimum_required(VERSION 2.6)

# ECM setup
include(FeatureSummary)
find_package(ECM 5.15.0  NO_MODULE)
set_package_properties(ECM PROPERTIES TYPE REQUIRED DESCRIPTION "Extra CMake Modules." URL "https://projects.kde.org/projects/kdesupport/extra-cmake-modules")
feature_summary(WHAT REQUIRED_PACKAGES_NOT_FOUND FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(KF5_VERSION "5.16.0") # handled by release scripts

if (WIN32)
   set(ICON_INSTALL_DIR         "share/icons"             ) # The icon install dir (default ${SHARE_INSTALL_PREFIX}/share/icons/)
else (WIN32)
   set(SHARE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/share" )
   set(ICON_INSTALL_DIR     "${SHARE_INSTALL_PREFIX}/icons" )
endif(WIN32)

########### install files ###############

set( oxygen_icon_dirs  8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256 )

set(OXYGEN_INSTALL_DIR ${ICON_INSTALL_DIR}/oxygen)
install( DIRECTORY ${oxygen_icon_dirs} DESTINATION ${OXYGEN_INSTALL_DIR} PATTERN .svn EXCLUDE PATTERN "*.sh" EXCLUDE )
install( FILES index.theme DESTINATION ${OXYGEN_INSTALL_DIR})

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

