#! /bin/bash

# Skip for debug build.

if [[ x$MRB_QUALS =~ x.*debug.* ]]; then
  echo "Skipping for debug build."
  exit 0
fi
if [[ x`which lar` =~ x.*debug.* ]]; then
  echo "Skipping for debug build."
  exit 0
fi

# Loop over all installed fcl files.

find $MRB_BUILDDIR/uboonecode/job -name \*.fcl -print | while read fcl
do
  echo "Testing fcl file $fcl"

  # Parse this fcl file.

  fclout=`basename ${fcl}`.out
  larout=`basename ${fcl}`.lar.out
  larerr=`basename ${fcl}`.lar.err
  lar -c $fcl --debug-config $fclout > $larout 2> $larerr

  # Exit status 1 counts as success.
  # Any other exit status exit immediately.

  stat=$?
  if [ $stat -ne 0 -a $stat -ne 1 ]; then
    echo "Error parsing ${fcl}."
    exit $stat
  fi

  # Check for certain kinds of diagnostic output.

  if egrep -iq 'deprecated|no longer supported' $larerr; then
    echo "Deprecated fcl construct found in ${fcl}."
    exit 1
  fi

  # Check for connections to development conditions database.

  if egrep -q uboonecon_dev $fclout; then
    echo "Found connection to development conditions database."
    exit 1
  fi

  # Check for connections to non-secure conditions database.

  if egrep -q 'http:.*uboonecon' $fclout; then
    echo "Found connection to non-secure conditions database server."
    exit 1
  fi

done
