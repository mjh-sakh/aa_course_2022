init:
	asdf install
	gem install bundler
	bundle install
	bundle update
	bundle binstub rspec-core

lint:
	bundle exec rubocop -a lib spec/*_spec.rb

test:
	bundle exec rspec -P spec/*spec.rb

reek:
	bundle exec reek lib/*.rb
