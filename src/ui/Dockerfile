#FROM ruby:2.2
FROM ubuntu:16.04
#RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
RUN apt-get update && \
    apt-get install -y ruby-full ruby-dev build-essential && \
    gem install bundler -v 2.3.26 --no-ri --no-rdoc 

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
#RUN bundle update --bundler
COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
