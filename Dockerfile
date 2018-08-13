FROM ruby:2.5.1
WORKDIR /app

RUN wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.00.27.tar.gz && \
  tar -xzf freetds-1.00.27.tar.gz && \
  cd freetds-1.00.27 && \
  ./configure --prefix=/usr/local --with-tdsver=7.3 && \
  make && \
  make install

COPY Gemfile Gemfile.lock ./
RUN bundle check || bundle install

COPY . /app
EXPOSE 3000

CMD rails s
