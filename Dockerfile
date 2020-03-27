FROM jekyll/jekyll

WORKDIR /app
COPY . /app
RUN chmod 777 /app
#RUN git clone https://github.com/LCRERGO/lcrergo.github.io .
RUN gem install bundler
RUN bundle install

EXPOSE 4000
CMD ["jekyll", "s"]
