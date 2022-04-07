# CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END

# Copyright 2018 Saso Kiselkov. All rights reserved.

# Shared library without any Qt functionality
TEMPLATE = lib
QT -= gui core
CONFIG += dll warn_on plugin debug
CONFIG -= thread exceptions qt rtti release

INCLUDEPATH += $$[LIBACFUTILS]/src
INCLUDEPATH += $$[LIBACFUTILS]/SDK/CHeaders/XPLM
INCLUDEPATH += $$[LIBACFUTILS]/SDK/CHeaders/Widgets
# Glew for Windows x64 (must use mingw version if building on linux!)
INCLUDEPATH += $$[LIBACFUTILS]/libacfutils-redist/mingw64/include/
#INCLUDEPATH += $$[LIBACFUTILS]/glew/mingw64/include/
INCLUDEPATH += $$[LIBACFUTILS]/cglm/cglm-0.7.9/include
INCLUDEPATH += $$[LIBACFUTILS]/soil/include
QMAKE_CFLAGS += -std=c99 -O2 -g -W -Wall -Wextra -Werror -fvisibility=hidden
QMAKE_CFLAGS += -Wunused-result

# _GNU_SOURCE needed on Linux for getline()
# DEBUG - used by our ASSERT macro
# _FILE_OFFSET_BITS=64 to get 64-bit ftell and fseek on 32-bit platforms.
# _USE_MATH_DEFINES - sometimes helps getting M_PI defined from system headers
DEFINES += _GNU_SOURCE DEBUG _FILE_OFFSET_BITS=64
DEFINES += GL_GLEXT_PROTOTYPES

# Grab the latest tag as the version number for a release version.
DEFINES += PLUGIN_VERSION=\'\"$$system("git describe --abbrev=0 --tags")\"\'

# Latest X-Plane APIs. Legacy support needed.
DEFINES += XPLM200 XPLM210 XPLM300 XPLM301 XPLM302 XPLM_DEPRECATED

TARGET = rain

win32 {
	# Minimum Windows version is Windows Vista (0x0600)
	DEFINES += APL=0 IBM=1 LIN=0 _WIN32_WINNT=0x0600 GLEW_BUILD
	QMAKE_DEL_FILE = rm -f
	QMAKE_CFLAGS -= -Werror
	LIBS += -static-libgcc
}

win32:contains(CROSS_COMPILE, x86_64-w64-mingw32-) {
	QMAKE_CFLAGS += $$system("$$[LIBACFUTILS]/pkg-config-deps win-64 \
	    --static-openal --cflags")

	LIBS += -L$$[LIBACFUTILS]/qmake/win64 -lacfutils
	LIBS += $$system("$$[LIBACFUTILS]/pkg-config-deps win-64 \
	    --static-openal --libs")
	LIBS += -L$$[LIBACFUTILS]/SDK/Libraries/Win -lXPLM_64
#SOIL does not come with libafcutils - you must download it youself. Download the mingw version if
        LIBS += -L$$[LIBACFUTILS]/soil/lib -lSOIL
	LIBS += -L$$[LIBACFUTILS]/GL_for_Windows/lib -lglu32 -lopengl32
	LIBS += -ldbghelp
}

linux-g++-64 {
	DEFINES += APL=0 IBM=0 LIN=1
	# The stack protector forces us to depend on libc,
	# but we'd prefer to be static.
	QMAKE_CFLAGS += -fno-stack-protector
	QMAKE_CFLAGS += $$system("$$[LIBACFUTILS]/pkg-config-deps linux-64 \
	    --static-openal --cflags")
	LIBS += -L$$[LIBACFUTILS]/qmake/lin64 -lacfutils
}

macx {
	DEFINES += APL=1 IBM=0 LIN=0
	QMAKE_CFLAGS += -mmacosx-version-min=10.9
}

macx-clang {
	QMAKE_CFLAGS += $$system("$$[LIBACFUTILS]/pkg-config-deps mac-64 \
	    --static-openal --cflags")
	LIBS += -L$$[LIBACFUTILS]/qmake/mac64 -lacfutils
	LIBS += -F$$[LIBACFUTILS]/SDK/Libraries/Mac
	LIBS += -framework OpenGL
	LIBS += -framework XPLM
}

HEADERS += ../../src/*.h
SOURCES += ../../src/*.c ../*.c
