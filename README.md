brotli.sh
===============


`brotli.sh` tool to auto compress css and js files by specifying path on CentOS based Centmin Mod LEMP web stack servers. Appending clean flag on end of directory path will remove any `*.br` or `*.gz` compressed files

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

Example `clean` appended flag with `GZIP=y` flag enabled

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.gz
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.gz
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2

Centmin Mod Nginx + ngx_brotli dynamic module enable
===============

To properly utilise Brotli compression and this `brolti.sh` tool, your web server needs to be able to serve Brotli Content-Encoding headers to only web browsers that support it. For Nginx there is an [ngx_brotli](https://github.com/google/ngx_brotli) module which can be compiled into Nginx to support such. Centmin Mod [latest 123.09beta01 branch's Nginx server](https://centminmod.com/install.html) has built in support for [ngx_brotli](https://github.com/google/ngx_brotli) module that can optionally be enabled or disabled via persistent config file `/etc/centminmod/custom_config.inc` set variables below:

    NGXDYNAMIC_BROTLI='y'
    NGINX_LIBBROTLI='y'

Once variables set, you recompile Centmin Mod Nginx via `centmin.sh menu option 4` and will have [ngx_brotli](https://github.com/google/ngx_brotli) support enabled. Centmin Mod Nginx dynamic modules are loaded from `/usr/local/nginx/modules` directory via an include file `/usr/local/nginx/conf/dynamic-modules.conf` in `/usr/local/nginx/conf/nginx.conf`.

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

    curl -sI /dev/null -H"Accept-Encoding: gzip,br" localhost/brotlitest2/bootstrap.min.css
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

    curl -sI /dev/null -H"Accept-Encoding: gzip" localhost/brotlitest2/bootstrap.min.css   
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