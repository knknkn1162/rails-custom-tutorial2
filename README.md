# README 

[![CircleCI](https://circleci.com/gh/knknkn1162/rails-custom-tutorial2.svg?style=shield)](https://circleci.com/gh/knknkn1162/rails-custom-tutorial2)

## Preface

:loudspeaker: Make it a rule to refer primary sources, official documents!! 

+ http://api.rubyonrails.org/

+ http://www.rubydoc.info/gems/rack

+ http://rspec.info/documentation/3.7/rspec-rails/

+ http://www.rubydoc.info/github/teamcapybara/capybara/master

## Preparation

### Gems

+ Rspec-rails

Add `rspec-rails` in GemFile and initalize as follows:

```bash
# see also, https://github.com/rspec/rspec-rails
rails g rspec:install
```

To install gems without production, exec `bundle install --without production`. With this option, the setting file `.bundle/config` is generated automatically.

----

+ factory_bot_rails

configure as the link, https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec.

----


+ bootstrap-saas


Be careful to add the following code in `app/assets/javascripts/application.js`:

```javascript
//= require jquery
//= require bootstrap-sprockets
```

See also the link https://github.com/twbs/bootstrap-sass


### Database setting for development & test.

Before migration, You should create new user and databases for development and test:

```bash
$ mysql -u root -p
# If you delete user, exec `drop user myuser`
> create user myapp_user@localhost identified by 'my_password'
> select Host, User from mysql.user;
+-----------+---------------+
| Host      | User          |
+-----------+---------------+
| localhost | myuser        |
| localhost | mysql.session |
| localhost | mysql.sys     |
| localhost | root          |
+--------- 

## Warning) This is a failure pattern:
# relogin with new user
# $ mysql -u myapp_user  -p 
# denied when create database from myapp_user, non-root user.
# mysql> create database myapp_user;
# ERROR 1044 (42000): Access denied for user 'myapp_user'@'localhost' to database 'myapp_development'

# you have to create database in only root user!
mysql> create database repeat_app_development;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+------------------------+
| Database               |
+------------------------+
| information_schema     |
| repeat_app_development | <= here is new database you made!
| sys                    |
+------------------------+
11 rows in set (0.00 sec)
mysql>  grant all privileges on repeat_app_development.* to repeat_app_user@localhost;
Query OK, 0 rows affected (0.01 sec)
# you can create test database in the same way! 
```

This work gets to use `rails db:migrate` in your development.

### Database setting for production

To use MySQL in production, install `mysql2` gem in the production and then follow the link, https://devcenter.heroku.com/articles/cleardb#provisioning-the-add-on.

### Configure database.yml

see `config/database.yml`!

### Circle CI

+ To reproduce circle CI environment locally, see https://circleci.com/docs/2.0/local-jobs/.

## development

### model

+ to confirm data model not to change database, exec `rails console --sandbox`. Also the command, `rails db:console` enables direct connection to database. 

### methods, variables

+ sessions ... The way to write spec is the link below: http://morizyun.github.io/ruby/rspec-rails-controller.html.

+ flash

+ cookies( `ActionDispatch::Cookies` ) .. cookies should be used in controllers only. See also https://relishapp.com/rspec/rspec-rails/v/3-7/docs/controller-specs/cookies. (The link describes controllers spec via `request.cookies` or `response.cookies`) Controller.cookies derives from Request.cookie_jar()
  + request.cookies .. http://www.rubydoc.info/gems/rack/Rack%2FRequest%2FHelpers:cookies (Rack provided)

## test

Note) assume to use RSpec + Capybara + Factory_bot

+ mock .. rspec-mocks( https://github.com/rspec/rspec-mocks : very detailed explanation than docs from relish )

## methods, variables

+ page .. The method that returns `Capybara::Session`. See http://www.rubydoc.info/github/teamcapybara/capybara/master/Capybara/DSL#page-instance_method

### gems

+ rails-controller-testing .. use capybara not only in features or views spec but also in controllers or views spec 

---

+ capybara

official document) http://www.rubydoc.info/github/jnicklas/capybara/Capybara
  + RSpecMatchers: http://www.rubydoc.info/github/jnicklas/capybara/Capybara/RSpecMatchers
  + Capybara::Session: http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session

---

### references

+ http://morizyun.github.io/ruby/ > rspec > controllers test, requests test

+ http://www.betterspecs.org/  .. How to test better rspec.

## production

### heroku

```bash

$ git push heroku master
# reset database
$ heroku maintenance:on
$ heroku pg:reset DATABASE
$ heroku run rails db:migrate
$ heroku run rails db:seed
$ heroku restart
$ heroku maintenance:off
# check your browser
$ heroku open
```

+ Introduce SSL

You can introduce SSL server easily in heroku!

1. Edit `config/environments/production.rb` and `config/puma.rb`

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
end
```

(To configure `config/puma.rb`, see https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#config )

2. set `./Procfile` as following. Be careful to set the file in top project file.

```
web: bundle exec puma -C config/puma.rb
```

# misc

## About Ruby

+ comment annotations .. https://github.com/bbatsov/ruby-style-guide#comment-annotations

## Questions

Q. when should be tested in feature spec? 

---

Q. how to test private method in controller? Currently, I tested along with before_filter.

---

Q. What kind of test should be checked? (Both normal and abnormal scenario?)

---

Q. how to deal with cookies in Helper module? (rspec guide shows that cookies should be used only in contoller spec, but railstutorial use it in helper module:( )

---

Q. What is the difference between yield and local variable in a partial?

A. The yield keyword motivates us to use blocks, whereas local variable to deal with just variable. The expression `yield(:sub)` layouts by calling `content_for` method.  See also, http://api.rubyonrails.org/v5.1/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for

---

Q. I often forgot to `do` keyword in rspec. For instance, I accidentally typed `it 'calls sth'` and returns, that should be `it 'calls sth' do`. Are there any linter to avoid this issue?

----

Q. The command, especially the rspec command is too long. Currently, I make the shorter alias via Makefile. Is there the other way to type commands quickly?

---
