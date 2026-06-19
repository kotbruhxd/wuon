# Install script for directory: /home/arseniy/muon/linux

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/arseniy/muon/build/linux/x64/release/bundle")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/run/current-system/sw/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/arseniy/muon/build/linux/x64/release/bundle/")
  
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon"
         RPATH "$ORIGIN/lib")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/wuon")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle" TYPE EXECUTABLE FILES "/home/arseniy/muon/build/linux/x64/release/intermediates_do_not_run/wuon")
  if(EXISTS "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon"
         OLD_RPATH "/home/arseniy/muon/build/linux/x64/release/plugins/file_selector_linux:/home/arseniy/muon/build/linux/x64/release/plugins/flutter_audio_desktop:/home/arseniy/muon/build/linux/x64/release/plugins/window_size:/home/arseniy/muon/linux/flutter/ephemeral:/nix/store/1scb6xccxlqy8rj9hfgf7ppqv99pfwq9-util-linux-minimal-2.42-lib/lib:/nix/store/waz72vmxc8zk90qqvgg9ikhzdk1kzjy4-xz-5.8.3/lib:/nix/store/v7fvwaf6j1hwvb9dmwfa97nzmrlshqai-gtk+3-3.24.52/lib:/nix/store/2bnyj2q5if7xpbhsmw0ylxj9bwj98daf-pango-1.57.1/lib:/nix/store/dydyb18hkw3aqmap8apa3708ws440nxd-cairo-1.18.4/lib:/nix/store/5d5gq4hcclz3mwikka3ykh924p610bdr-gdk-pixbuf-2.44.6/lib:/nix/store/s3knizlhir254y56l6kdd85dq8pm8xb1-at-spi2-core-2.60.1/lib:/nix/store/bd9nkv00cbnj19zc61rlqyrjvnlmq73j-harfbuzz-13.2.1/lib:/nix/store/jlyahda14aya375lv7k9fsin2zk90nxz-glib-2.88.1/lib:"
         NEW_RPATH "$ORIGIN/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/run/current-system/sw/bin/strip" "$ENV{DESTDIR}/home/arseniy/muon/build/linux/x64/release/bundle/wuon")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle/data" TYPE FILE FILES "/home/arseniy/muon/linux/flutter/ephemeral/icudtl.dat")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/lib/libflutter_linux_gtk.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle/lib" TYPE FILE FILES "/home/arseniy/muon/linux/flutter/ephemeral/libflutter_linux_gtk.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/lib/libfile_selector_linux_plugin.so;/home/arseniy/muon/build/linux/x64/release/bundle/lib/libflutter_audio_desktop_plugin.so;/home/arseniy/muon/build/linux/x64/release/bundle/lib/libwindow_size_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle/lib" TYPE FILE FILES
    "/home/arseniy/muon/build/linux/x64/release/plugins/file_selector_linux/libfile_selector_linux_plugin.so"
    "/home/arseniy/muon/build/linux/x64/release/plugins/flutter_audio_desktop/libflutter_audio_desktop_plugin.so"
    "/home/arseniy/muon/build/linux/x64/release/plugins/window_size/libwindow_size_plugin.so"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/arseniy/muon/build/linux/x64/release/bundle/data/flutter_assets")
  
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle/data" TYPE DIRECTORY FILES "/home/arseniy/muon/build//flutter_assets")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/arseniy/muon/build/linux/x64/release/bundle/lib/libapp.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/arseniy/muon/build/linux/x64/release/bundle/lib" TYPE FILE FILES "/home/arseniy/muon/build/lib/libapp.so")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/arseniy/muon/build/linux/x64/release/flutter/cmake_install.cmake")
  include("/home/arseniy/muon/build/linux/x64/release/plugins/file_selector_linux/cmake_install.cmake")
  include("/home/arseniy/muon/build/linux/x64/release/plugins/flutter_audio_desktop/cmake_install.cmake")
  include("/home/arseniy/muon/build/linux/x64/release/plugins/window_size/cmake_install.cmake")
  include("/home/arseniy/muon/build/linux/x64/release/plugins/jni/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/arseniy/muon/build/linux/x64/release/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/arseniy/muon/build/linux/x64/release/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
