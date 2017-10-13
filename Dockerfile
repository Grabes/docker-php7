FROM johnpbloch/phpfpm:7.1

RUN curl -L https://phar.phpunit.de/phpunit.phar > /tmp/phpunit.phar \
	&& chmod +x /tmp/phpunit.phar \
	&& mv /tmp/phpunit.phar /usr/local/bin/phpunit

RUN apt-get update && apt-get install -y \
	git \
	subversion \
	wget \
	libxml2-dev \
	ssmtp \
  vim


RUN docker-php-ext-install pcntl && \
		docker-php-ext-install soap
RUN echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

COPY ./aliases.sh /root/aliases.sh
RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source /root/aliases.sh" >> ~/.bashrc && \
	echo "" >> ~/.bashrc && \
	sed -i 's/\r//' /root/aliases.sh && \
	sed -i 's/^#! \/bin\/sh/#! \/bin\/bash/' /root/aliases.sh

CMD ["php-fpm"]

EXPOSE 9000