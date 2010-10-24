#!/bin/sh
# Copyright (C) 2010 Thomas Moulard, JRL, CNRS/AIST.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

 # ------ #
 # README #
 # ------ #

# This script updates the Doxygen documentation on Github.
#
# - it checkouts locally the gh-pages of the current repository,
# - it copy the local Doxygen documentation,
# - it creates a commit and push the modification.
#
# This scripts makes several assumptions on the project structure:
# 1. It should be launched from the documentation build directory
#    I.e. _build/doc
#
# 2. The documentation is generated in the doxygen-html directory
#    of the doc build directory.
#
# 3. The documentation is updated through `make doc` in the top build
#    directory.
#
# If doxygen.cmake is used, 2 and 3 will be respected.
#

# Override the locale.
LC_ALL='C'
export LC_ALL

me=$0
bme=`basename "$0"`


  # ----------------------- #
  # Customizable variables. #
  # ----------------------- #

: ${GIT=/usr/bin/git}

  # ---------------- #
  # Helper functions #
  # ---------------- #

set_colors()
{
  red='[0;31m';    lred='[1;31m'
  green='[0;32m';  lgreen='[1;32m'
  yellow='[0;33m'; lyellow='[1;33m'
  blue='[0;34m';   lblue='[1;34m'
  purple='[0;35m'; lpurple='[1;35m'
  cyan='[0;36m';   lcyan='[1;36m'
  grey='[0;37m';   lgrey='[1;37m'
  white='[0;38m';  lwhite='[1;38m'
  std='[m'
}

set_nocolors()
{
  red=;    lred=
  green=;  lgreen=
  yellow=; lyellow=
  blue=;   lblue=
  purple=; lpurple=
  cyan=;   lcyan=
  grey=;   lgrey=
  white=;  lwhite=
  std=
}

# abort err-msg
abort()
{
  echo "update-doxygen-doc.sh: ${lred}abort${std}: $@" \
  | sed '1!s/^[ 	]*/             /' >&2
  exit 1
}

# warn msg
warn()
{
  echo "update-doxygen-doc.sh: ${lred}warning${std}: $@" \
  | sed '1!s/^[ 	]*/             /' >&2
}

# notice msg
notice()
{
  echo "update-doxygen-doc.sh: ${lyellow}notice${std}: $@" \
  | sed '1!s/^[ 	]*/              /' >&2
}

# yesno question
yesno()
{
  printf "$@ [y/N] "
  read answer || return 1
  case $answer in
    y* | Y*) return 0;;
    *)       return 1;;
  esac
  return 42 # should never happen...
}


  # -------------------- #
  # Actions definitions. #
  # -------------------- #

version()
{
    echo 'update-doxygen-doc.sh - provided by @PROJECT_NAME@ @PROJECT_VERSION@
Copyright (C) 2010 JRL, CNRS/AIST.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.'
}

help()
{
    echo 'Usage: update-doxygen-doc.sh [action]
Actions:
  --help, -h		      Print this message and exit.
  --version, -v		      Print the script version and exit.
  --doc-version VERSION       Update the documentation of a stable
                              release to github.
                              VERSION by default is HEAD but can be
                              changed to vX.Y.Z to update the documentation
                              of a released version.
'

Report bugs to http://github.com/jrl-umi3218/jrl-cmakemodules/issues
For more information, see http://github.com/jrl-umi3218/jrl-cmakemodules
}

  # ------------------- #
  # `main' starts here. #
  # ------------------- #

# Define colors if stdout is a tty.
if test -t 1; then
  set_colors
else # stdout isn't a tty => don't print colors.
  set_nocolors
fi

# For dev's:
test "x$1" = x--debug && shift && set -x

doc_version=HEAD

remote_url=`${GIT} config remote.origin.url`

case $1 in
    version | v | --version | -version)
	shift
	version
	;;
    help | h | --help | -help)
	shift
	help
	;;
    --doc-version)
	doc_version=$2
	shift; shift
	;;
    --remote-url)
	remote_url=$2
	;;
    '')
	;;
    *)
	echo "update-doxygen-doc.sh: ${lred}invalid option${std}: $1"
	shift
	help
	exit 1
	;;
esac


# Main starts here...
echo "* Checkout ${doc_version}..."
${GIT} checkout --quiet $doc_version

echo "* Generating the documentation..."
(cd .. && make doc) 2> /dev/null > /dev/null || \
 abort "failed to generate the documentation"

echo "* Creating the temporary directory..."
tmp=`mktemp -d` || abort "cannot create the temporary directory"
trap "rm -rf -- '$tmp'" EXIT


build_docdir=`pwd`

head_commit=`${GIT} log --format=oneline HEAD^.. | cut -d' ' -f1`


echo "Remote url:" $remote_url


echo "* Clone the project..."
cd $tmp
${GIT} clone --quiet --depth 1 $remote_url project \
 || abort "failed to clone the package repository"
cd project \
 || abort "failed to change directory"

echo "* Checkout the github web pages..."
${GIT} checkout --quiet -b gh-pages origin/gh-pages \
 || abort "failed to checkout gh-pages (does the branch exist?)"

echo "* Copy the documentation..."
mkdir -p doxygen
rm -rf doxygen/$doc_version
cp -r $build_docdir/doxygen-html doxygen/$doc_version \
 || abort "failed to copy the documentation"

echo "* Generate the commit..."
${GIT} add doxygen/$doc_version \
 || abort "failed to add the updated documentation to the git index"

echo "Update $doc_version Doxygen documentation.
Source commit id: $head_commit" >> $tmp/commit_msg
commit_status=`${GIT} status -s`

# Make sure that there is something to commit.
# If this is not the case, the documentation is already
# up-to-date and the commit should not be generated.
if test -n "$commit_status"; then
  ${GIT} commit --quiet -F $tmp/commit_msg \
   || abort "failed to generate the git commit"

  echo "* Push the generated commit..."
  ${GIT} push origin gh-pages

  echo "${lgreen}Documentation updated with success!${std}"
else
    notice "Github pages documentation is already up-to-date."
fi

trap - EXIT
