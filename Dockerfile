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

#####################################
# Dusk Dependencies:
#####################################
USER root
ARG INSTALL_DUSK_DEPS=false
ENV INSTALL_DUSK_DEPS ${INSTALL_DUSK_DEPS}
RUN if [ ${INSTALL_DUSK_DEPS} = true ]; then \
  # Install required packages
  add-apt-repository ppa:ondrej/php \
  && apt-get update \
  && apt-get -y install zip wget unzip xdg-utils \
    libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 xvfb \
    gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi \
    xfonts-base xfonts-scalable x11-apps \

  # Install Google Chrome
  && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && dpkg -i --force-depends google-chrome-stable_current_amd64.deb \
  && apt-get -y -f install \
  && dpkg -i --force-depends google-chrome-stable_current_amd64.deb \
  && rm google-chrome-stable_current_amd64.deb \

  # Install Chrome Driver
  && wget https://chromedriver.storage.googleapis.com/2.31/chromedriver_linux64.zip \
  && unzip chromedriver_linux64.zip \
  && mv chromedriver /usr/local/bin/ \
  && rm chromedriver_linux64.zip \
;fi

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
apt-get install -yq nodejs build-essential

RUN npm install -g npm

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt remove cmdtest

RUN apt-get update && apt-get install yarn 

CMD ["php-fpm"]

EXPOSE 9000