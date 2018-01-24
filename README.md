# README 

## Preparation

### Gems

+ Rspec-rails

Add `rspec-rails` in GemFile and initalize as follows:

```bash
# see also, https://github.com/rspec/rspec-rails
rails g rspec:install
```

To install gems without production, exec `bundle install --without production`. With this option, the setting file `.bundle/config` is generated automatically.

+ factory_bot_rails

configure as the link, https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec.


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

## development

### model

+ to confirm data model not to change database, exec `rails console --sandbox`. Also the command, `rails db:console` enables direct connection to database. 

## test

### gems

+ rails-controller-testing .. use capybara not only in features or views spec but also in controllers or views spec 

---

+ capybara

official document) http://www.rubydoc.info/github/jnicklas/capybara/Capybara
  + RSpecMatchers: http://www.rubydoc.info/github/jnicklas/capybara/Capybara/RSpecMatchers
  + Capybara::Session: http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session

---

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
```
