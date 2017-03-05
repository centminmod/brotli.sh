brotli.sh
===============


tool to auto compress css and js files by specifying path. Appending clean flag on end of directory path will remove any *.br compressed files

    Usage
    
    /root/tools/brotli.sh /path/to/parent/directory
    /root/tools/brotli.sh /path/to/parent/directory clean

Default is non-debug mode without any verbose output. You can set `DEBUG=y` in separate config file `brotli-config.ini` located in same directory as `brotli.sh` which will enable debug mode for more verbose output.

Example:

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br

If `GZIP=y` variable enabled, you also can use `gzip` or `pigz` to create compressed gzip static versions of css and js files along with brotli ones. If only 1 cpu thread is detected, `brotli.sh` will fall back to gzip binary. If more than 2 cpu threads detected, then use pigz multi-threaded gzip binary.

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    /usr/bin/pigz -11k /usr/local/nginx/html/brotlitest2/bootstrap.min.js
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    /usr/bin/pigz -11k /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz

Resulting files

    ls -lah /usr/local/nginx/html/brotlitest2
    total 236K
    drwxr-sr-x  2 root  nginx 4.0K Mar  5 14:44 .
    drwxr-sr-x. 5 nginx nginx 4.0K Mar  5 13:33 ..
    -rw-r--r--  1 root  nginx 119K Jul 25  2016 bootstrap.min.css
    -rw-r--r--  1 nginx nginx  16K Jul 25  2016 bootstrap.min.css.br
    -rw-r--r--  1 nginx nginx  18K Jul 25  2016 bootstrap.min.css.gz
    -rw-r--r--  1 root  nginx  37K Jul 25  2016 bootstrap.min.js
    -rw-r--r--  1 nginx nginx 8.6K Jul 25  2016 bootstrap.min.js.br
    -rw-r--r--  1 nginx nginx 9.3K Jul 25  2016 bootstrap.min.js.gz

Example `clean` appended flag

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2

Example `clean` appended flag with `GGZIP=y` flag enabled

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2

Variables
===============

`brotli.sh` runs are logged to directory defined by variable `LOGDIR='/var/log/brotli'`. You can override this path in separate config file `brotli-config.ini` located in same directory as `brotli.sh` by setting your own `LOGDIR` variable path

    ls -lah /var/log/brotli/
    total 24K
    drwxr-xr-x   2 root root 4.0K Mar  5 14:03 .
    drwxr-xr-x. 13 root root 4.0K Mar  5 13:56 ..
    -rw-r--r--   1 root root  574 Mar  5 13:56 brotli.sh_050317-135652.log
    -rw-r--r--   1 root root  222 Mar  5 13:57 brotli.sh_050317-135701.log
    -rw-r--r--   1 root root  574 Mar  5 14:01 brotli.sh_050317-140151.log
    -rw-r--r--   1 root root  222 Mar  5 14:03 brotli.sh_050317-140341.log

Other variables you can override n separate config file `brotli-config.ini` located in same directory as `brotli.sh` include the user and group file permissions of the resulting brotli *.br compressed files:

    USER=nginx
    GROUP=nginx
    CHMOD=644