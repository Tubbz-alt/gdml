dnl
dnl m4 macros for setting up Geant4
dnl

# call all the Geant4 macros
AC_DEFUN([GDML_SETUP_GEANT4], [

GDML_WITH_GEANT4
GDML_GEANT4_VERSION
GDML_WITH_G4SYSTEM
GDML_WITH_GEANT4_INCLUDE
GDML_WITH_GEANT4_LIBDIR
GDML_ENABLE_GEANT4_GRANULAR_LIBS
GDML_SUBST_GEANT4

GDML_CHECK_NIST
GDML_ENABLE_NIST

GDML_HAVEG4TESSELLATED
GDML_HAVEG4TET
GDML_HAVEG4TWISTEDBOX
GDML_HAVEG4TWISTEDTRD
GDML_HAVEG4TWISTEDTRAP
GDML_HAVEG4TWISTEDTUBS
GDML_HAVEG4ELLIPSOID
GDML_HAVEG4EXTRUDEDSOLID

])

# macro to set GEANT4 base dir (G4INSTALL)
AC_DEFUN([GDML_WITH_GEANT4], [

AC_MSG_CHECKING(for GEANT4 installation setting)

AC_ARG_WITH(geant4,
	AC_HELP_STRING([--with-geant4=<path>],[Geant4 installation base [[G4INSTALL]] ]),
	[GEANT4_PREFIX=$with_geant4],
	[GEANT4_PREFIX=$G4INSTALL])

AC_MSG_RESULT([$GEANT4_PREFIX])

GDML_CHECK_PKG_DIR( [$GEANT4_PREFIX], [Geant4])

])

# macro to set G4SYSTEM
AC_DEFUN([GDML_WITH_G4SYSTEM], [

AC_MSG_CHECKING(for G4SYSTEM setting)

AC_ARG_WITH(geant4-system,
	AC_HELP_STRING([--with-geant4-system=<value>],[Value of G4SYSTEM variable]),
	[G4SYSTEM=$with_geant4_g4system])

if test -z "${G4SYSTEM}"; then
  G4SYSTEM=`uname`-${CXX}
fi

AC_MSG_RESULT([$G4SYSTEM])

AC_SUBST(G4SYSTEM)

])

# macro to set GEANT4 include dir
AC_DEFUN([GDML_WITH_GEANT4_INCLUDE], [

AC_MSG_CHECKING([for Geant4 include dir setting])

AC_ARG_WITH([geant4-include],
	AC_HELP_STRING([--with-geant4-include=<path>],[Geant4 alternate headers dir]),
	[GEANT4_INCLUDE=$with_geant4_include],
	[GEANT4_INCLUDE=$GEANT4_PREFIX/include/Geant4])

AC_MSG_RESULT([$GEANT4_INCLUDE])

GDML_CHECK_PKG_DIR( [$GEANT4_INCLUDE],
	[GEANT4],
	[G4RunManager.hh])
])

AC_MSG_RESULT([yes])

# macro to set GEANT4 lib dir
AC_DEFUN([GDML_WITH_GEANT4_LIBDIR], [

AC_MSG_CHECKING([for Geant4 lib dir])

AC_ARG_WITH([geant4-libdir],
	AC_HELP_STRING([--with-geant4-libdir=<path>], [Geant4 alternate library dir]),
	[GEANT4_LIBDIR=$with_geant4_libdir],
	[GEANT4_LIBDIR=$GEANT4_PREFIX/lib64])

AC_MSG_RESULT([$GEANT4_LIBDIR])

GDML_CHECK_PKG_DIR( [$GEANT4_LIBDIR],
	[GEANT4])
])

# macro to substitute GEANT4 vars to output
AC_DEFUN([GDML_SUBST_GEANT4], [

AC_SUBST(GEANT4_PREFIX)
AC_SUBST(GEANT4_INCLUDE)
AC_SUBST(GEANT4_LIBDIR)

])

# macro to select granular libs
AC_DEFUN([GDML_ENABLE_GEANT4_GRANULAR_LIBS], [

AC_MSG_CHECKING(whether to use Geant4 granular libs)

AC_ARG_ENABLE([geant4-granular-libs],
	AC_HELP_STRING( [--enable-geant4-granular-libs], [Enable linking against granular rather than global Geant4 libs] ),
	[ac_g4_use_granular=$enable_geant4_granular_libs],
	[ac_g4_use_granular=no])

# no option?
if test -z "${with_geant4_granular_libs}"; then
  # set in env?
  if test -n "${G4LIB_USE_GRANULAR}"; then
    ac_g4_use_granular=yes
  fi
fi

AC_MSG_RESULT([$ac_g4_use_granular])

if test "${ac_g4_use_granular}" = "yes"; then
  GEANT4_USE_GRANULAR=1 
  AC_SUBST(GEANT4_USE_GRANULAR)
else
  GEANT4_USE_GLOBAL=1
  AC_SUBST(GEANT4_USE_GLOBAL)
fi

])

# macro to check whether NIST is supported by the current Geant4 version
AC_DEFUN([GDML_CHECK_NIST], [

HAVE_NIST=no

AC_CHECK_FILE([$GEANT4_PREFIX/source/materials/include/G4NistManager.hh],HAVE_NIST=yes)

if test "$HAVE_NIST" = "yes"
then
  AC_DEFINE(HAVE_NIST)
fi

])

# macro to enable/disable NIST support
AC_DEFUN([GDML_ENABLE_NIST], [

dnl Removed because this is somehow getting put in front of GEANT4_PREFIX setting, which breaks NIST config.
dnl AC_REQUIRE([GDML_CHECK_NIST])

AC_MSG_CHECKING(whether to enable Geant4 NIST support for material lookup)

AC_ARG_ENABLE([nist],
              AC_HELP_STRING([--enable-nist=<setting>]., [Turn NIST support on or off.]))

# default to using NIST if not set from the enable-nist option
if test "X$enable_nist" = "X"
then
  enable_nist=yes
fi

if test "X$enable_nist" = "Xyes"
then
  if test "X$HAVE_NIST" = "Xyes"
  then
    AC_MSG_RESULT(yes)
    AC_DEFINE(GDML_USE_NIST)
  else
    AC_MSG_RESULT(no)
    AC_MSG_WARN(NIST was selected but your version of Geant4 does not support it)
  fi
else
  AC_MSG_RESULT(no)
fi

])

dnl Macro to extract the Geant4 version from G4Version.hh or G4RunManagerKernel.hh, if the former file does not exist.
AC_DEFUN([GDML_GEANT4_VERSION], [

AC_MSG_CHECKING(for Geant4 full version)

if test -n "$GEANT4_PREFIX"
then

  if ! test -d $GEANT4_PREFIX; then
    AC_MSG_ERROR(G4INSTALL does not point to a directory)
  fi

  if ! test -e $GEANT4_PREFIX/source/run/include/G4RunManager.hh; then
    AC_MSG_ERROR(G4INSTALL does not appear to contain the Geant4 source code)
  fi

  if test -e "$GEANT4_PREFIX/source/global/management/include/G4Version.hh"
  then
    GEANT4_FULL_VERSION=$(sed -n -e '/#define G4VERSION_NUMBER/s/#define G4VERSION_NUMBER  //p' $GEANT4_PREFIX/source/global/management/include/G4Version.hh | \
                          awk 'BEGIN { FS="" } ; { print [$]1"."[$]2"."[$]3 }')
  elif test -e "$GEANT4_PREFIX/source/run/src/G4RunManagerKernel.cc"
  then
    GEANT4_FULL_VERSION=$(sed -n -e '/\/\/ GEANT4 tag /s/.*\(geant4-[[0-9]]*-[[0-9]]*[[0-9a-z-]]*\).*/\1/p' \
                          $GEANT4_PREFIX/source/run/src/G4RunManagerKernel.cc | sed -e 's/geant4-//g' -e 's/patch-//g' -e 's/-/./g')
  else
    AC_MSG_ERROR(could not determine Geant4 version because G4Version.hh or G4RunManagerKernel.hh was not found in $GEANT4_PREFIX)
  fi
else
  AC_MSG_ERROR(G4INSTALL is not set in the environment)
fi

GEANT4_MAJOR_VERSION=$(echo "$GEANT4_FULL_VERSION" | awk 'BEGIN{ FS="." } { print [$]1 }' | sed 's/0*//')
GEANT4_MINOR_VERSION=$(echo "$GEANT4_FULL_VERSION" | awk 'BEGIN{ FS="." } { print [$]2 }' | sed 's/0*//')
GEANT4_PATCH_VERSION=$(echo "$GEANT4_FULL_VERSION" | awk 'BEGIN{ FS="." } { print [$]3 }' | sed 's/0*//')

if test -z "$GEANT4_MINOR_VERSION";
then
  GEANT4_MINOR_VERSION=0
fi

if test -z "$GEANT4_PATCH_VERSION";
then
  GEANT4_PATCH_VERSION=0
fi

GEANT4_FULL_VERSION=$GEANT4_MAJOR_VERSION"."$GEANT4_MINOR_VERSION"."$GEANT4_PATCH_VERSION

AC_MSG_RESULT($GEANT4_FULL_VERSION)

AC_MSG_CHECKING(for Geant4 major version level)
AC_MSG_RESULT($GEANT4_MAJOR_VERSION)

AC_MSG_CHECKING(for Geant4 minor version level)
AC_MSG_RESULT($GEANT4_MINOR_VERSION)

AC_MSG_CHECKING(for Geant4 patch level)
AC_MSG_RESULT($GEANT4_PATCH_VERSION)

AC_SUBST(GEANT4_FULL_VERSION)
AC_SUBST(GEANT4_MAJOR_VERSION)
AC_SUBST(GEANT4_MINOR_VERSION)
AC_SUBST(GEANT4_PATCH_VERSION)

])

# Macro to set HAVE_G4TESSELLATED if G4TessellatedSolid.hh exists.
AC_DEFUN([GDML_HAVEG4TESSELLATED], [

AC_MSG_CHECKING(whether to enable G4TessellatedSolid)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4TessellatedSolid.hh; then
  AC_DEFINE(HAVE_G4TESSELLATEDSOLID)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4TET if G4Tet.hh exists.
AC_DEFUN([GDML_HAVEG4TET], [

AC_MSG_CHECKING(whether to enable G4Tet)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4Tet.hh; then
  AC_DEFINE(HAVE_G4TET)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4TWISTEDBOX if G4TwistedBox.hh exists.
AC_DEFUN([GDML_HAVEG4TWISTEDBOX], [

AC_MSG_CHECKING(whether to enable G4TwistedBox)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4TwistedBox.hh; then
  AC_DEFINE(HAVE_G4TWISTEDBOX)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4TWISTEDTRD if G4TwistedTrd.hh exists.
AC_DEFUN([GDML_HAVEG4TWISTEDTRD], [

AC_MSG_CHECKING(whether to enable G4TwistedTrd)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4TwistedTrd.hh; then
  AC_DEFINE(HAVE_G4TWISTEDTRD)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4TWISTEDTRAP if G4TwistedTrap.hh exists.
AC_DEFUN([GDML_HAVEG4TWISTEDTRAP], [

AC_MSG_CHECKING(whether to enable G4TwistedTrap)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4TwistedTrap.hh; then
  AC_DEFINE(HAVE_G4TWISTEDTRAP)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4TWISTEDTUBS if G4TwistedTubs.hh exists.
AC_DEFUN([GDML_HAVEG4TWISTEDTUBS], [

AC_MSG_CHECKING(whether to enable G4TwistedTubs)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4TwistedTubs.hh; then
  AC_DEFINE(HAVE_G4TWISTEDTUBS)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4ELLIPSOID if G4Ellipsoid.hh exists.
AC_DEFUN([GDML_HAVEG4ELLIPSOID], [

AC_MSG_CHECKING(whether to enable G4Ellipsoid)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4Ellipsoid.hh; then
  AC_DEFINE(HAVE_G4ELLIPSOID)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])

# Macro to set HAVE_G4EXTRUDEDSOLID if G4ExtrudedSolid.hh exists.
AC_DEFUN([GDML_HAVEG4EXTRUDEDSOLID], [

AC_MSG_CHECKING(whether to enable G4ExtrudedSolid)

if test -e $GEANT4_PREFIX/source/geometry/solids/specific/include/G4ExtrudedSolid.hh; then
  AC_DEFINE(HAVE_G4EXTRUDEDSOLID)
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi

])
