#!/bin/bash
######################################################
# brotli.sh compression tool for manual brotli compress
# of css and js files
# written by George Liu (eva2000) centminmod.com
######################################################
# variables
#############
DT=`date +"%d%m%y-%H%M%S"`

USER=nginx
GROUP=nginx
CHMOD=644
DBEUG=n

# Also enable gzip compression for css and js
GZIP=y

LOGDIR='/var/log/brotli'
CPUS=$(grep -c "processor" /proc/cpuinfo)
######################################################
# functions
#############
SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

if [ ! -f /usr/bin/pigz ]; then
    yum -q -y install pigz
    if [ ! -f /usr/bin/pigz ]; then
      echo "/usr/bin/pigz still not found"
      exit
    fi
fi

if [ ! -f /usr/bin/pigz ]; then
  GZIP_PIGZ='n'
fi

if [ ! -d "$LOGDIR" ]; then
  mkdir -p "$LOGDIR"
fi

if [ -f "$SCRIPT_DIR/brotli-config.ini" ]; then
  source "$SCRIPT_DIR/brotli-config.ini"
fi

if [ "$CPUS" -lt 2 ]; then
  GZIP_PIGZ='n'
  GZIP_BIN='/usr/bin/gzip'
  GZIP_BINOPT='-6'
else
  GZIP_PIGZ='y'
  GZIP_BIN='/usr/bin/pigz'
  GZIP_BINOPT='-11k'
fi

brotli_compress() {
  BROTLI_CLEAN=$1
  for f in $(/usr/bin/find $DIR_PATH -type f -iname '*.js')
  do
    if [[ "$BROTLI_CLEAN" != 'clean' ]]; then
      if [[ "$DEBUG" = [yY] ]]; then
        echo "/usr/local/bin/bro --force --input ${f} --output ${f}.br"
        echo "chown ${USER}:${GROUP} ${f}.br"
        echo "chmod $CHMOD ${f}.br"
      fi
      if [ -f "${f}" ]; then
        /usr/local/bin/bro --force --input "${f}" --output "${f}.br"
        chown ${USER}:${GROUP} "${f}.br"
        chmod $CHMOD "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          if [[ "$GZIP_PIGZ" = [Yy] ]]; then
            if [[ "$DEBUG" = [yY] ]]; then
              echo "$GZIP_BIN $GZIP_BINOPT "${f}""
            fi
            $GZIP_BIN $GZIP_BINOPT "${f}"
          else
            $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
          fi
          if [[ "$DEBUG" = [yY] ]]; then
            echo "chown ${USER}:${GROUP} "${f}.gz""
            echo "chmod $CHMOD "${f}.gz""
          fi
          chown ${USER}:${GROUP} "${f}.gz"
          chmod $CHMOD "${f}.gz"
        fi
      fi
    fi
    if [[ "$BROTLI_CLEAN" = 'clean' ]]; then
      if [ -f "${f}.br" ]; then
        if [[ "$DEBUG" = [yY] ]]; then
          echo "rm -rf ${f}.br"
          if [[ "$GZIP" = [Yy] ]]; then
            echo "rm -rf "${f}.gz""
          fi
        fi
        rm -rf "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          rm -rf "${f}.gz"
        fi
      fi
    fi
  done
  
  for f in $(/usr/bin/find $DIR_PATH -type f -iname '*.css')
  do
    if [[ "$BROTLI_CLEAN" != 'clean' ]]; then
      if [[ "$DEBUG" = [yY] ]]; then
        echo "/usr/local/bin/bro --force --input ${f} --output ${f}.br"
        echo "chown ${USER}:${GROUP} ${f}.br"
        echo "chmod $CHMOD ${f}.br"
      fi
      if [ -f "${f}" ]; then
        /usr/local/bin/bro --force --input "${f}" --output "${f}.br"
        chown ${USER}:${GROUP} "${f}.br"
        chmod $CHMOD "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          if [[ "$GZIP_PIGZ" = [Yy] ]]; then
            if [[ "$DEBUG" = [yY] ]]; then
              echo "$GZIP_BIN $GZIP_BINOPT "${f}""
            fi
            $GZIP_BIN $GZIP_BINOPT "${f}"
          else
            $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
          fi
          if [[ "$DEBUG" = [yY] ]]; then
            echo "chown ${USER}:${GROUP} "${f}.gz""
            echo "chmod $CHMOD "${f}.gz""
          fi
          chown ${USER}:${GROUP} "${f}.gz"
          chmod $CHMOD "${f}.gz"
        fi
      fi
    fi
    if [[ "$BROTLI_CLEAN" = 'clean' ]]; then
      if [ -f "${f}.br" ]; then
        if [[ "$DEBUG" = [yY] ]]; then
          echo "rm -rf ${f}.br"
          if [[ "$GZIP" = [Yy] ]]; then
            echo "rm -rf "${f}.gz""
          fi
        fi
        rm -rf "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          rm -rf "${f}.gz"
        fi
      fi
    fi
  done
  if [[ "$BROTLI_CLEAN" = 'clean' ]]; then
    echo
    echo "cleaned up brotli *.br static css & js files"
    echo "recursively under $DIR_PATH"
    echo
  fi
}

######################################################
DIR_PATH=$1
CLEAN=$2

if [[ -z "$DIR_PATH" && -z "$CLEAN" ]] || [[ -z "$DIR_PATH" && ! -z "$CLEAN" ]]; then
  echo
  echo "Usage"
  echo
  echo "$0 /path/to/parent/directory"
  echo "$0 /path/to/parent/directory clean"
  echo
elif [[ -d "$DIR_PATH" && ! -z "$DIR_PATH" && "$CLEAN" = 'clean' ]]; then
  {
  brotli_compress clean
  } 2>&1 | tee ${LOGDIR}/brotli.sh_${DT}.log
else
  {
  brotli_compress
} 2>&1 | tee ${LOGDIR}/brotli.sh_${DT}.log
fi

