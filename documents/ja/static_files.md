Public
===
[戻る](../../README.md)

目次
<!--ts-->


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 10:32:40 UTC 2024 -->

<!--te-->

デフォルトでは、Basolatoはる静的ファイルへのリクエストを受け取ると、publicディレクトリの中を探します。

ファイルは以下のように提供されます。

./public/css/style.css -> http://example.com/css/style.css のようになります。

**注意：Basolatoは、他の人が読めるファイルのみを提供します。Unix/Linuxでは、chmod o+r ./public/css/style.cssで、これを確認することができます。**

本番環境では、静的ファイルはNginxなどのウェブサーバアプリケーションで提供されるべきです。

```nginx
# sample_nginx.conf
http {
        ##
        # Gzip Settings
        ##

        gzip on;
        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        location ~ .*\.(js|css|ico|jpg|gif|png|svg|)$ {
            root    your/project/dir/public;
            expire  30d;
            access_log off;
        }
}
```
