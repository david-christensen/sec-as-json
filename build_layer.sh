#!/usr/bin/env bash

mkdir ruby && mkdir ruby/gems

docker run --rm \
             -v $PWD:/var/layer \
             -w /var/layer \
             lambci/lambda:build-ruby2.7 \
             bundle install --path=ruby/gems --without test

# move directories and throw out cache
mv ruby/gems/ruby/* ruby/gems/ && \
    rm -rf ruby/gems/2.7.0/cache && \
    rm -rf ruby/gems/ruby

# Add lib directory
mkdir ruby/lib && \
  cp -r lib/ ruby/lib

rm -rf layer/gems_and_lib

mkdir -p layer/gems_and_lib/ruby

cp -r ruby layer/gems_and_lib/

# zip and clean-up
#zip -r layer/layer.zip ruby
rm -rf .bundle/ && rm -rf ruby
