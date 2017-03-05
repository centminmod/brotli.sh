brotli.sh

tool to auto compress css and js files by specifying path. Appending clean flag on end of directory path will remove any *.br compressed files

    Usage
    
    /root/tools/brotli.sh /path/to/parent/directory
    /root/tools/brotli.sh /path/to/parent/directory clean

Default is non-debug mode without any verbose output. You can set `DEBUG=y` in separate config file `brotli-config.ini` located ins ame directory as `brotli.sh` which will enable debug mode for more verbose output.

Example:

    ./brotli.sh /usr/local/nginx/html/brotlitest2
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.js --output /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    /usr/local/bin/bro --force --input /usr/local/nginx/html/brotlitest2/bootstrap.min.css --output /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chown nginx:nginx /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    chmod 644 /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br

Example clean appended flag

    ./brotli.sh /usr/local/nginx/html/brotlitest2 clean
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.js.br
    rm -rf /usr/local/nginx/html/brotlitest2/bootstrap.min.css.br
    
    cleaned up brotli *.br static css & js files
    recursively under /usr/local/nginx/html/brotlitest2
