#!/bin/bash
######################################################
# brotli.sh compression tool for manual brotli compress
# of css and js files
# written by George Liu (eva2000) centminmod.com
######################################################
# variables
#############
VERSION='0.6'
DT=`date +"%d%m%y-%H%M%S"`

# file extension type array
# space separated list of file extensions to compress each
# using wildcard wrapped in double quotes
FILETYPES=( "*.css" "*.js" )
FILE_MINSIZE='1048576'

USER=nginx
GROUP=nginx
CHMOD=644
DEBUG=y
TIMEDSTATS=n

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

if [[ ! -f /usr/local/bin/brotli || -f /usr/local/bin/bro ]]; then
  echo
  echo "/usr/local/bin/brotli not found"
  echo "installing brotli binary"
  echo
  sleep 3
  if [ -d /svr-setup ]; then
    cd /svr-setup
    rm -rf /svr-setup/brotli
  else
    cd /usr/local/src
    rm -rf /usr/local/src/brotli
  fi
  if [ -f /usr/local/bin/bro ]; then
    rm -rf /usr/local/bin/bro
  fi
  git clone https://github.com/google/brotli.git
  cd brotli
  ./configure-cmake
  make -j${CPUS}
  make install
  if [ -d /svr-setup ]; then
    ls -lah /usr/local/bin/brotli
  else
    ls -lah /usr/local/bin/brotli
  fi
  # \cp -af bin/brotli /usr/local/bin/brotli
  BROTLI_BIN='/usr/local/bin/brotli'
  BROTLI_BINOPT="-q $BROTLI_LEVEL --force"
elif [ -f /usr/local/bin/brotli ]; then
  BROTLI_BIN='/usr/local/bin/brotli'
  BROTLI_BINOPT="-q $BROTLI_LEVEL --force"
fi

if [ ! -f /usr/bin/pigz ]; then
  echo
  echo "/usr/bin/pigz not found"
  echo "installing pigz from YUM repo"
  echo
  sleep 3
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

display_files() {
  DISPLAY=$1
  if [[ "$DISPLAY" = 'display' ]]; then
    echo
    echo "Listing all *.br and *.gz css and js files"
    echo
    /usr/bin/find $DIR_PATH -type f \( -iname '*.js.br' -o -iname '*.js.gz' -o -iname '*.css.br' -o -iname '*.css.gz' \) -print0 | while read -d $'\0' f;
    do
      echo "$f"
    done
  fi
}

brotli_compress() {
  BROTLI_CLEAN=$1
  for filematch in "${FILETYPES[@]}"
   do
    ##
    /usr/bin/find $DIR_PATH -type f -iname "$filematch" -print0 | while read -d $'\0' f;
    do
      DETECT_EXT="${f##*.}"
      FILESIZE=$(stat -c%s "$f")
      if [[ "$BROTLI_CLEAN" != 'clean' ]] && [[ "$FILESIZE" -le "$FILE_MINSIZE" ]]; then
        if [[ "$DEBUG" = [yY] ]]; then
          BROTLI_BINSHORT=$(echo $BROTLI_BIN | sed -e 's|\/usr\/local\/bin\/||')
          echo -n "[br compress $DETECT_EXT $FILESIZE bytes]: "
          echo "$BROTLI_BINSHORT $BROTLI_BINOPT --input ${f} --output ${f}.br"
          # echo "chown ${USER}:${GROUP} ${f}.br"
          # echo "chmod $CHMOD ${f}.br"
        fi
        if [ -f "${f}" ]; then
          if [[ "$DEBUG" = [yY] ]]; then
            if [[ "$TIMEDSTATS" = [Yy] ]]; then
              echo -n "[br compress stats]: "
              /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $BROTLI_BIN $BROTLI_BINOPT "${f}" --output="${f}.br"
            else
              $BROTLI_BIN $BROTLI_BINOPT "${f}" --output="${f}.br"
            fi
          else
            echo "[br compress]: ${f}"
            $BROTLI_BIN $BROTLI_BINOPT "${f}" --output="${f}.br"
          fi
          chown ${USER}:${GROUP} "${f}.br"
          chmod $CHMOD "${f}.br"
          BRCOMP_FILESIZE=$(stat -c%s "${f}.br")
          if [[ "$DEBUG" = [yY] ]]; then
            BRCOMP_RATIO=$(echo "scale=2; $FILESIZE/$BRCOMP_FILESIZE" | bc)
            echo "[br compression ratio]: $BRCOMP_RATIO"
          fi
          if [[ "$GZIP" = [Yy] ]]; then
            if [[ "$GZIP_PIGZ" = [Yy] ]]; then
              if [[ "$DEBUG" = [yY] ]]; then
                GZIP_BINSHORT=$(echo $GZIP_BIN | sed -e 's|\/usr\/bin\/||')
                echo -n "[gz compress $DETECT_EXT $FILESIZE bytes]: "
                echo "$GZIP_BINSHORT $GZIP_BINOPT "${f}""
              fi
              if [[ "$DEBUG" = [yY] ]]; then
                if [[ "$TIMEDSTATS" = [Yy] ]]; then
                  echo -n "[gz compress stats]: "
                  /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT "${f}"
                else
                  $GZIP_BIN $GZIP_BINOPT "${f}"
                fi
              else
                echo "[gz compress]: ${f}"
                $GZIP_BIN $GZIP_BINOPT "${f}"
              fi
            else
              if [[ "$DEBUG" = [yY] ]]; then
                /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
              else
                $GZIP_BIN $GZIP_BINOPT -c  -- "${f}" > "${f}.gz"
              fi
            fi
            # if [[ "$DEBUG" = [yY] ]]; then
              # echo "chown ${USER}:${GROUP} "${f}.gz""
              # echo "chmod $CHMOD "${f}.gz""
            # fi
            chown ${USER}:${GROUP} "${f}.gz"
            chmod $CHMOD "${f}.gz"
            GZCOMP_FILESIZE=$(stat -c%s "${f}.gz")
            if [[ "$DEBUG" = [yY] ]]; then
              GZCOMP_RATIO=$(echo "scale=2; $FILESIZE/$GZCOMP_FILESIZE" | bc)
              echo "[gz compression ratio]: $GZCOMP_RATIO"
            fi
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
    ##
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
  echo "$0 /path/to/parent/directory display"
  echo
elif [[ -d "$DIR_PATH" && ! -z "$DIR_PATH" && "$CLEAN" = 'clean' ]]; then
  {
  brotli_compress clean
  } 2>&1 | tee ${LOGDIR}/brotli.sh_clean_${DT}.log
elif [[ -d "$DIR_PATH" && ! -z "$DIR_PATH" && "$CLEAN" = 'display' ]]; then
  {
  display_files display
  } 2>&1 | tee ${LOGDIR}/brotli.sh_display_${DT}.log
else
  {
  brotli_compress
} 2>&1 | tee ${LOGDIR}/brotli.sh_${DT}.log
fi

