#!/usr/bin/env bash
#!/usr/bin/env node --max-old-space-size=4096

set -u -e -o pipefail

cd $(dirname $0)/../..

source ./scripts/ci/utils.sh

DEBUG=false
NOCSS=false
PACKAGES=(
  bis
)
NODE_PACKAGES=(cli)

for ARG in "$@"; do
  case "$ARG" in
    -n)
      PACKAGES=($2)
      ;;
    -debug)
      DEBUG=true
      ;;
    -nocss)
      NOCSS=true
      ;;
  esac
done

buildLess() {
  echo 'copy styles...'
  node ./scripts/build/copy-less.js
}

addBanners() {
  for file in ${1}/*; do
    if [[ -f ${file} && "${file##*.}" != "map" ]]; then
      cat ${LICENSE_BANNER} > ${file}.tmp
      cat ${file} >> ${file}.tmp
      mv ${file}.tmp ${file}
    fi
  done
}


echo "=====BUILDING: Version ${VERSION}, Zorro Version ${ZORROVERSION}"

N="
"
PWD=`pwd`

SOURCE=${PWD}/packages
DIST=${PWD}/dist/@yelon16-patch

# fix linux
# npm rebuild node-sass

build() {
  for NAME in ${PACKAGES[@]}
  do
    echo "====== PACKAGING ${NAME}"

    if ! containsElement "${NAME}" "${NODE_PACKAGES[@]}"; then
      node --max_old_space_size=4096 ${PWD}/scripts/build/packing ${NAME}
    else
      echo "not yet!!!"
    fi

  done

  if [[ ${NOCSS} == false ]]; then
    buildLess
  fi
  # package version
  updateVersionReferences ${DIST}
}

build

echo 'FINISHED!'

# TODO: just only cipchk
# clear | bash ./scripts/ci/build-yelon.sh -debug
# clear | bash ./scripts/ci/build-yelon.sh -n chart -nocss
if [[ ${DEBUG} == true ]]; then
  cd ../../
  DEBUG_FROM=${PWD}/work/yelon/dist/@yelon/theme/*
  DEBUG_TO=${PWD}/work/ng11-strict/node_modules/@yelon/theme
  echo "DEBUG_FROM:${DEBUG_FROM}"
  echo "DEBUG_TO:${DEBUG_TO}"
  rm -rf ${DEBUG_TO}
  mkdir -p ${DEBUG_TO}
  rsync -a ${DEBUG_FROM} ${DEBUG_TO}
  echo "DEBUG FINISHED~!"
fi
