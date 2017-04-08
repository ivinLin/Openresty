# Openresty 开发要点记录

### 安装
1. 下载 openresty 安装包，[去这里下载](http://openresty.org/cn/download.html)
2. 构建openresty，执行以下命令。
```
tar -xzvf openresty-VERSION.tar.gz
cd openresty-VERSION/
./configure
make
sudo make install
```
3. 在 mac 下，需要安装pcre 和openssl这两个库
```
brew update
brew install pcre openssl
```
4. 安装，执行以下命令进行安装
```
$ ./configure \
   --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/" \
   --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
   -j8
```
安装完成，在```/user/local/```目录下可以看到已经成功安装了 openresty， 在这个目录下，包含：
```
ProdeMacBook-Pro:template ivin$ cd /usr/local/openresty/
ProdeMacBook-Pro:openresty ivin$ ls -lrt
total 328
drwxr-xr-x   6 root  wheel     204 12 19 16:18 luajit
-rw-r--r--@  1 root  wheel  165176 12 19 16:18 resty.index
drwxr-xr-x@ 43 root  wheel    1462 12 19 16:18 pod
drwxr-xr-x   7 root  wheel     238 12 19 16:18 lualib
drwxr-xr-x   5 root  wheel     170 12 19 16:18 site
drwxr-xr-x   9 root  wheel     306 12 19 16:18 bin
drwxr-xr-x  11 root  wheel     374 12 19 18:44 nginx
```
其中：

luajit：是 lua解释器

resty&lualib:是执行需要依赖的 lua 库

nginx：nginx 执行包。

### location里边可以直接写 lua 代码
两种方式：

方式1：通过content_by_lua_block ，如在content_by_lua_block中写：

        location /{
        default_type text/html;
        content_by_lua_block {
            local args = ngx.req.get_uri_args();
            ngx.say(args.a);
        }
    }
        
++需要注意的是，注释代码一定要用‘--’++。

方式2：通过 content_by_lua_file 加载 lua 脚本。

        location /{
        default_type text/html;
        content_by_lua_file ../lua/redirect.lua;
    }
会自动执行 redirect.lua 这个脚本中的代码。

### 监听端口不能太小
设置了6666这个端口进行监听，发现在浏览器访问时经常无法访问，马蛋！

最好是可以是设置成大于10240的端口号。

### nginx.conf 中lua 脚本混合使用中的坑
1. 在 lua 代码中，注释使用的是```--```，but，在 nginx.conf 文件中的注释是```#```,很容易搞混：（

2. nginx.conf 中每行代码需要使用';'好结束，而 lua 代码不需要。

### 加载模板文件
加载方法：
1. ngin.conf文件中，在 server 模块内，location 外设置模板文件所在的目录路径。

        server{
            set $template_root "../template";
            location /{
                ...
                content_by_lua_file ../lua_script/test_template.lua;
            }
        }

2. 在 lua 代码中，定义模板操作对象，并调用 render方法将数据写入到模板文件中。代码示例test_template.lua：

        local template = require("resty.template")；
        local content = {
            title = "hello",
            desc = "this is a template test"
        };
        ...
        -- 将数据写入到模板文件中
        template.render("h1.html", content); 

h1.html 文件应该存放在上面设置的：```../template```目录中。
文件代码如下：

        <html>
            <head>
                <title>Page</title>
            </head>
            
            <body>
                <text>{* title *}</text>
                <text>{* desc *}</text>
            </body>
        </html>
        
再引申说下模板文件的语法：
        
        {(include_file)}：包含另一个模板文件；
    {* var *}：变量输出；
    {{ var }}：变量转义输出；
    {% code %}：代码片段；
    {# comment #}：注释；
    {-raw-}：中间的内容不会解析，作为纯文本输出；

**所以，在模板文件中，也是可以写 lua 脚本代码的哦：）**

### 加载第三方库
1. 在 http 模块内，server板块外调用 api 加载第三方库。

        http{
            #lua模块路径，其中”;;”表示默认搜索路径，默认到/usr/servers/nginx下找  
            lua_package_path "/usr/local/openresty/lualib/?.lua;;";  #lua 模块  
            lua_package_cpath "/usr/local/openresty/lualib/?.so;;";  #c模块
            server{
                ...
            }
            location /{
                ...
            }
        }
        
2. 在 lua 代码中引用需要的第三方库。

        local cjson = require(“cjson”)  
        local redis = require(“resty.redis”)  



