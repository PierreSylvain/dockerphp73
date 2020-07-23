FROM centos:7

# Install Apache
RUN yum -y update
RUN yum -y install httpd httpd-tools

# Install EPEL Repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Install PHP
RUN yum --enablerepo=remi-php73 -y install php php-bcmath php-cli php-common php-gd php-intl php-ldap php-mbstring \
    php-mysqlnd php-pear php-soap php-xml php-xmlrpc php-zip php-imap

# Update Apache Configuration
RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/User .*$/User ${APACHE_RUN_USER}/' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/Group .*$/Group ${APACHE_RUN_GROUP}/' /etc/httpd/conf/httpd.conf

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -f composer-setup.php

# Add normal user and use it for apache
RUN groupadd -g 1000 develop 
RUN adduser -g develop -u 1000 develop 

ENV APACHE_RUN_USER develop
ENV APACHE_RUN_GROUP develop

EXPOSE 80

WORKDIR /var/www/html

# Start Apache
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]


