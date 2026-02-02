1.apache

```powershell
httpd
cat /etc/httpd/conf/httpd.conf
apache2
cat /etc/apache2/apache2.conf

/var/log/apache2/*log

grep -Ev '#|^$' apache2.conf | grep conf
IncludeOptional mods-enabled/*.conf
Include ports.conf
IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf

apachectl -t

httpd -M
apachectl -M

以 www-data 或 apache 身份
```

2.nginx

3.tomcat

```powershell
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-2.el9.x86_64
export JAVA_BIN=$JAVA_HOME/bin
export PATH=$JAVA_BIN:$PATH

mkdir /usr/share/tomcat/webapps/ROOT
```

