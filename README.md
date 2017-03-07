brotli.sh
===============

* Short Url: [centminmod.com/brotlistatic](https://centminmod.com/brotlistatic)
* Forum Guide: [https://community.centminmod.com/posts/45818/](https://community.centminmod.com/posts/45818/)


`brotli.sh` tool to auto compress css and js files by specifying path on [CentOS based Centmin Mod LEMP web stack](https://centminmod.com/) servers. Appending clean flag on end of directory path will remove any `*.br` or `*.gz` compressed files. I usually place my tools at `/root/tools` but you can place `brotli.sh` wherever you want.

    Usage
    
    /root/tools/brotli.sh /path/to/parent/directory
    /root/tools/brotli.sh /path/to/parent/directory clean
    /root/tools/brotli.sh /path/to/parent/directory display

You may want to run a cronjob to automatically run `brotli.sh` tool on a specific directory every 24hrs etc. Reason why is Nginx `gzip_static` and `brotli_static` directives will serve the pre-compressed `*.br` or `*.gz` files whenever they are detected. If you update your site's css or js files, then the pre-compressed `*.br` or `*.gz` will be out of date and need recompressing. You may want to add a Nginx or web server restart command to cronjob too.

brotli.sh Requirements
===============

* CentOS with YUM repo for pigz package or you can manually install pigz for your Linux distro before running `brotli.sh`
* git for installing Google Brotli binary from their Github repo
* bc package for file size and compression ratio calculations

brotli.sh Info
===============

First time you run `brotli.sh` tool, it will detect if Brotli binary is located at `/usr/local/bin/bro` and if pigz binary is located at `/usr/bin/pigz`. If they are not detected, `brotli.sh` tool will install Brotli binary from official source compile available from [Google's Brotli Github repo](https://github.com/google/brotli) and install pigz from YUM repo if available.

Default is to enable debug mode with verbose output which includes compression ratio (original size/compressed size). You can set `DEBUG=y` or `DEBUG=n` in separate config file `brotli-config.ini` located in same directory as `brotli.sh` which will enable or disabledebug mode for more verbose output.

Example running `brotli.sh` passing the directory path on command line `/usr/local/nginx/html/brotlitest2` and `GZIP=n` and `TIMEDSTATS=n` and `DEBUG=n`:

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap min.css
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.js

Example running `brotli.sh` passing the directory path on command line `/usr/local/nginx/html/brotlitest2` and `GZIP=n` and `TIMEDSTATS=n` and `DEBUG=y`:

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap min.css --output /usr/local/nginx/html/brotlitest2/bootstrap min.css.br
    [br compression ratio]: 7.50
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    [br compression ratio]: 7.50
    [br compress js 37045 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    [br compression ratio]: 4.24

Example running `brotli.sh` passing the directory path on command line `/usr/local/nginx/html/brotlitest2` and `GZIP=n` and `TIMEDSTATS=y` and `DEBUG=y`:

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap min.css --output /usr/local/nginx/html/brotlitest2/bootstrap min.css.br
    [br compress stats]: real: 0.14s user: 0.13s sys: 0.00s cpu: 98% maxmem: 7540 KB cswaits: 2
    [br compression ratio]: 7.50
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    [br compress stats]: real: 0.14s user: 0.14s sys: 0.00s cpu: 99% maxmem: 7540 KB cswaits: 1
    [br compression ratio]: 7.50
    [br compress js 37045 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    [br compress stats]: real: 0.04s user: 0.03s sys: 0.00s cpu: 97% maxmem: 3316 KB cswaits: 0
    [br compression ratio]: 4.24

If `GZIP=y` variable enabled, you also can use `gzip` or `pigz` to create compressed gzip static versions of css and js files along with brotli ones. If only 1 cpu thread is detected, `brotli.sh` will fall back to gzip binary. If more than 2 cpu threads detected, then use pigz multi-threaded gzip binary. If pigz is used, compression level 11 is used to enable [Zopfli](https://github.com/google/zopfli) based compression for gzip for more compressed files than what gzip level 9 compression can produce.

With `GZIP=y` and `TIMEDSTATS=n` and `DEBUG=n`

    /brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap min.css
    [gz compress]: /usr/local/nginx/html/brotlitest2/bootstrap min.css
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    [gz compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    [br compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.js
    [gz compress]: /usr/local/nginx/html/brotlitest2/bootstrap.min.js

With `GZIP=y` and `TIMEDSTATS=n` and `DEBUG=y`

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap min.css --output /usr/local/nginx/html/brotlitest2/bootstrap min.css.br
    [br compression ratio]: 7.50
    [gz compress css 121200 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap min.css
    [gz compression ratio]: 6.61
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    [br compression ratio]: 7.50
    [gz compress css 121200 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    [gz compression ratio]: 6.61
    [br compress js 37045 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    [br compression ratio]: 4.24
    [gz compress js 37045 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap.min.js
    [gz compression ratio]: 3.90

With `GZIP=y` and `TIMEDSTATS=y` and `DEBUG=y`

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap min.css --output /usr/local/nginx/html/brotlitest2/bootstrap min.css.br
    [br compress stats]: real: 0.14s user: 0.14s sys: 0.00s cpu: 99% maxmem: 7540 KB cswaits: 1
    [br compression ratio]: 7.50
    [gz compress css 121200 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap min.css
    [gz compress stats]: real: 0.41s user: 0.39s sys: 0.02s cpu: 100% maxmem: 5124 KB cswaits: 8
    [gz compression ratio]: 6.61
    [br compress css 121200 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    [br compress stats]: real: 0.14s user: 0.14s sys: 0.00s cpu: 99% maxmem: 7536 KB cswaits: 1
    [br compression ratio]: 7.50
    [gz compress css 121200 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap.min.css
    [gz compress stats]: real: 0.41s user: 0.38s sys: 0.02s cpu: 99% maxmem: 5124 KB cswaits: 8
    [gz compression ratio]: 6.61
    [br compress js 37045 bytes]: bro --quality 11 --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    [br compress stats]: real: 0.04s user: 0.03s sys: 0.00s cpu: 97% maxmem: 3316 KB cswaits: 0
    [br compression ratio]: 4.24
    [gz compress js 37045 bytes]: pigz -11k -f /usr/local/nginx/html/brotlitest2/bootstrap.min.js
    [gz compress stats]: real: 0.09s user: 0.08s sys: 0.00s cpu: 100% maxmem: 3084 KB cswaits: 7
    [gz compression ratio]: 3.90

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

Example `clean` appended flag running `brotli.sh` passing the directory path on command line `/usr/local/nginx/html/brotlitest2` withn `clean` appended

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2

Example `clean` appended flag with `GZIP=y` flag enabled

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2

Added `display` flag you can append on the end to just find and display all `*.br` and `*.gz` compressed css and js files.

    ./brotli.sh /usr/local/nginx/html/brotlitest2 display
    
    Listing all *.br and *.gz css and js files
    
    /usr/local/nginx/html/brotlitest2/cm-jquerymin-pagespeed.js.br
    /usr/local/nginx/html/brotlitest2/cm-pagespeed.css.gz
    /usr/local/nginx/html/brotlitest2/bootstrap min.css.br
    /usr/local/nginx/html/brotlitest2/cm-jquerymin-pagespeed.js.gz
    /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    /usr/local/nginx/html/brotlitest2/cm-pagespeed.css.br
    /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    /usr/local/nginx/html/brotlitest2/bootstrap min.css.gz
    /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz
    /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br


Centmin Mod Nginx + ngx_brotli dynamic module enable
===============

To properly utilise Brotli compression and this `brolti.sh` tool, your web server needs to be able to serve Brotli Content-Encoding headers to only web browsers that support it. For Nginx there is an [ngx_brotli](https://github.com/google/ngx_brotli) module which can be compiled into Nginx to support such. Centmin Mod [latest 123.09beta01 branch's Nginx server](https://centminmod.com/install.html) has built in support for [ngx_brotli](https://github.com/google/ngx_brotli) module that can optionally be enabled or disabled via persistent config file `/etc/centminmod/custom_config.inc` set variables below:

    NGXDYNAMIC_BROTLI='y'
    NGINX_LIBBROTLI='y'

Once variables set, you recompile Centmin Mod Nginx via `centmin.sh menu option 4` and will have [ngx_brotli](https://github.com/google/ngx_brotli) support enabled. Centmin Mod Nginx dynamic modules are loaded from `/usr/local/nginx/modules` directory via an include file `/usr/local/nginx/conf/dynamic-modules.conf` in `/usr/local/nginx/conf/nginx.conf`.

`centmin.sh menu option 4`

    --------------------------------------------------------
         Centmin Mod Menu 123.09beta01 centminmod.com     
    --------------------------------------------------------
    1).  Centmin Install
    2).  Add Nginx vhost domain
    3).  NSD setup domain name DNS
    4).  Nginx Upgrade / Downgrade
    5).  PHP Upgrade / Downgrade
    6).  XCache Re-install
    7).  APC Cache Re-install
    8).  XCache Install
    9).  APC Cache Install
    10). Memcached Server Re-install
    11). MariaDB MySQL Upgrade & Management
    12). Zend OpCache Install/Re-install
    13). Install/Reinstall Redis PHP Extension
    14). SELinux disable
    15). Install/Reinstall ImagicK PHP Extension
    16). Change SSHD Port Number
    17). Multi-thread compression: pigz,pbzip2,lbzip2...
    18). Suhosin PHP Extension install
    19). Install FFMPEG and FFMPEG PHP Extension
    20). NSD Install/Re-Install
    21). Update - Nginx + PHP-FPM + Siege
    22). Add Wordpress Nginx vhost + Cache Plugin
    23). Update Centmin Mod Code Base
    24). Exit
    --------------------------------------------------------
    Enter option [ 1 - 24 ] 

In `/usr/local/nginx/conf/nginx.conf` contains include file to load Nginx dynamic modules

    include /usr/local/nginx/conf/dynamic-modules.conf;

And also contains an include file with actual Nginx Brotli settings

    include /usr/local/nginx/conf/brotli_inc.conf;

Contents of `/usr/local/nginx/conf/dynamic-modules.conf` will contain Nginx Brotli's dynamic and static modules

    load_module "modules/ngx_http_brotli_filter_module.so";
    load_module "modules/ngx_http_brotli_static_module.so";

Contents of `/usr/local/nginx/conf/brotli_inc.conf` with ngx_brotli settings

    /usr/local/nginx/conf/brotli_inc.conf
    brotli on;
    brotli_static on;
    brotli_min_length 1000;
    brotli_buffers 32 8k;
    brotli_comp_level 5;
    brotli_types text/plain text/css text/xml application/javascript application/x-javascript application/xml application/xml+rss application/ecmascript application/json image/svg+xml;

With Centmin Mod Nginx's Brotli module enabled, this will configure both Brotli on the fly compression as well as support Brotli static file serving if a `*.br` extension file is detected. To test, you can use `curl` command with appropate Accept-Encoding directives for `gzip` and `br`.

Curl content encoding `gzip,br` check for Centmin Mod Nginx based server with ngx_brotli enabled. Check for `Content-Encoding: br` to confirm that Nginx is serving Brotli compressed version of the css or js file.

    curl -sI /dev/null -H"Accept-Encoding: gzip,br" https://domain.com/brotlitest2/bootstrap.min.css
    HTTP/1.1 200 OK
    Date: Sun, 05 Mar 2017 16:39:04 GMT
    Content-Type: text/css
    Content-Length: 16149
    Last-Modified: Mon, 25 Jul 2016 16:08:01 GMT
    Connection: keep-alive
    Vary: Accept-Encoding
    ETag: "57963961-3f15"
    Content-Encoding: br
    Server: nginx centminmod
    X-Powered-By: centminmod
    Expires: Tue, 04 Apr 2017 16:39:04 GMT
    Cache-Control: max-age=2592000
    Access-Control-Allow-Origin: *
    Cache-Control: public, must-revalidate, proxy-revalidate

Curl content encoding `gzip` check for Centmin Mod Nginx based server with ngx_brotli enabled. Check for `Content-Encoding: gzip` to confirm that Nginx is serving Gzip compressed version of the css or js file.

    curl -sI /dev/null -H"Accept-Encoding: gzip" https://domain.com/brotlitest2/bootstrap.min.css   
    HTTP/1.1 200 OK
    Date: Sun, 05 Mar 2017 16:40:19 GMT
    Content-Type: text/css
    Content-Length: 18322
    Last-Modified: Mon, 25 Jul 2016 16:08:01 GMT
    Connection: keep-alive
    Vary: Accept-Encoding
    ETag: "57963961-4792"
    Content-Encoding: gzip
    Server: nginx centminmod
    X-Powered-By: centminmod
    Expires: Tue, 04 Apr 2017 16:40:19 GMT
    Cache-Control: max-age=2592000
    Access-Control-Allow-Origin: *
    Cache-Control: public, must-revalidate, proxy-revalidate

Centmin Mod Nginx with ngx_brotli enabled

> nginx -V
> nginx version: nginx/1.11.10
> built by gcc 6.2.1 20160916 (Red Hat 6.2.1-3) (GCC) 
> built with OpenSSL 1.1.0e  16 Feb 2017
> TLS SNI support enabled
> configure arguments: --with-ld-opt='-ljemalloc -Wl,-z,relro -Wl,-rpath,/usr/local/lib' --with-cc-opt='-m64 -march=native -g -O3 -fstack-protector-strong -fuse-ld=gold --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wno-deprecated-declarations -gsplit-dwarf' --sbin-path=/usr/local/sbin/nginx --conf-path=/usr/local/nginx/conf/nginx.conf --with-http_stub_status_module --with-http_secure_link_module --add-module=../nginx-module-vts --with-libatomic --with-http_gzip_static_module --add-dynamic-module=../ngx_brotli --add-dynamic-module=../ngx_pagespeed-1.12.34.2-beta --with-http_sub_module --with-http_addition_module --with-http_image_filter_module=dynamic --with-http_geoip_module --with-stream_geoip_module --with-stream_realip_module --with-stream_ssl_preread_module --with-threads --with-stream=dynamic --with-stream_ssl_module --with-http_realip_module --add-dynamic-module=../ngx-fancyindex-0.4.0 --add-module=../ngx_cache_purge-2.3 --add-module=../ngx_devel_kit-0.3.0 --add-module=../set-misc-nginx-module-0.31 --add-module=../echo-nginx-module-0.60 --add-module=../redis2-nginx-module-0.13 --add-module=../ngx_http_redis-0.3.7 --add-module=../memc-nginx-module-0.17 --add-module=../srcache-nginx-module-0.31 --add-module=../headers-more-nginx-module-0.32 --with-pcre=../pcre-8.40 --with-pcre-jit --with-zlib=../zlib-1.2.11 --with-http_ssl_module --with-http_v2_module --with-openssl=../openssl-1.1.0e


Configuration Variables
===============

`brotli.sh` can specify FILE_MINSIZE variable to define the minimum size of css or js file to be precompressed. Any files greater than FILE_MINSIZE will skip compression routines. Default is set to 1048576 bytes.

    FILE_MINSIZE='1048576'

`brotli.sh` runs are logged to directory defined by variable `LOGDIR='/var/log/brotli'`. You can override this path in separate config file `brotli-config.ini` located in same directory as `brotli.sh` by setting your own `LOGDIR` variable path

    ls -lah /var/log/brotli/
    total 24K
    drwxr-xr-x   2 root root 4.0K Mar  5 14:03 .
    drwxr-xr-x. 13 root root 4.0K Mar  5 13:56 ..
    -rw-r--r--   1 root root  574 Mar  5 13:56 brotli.sh_050317-135652.log
    -rw-r--r--   1 root root  222 Mar  5 13:57 brotli.sh_050317-135701.log
    -rw-r--r--   1 root root  574 Mar  5 14:01 brotli.sh_050317-140151.log
    -rw-r--r--   1 root root  222 Mar  5 14:03 brotli.sh_050317-140341.log

Other variables you can override in separate config file `brotli-config.ini` located in same directory as `brotli.sh` include the user and group file permissions of the resulting brotli *.br compressed files:

    USER=nginx
    GROUP=nginx
    CHMOD=644
    DBEUG=n
    TIMEDSTATS=n
    BROTLI_LEVEL=11
    GZIP=y
    GZIP_LEVEL=11
    LOGDIR='/var/log/brotli'
    FILETYPES=( "*.css" "*.js" )
    FILE_MINSIZE='1048576'