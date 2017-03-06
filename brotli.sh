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

# Brotli settings
BROTLI_LEVEL=11

# Also enable gzip compression for css and js
GZIP=y
GZIP_LEVEL=11

LOGDIR='/var/log/brotli'
CPUS=$(grep -c "processor" /proc/cpuinfo)
######################################################
# functions
#############
SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

if [ ! -f /usr/local/bin/bro ]; then
  if [ -d /svr-setup ]; then
    cd /svr-setup
  else
    cd /usr/local/src
  fi
  git clone https://github.com/google/brotli.git
  cd brotli
  python setup.py install
  make -j${CPUS}
  if [ -d /svr-setup ]; then
    ls -lah /svr-setup/brotli/bin/bro
  else
    ls -lah /usr/local/src/brotli/bin/bro
  fi
  \cp -af bin/bro /usr/local/bin/bro
elif [ -f /usr/local/bin/bro ]; then
  BROTLI_BIN='/usr/local/bin/bro'
  BROTLI_BINOPT="--quality $BROTLI_LEVEL --force"
fi

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
  GZIP_LEVEL=4
  GZIP_BINOPT="-${GZIP_LEVEL}"
else
  GZIP_PIGZ='y'
  GZIP_BIN='/usr/bin/pigz'
  GZIP_BINOPT="-${GZIP_LEVEL}k -f"
fi

brotli_compress() {
  BROTLI_CLEAN=$1
  /usr/bin/find $DIR_PATH -type f -iname '*.js' -print0 | while read -d $'\0' f;
  do
    if [[ "$BROTLI_CLEAN" != 'clean' ]]; then
      if [[ "$DEBUG" = [yY] ]]; then
        echo "$BROTLI_BIN $BROTLI_BINOPT --input ${f} --output ${f}.br"
        echo "chown ${USER}:${GROUP} ${f}.br"
        echo "chmod $CHMOD ${f}.br"
      fi
      if [ -f "${f}" ]; then
        if [[ "$DEBUG" = [yY] ]]; then
          /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $BROTLI_BIN $BROTLI_BINOPT --input "${f}" --output "${f}.br"
        else
          $BROTLI_BIN $BROTLI_BINOPT --input "${f}" --output "${f}.br"
        fi
        chown ${USER}:${GROUP} "${f}.br"
        chmod $CHMOD "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          if [[ "$GZIP_PIGZ" = [Yy] ]]; then
            if [[ "$DEBUG" = [yY] ]]; then
              echo "$GZIP_BIN $GZIP_BINOPT "${f}""
            fi
            if [[ "$DEBUG" = [yY] ]]; then
              /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT "${f}"
            else
              $GZIP_BIN $GZIP_BINOPT "${f}"
            fi
          else
            if [[ "$DEBUG" = [yY] ]]; then
              /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
            else
              $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
            fi
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
  
  /usr/bin/find $DIR_PATH -type f -iname '*.css' -print0 | while read -d $'\0' f;
  do
    if [[ "$BROTLI_CLEAN" != 'clean' ]]; then
      if [[ "$DEBUG" = [yY] ]]; then
        echo "$BROTLI_BIN $BROTLI_BINOPT --input ${f} --output ${f}.br"
        echo "chown ${USER}:${GROUP} ${f}.br"
        echo "chmod $CHMOD ${f}.br"
      fi
      if [ -f "${f}" ]; then
        if [[ "$DEBUG" = [yY] ]]; then
          /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $BROTLI_BIN $BROTLI_BINOPT --input "${f}" --output "${f}.br"
        else
          $BROTLI_BIN $BROTLI_BINOPT --input "${f}" --output "${f}.br"
        fi
        chown ${USER}:${GROUP} "${f}.br"
        chmod $CHMOD "${f}.br"
        if [[ "$GZIP" = [Yy] ]]; then
          if [[ "$GZIP_PIGZ" = [Yy] ]]; then
            if [[ "$DEBUG" = [yY] ]]; then
              echo "$GZIP_BIN $GZIP_BINOPT "${f}""
            fi
            if [[ "$DEBUG" = [yY] ]]; then
              /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT "${f}"
            else
              $GZIP_BIN $GZIP_BINOPT "${f}"
            fi
          else
            if [[ "$DEBUG" = [yY] ]]; then
              /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
            else
              $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
            fi
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
    echo "cleaned up brotli *.br & *.gz static css & js files"
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

