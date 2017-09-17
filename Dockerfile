FROM ruby

RUN \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install curl && \
	curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 > phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
	tar -xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
	rm phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
	mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/ && \
	rm -r phantomjs-2.1.1-linux-x86_64

WORKDIR /usr/src/app
COPY Gemfile* /usr/src/app/
RUN bundle install
COPY . /usr/src/app

CMD ["./profiler.rb http://localhost ./profile.rb"]
