# Get the base.
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Detroit

# These should be overridden with the --build-arg argument during build.
# www-data by default gets uid 33 and gid 33.
ARG HOST_USER_GID=33
ARG HOST_USER_ID=33

# Set active user.
USER root

# Install packages
RUN \
	echo ""                                                      && \
	# Update
	apt-get update                                               && \
	echo ""                                                      && \
	# Install curl and apt-utils and locales
	apt-get -y --no-install-recommends install apt-utils         && \
	apt-get -y --no-install-recommends install locales curl wget && \
	echo ""                                                      && \
	# Set some environment variables and locale.
	locale-gen en_US.UTF-8                                       && \
	dpkg-reconfigure locales                                     && \
	export LANGUAGE=en_US.UTF-8                                  && \
	export LANG=en_US.UTF-8                                      && \
	export LC_ALL=en_US.UTF-8                                    && \
	echo ""                                                      && \
	# Set timezone
	echo "America/Detroit" > /etc/timezone                       && \
	echo ""                                                      && \
	# Install
	apt-get -y --no-install-recommends install apt-utils         && \
	echo ""                                                      && \
	# Install
	apt-get -y --no-install-recommends install       \
		software-properties-common                   \
		gcc-avr binutils-avr avr-libc                \
		zip unzip                                    \
		sqlite3                                      \
		wget                                         \
		nano                                         \
		apt-transport-https                          \
		ca-certificates                              \
		curl                                         \
		apache2                                      \
		apache2-utils                                \
		php7.2                                       \
		php-curl php-json php-dom php-pear php-fpm   \
		php-dev php-json php-zip php-curl php-xmlrpc \
		php-gd php-mysql php-mbstring php-xml        \
		php-dom libapache2-mod-php                   \
		php7.2-sqlite                                \
		libapache2-mod-php7.2                        \
		git-core                                     \
		build-essential                              \
		openssl                                      \
		libssl-dev                                   \
		python                                       \
		nodejs                                       \
		ncdu                                         \
		                                                         && \
	echo ""                                                      && \
	curl -L https://npmjs.org/install.sh | sh                    && \
	npm install terser -g                                        && \
	echo ""                                                      && \
	# Configure Apache.
	a2enmod php7.2                                               && \
	a2enmod rewrite                                              && \
	a2dismod mpm_event                                           && \
	a2enmod mpm_prefork                                          && \
    echo ""                                                      && \
	# Clean up caching and unneeded packages.
	apt-get -y --purge autoremove gcc                            && \
	apt-get -y autoclean                                         && \
	apt-get -y autoremove                                        && \
	rm -rf /var/lib/apt/lists/*                                  && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/                        && \
	echo " "

# Change the UID and GID of the www-data (apache, 33:33) user to 1000:1000.
# Find any files with the previous UID and/or GID and update.
# Skip /proc, /sys, and /var/www/site.
RUN \
	old_gid=$(id -g www-data) && \
	old_uid=$(id -u www-data) && \
	groupmod -g $HOST_USER_GID www-data && \
	usermod  -u $HOST_USER_ID  www-data && \
	find / -path "/var/www/site" -prune -o -path "/sys" -prune -o -path "/proc" -prune -o -group $old_gid -exec chgrp -h www-data {} \; && \
	find / -path "/var/www/site" -prune -o -path "/sys" -prune -o -path "/proc" -prune -o -user  $old_uid -exec chown -h www-data {} \;

# Create the MOUNT directory
RUN \
	mkdir /var/www/site       && \
	mkdir /var/www/site/MOUNT && \
	echo ""                   && \
	echo DONE                 && \
	echo ""

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Add the redirector file.
# ADD index_redirector.php          /var/www/site/index.php

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND
