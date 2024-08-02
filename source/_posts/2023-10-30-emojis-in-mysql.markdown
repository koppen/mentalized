---
title: "Emojis in MySQL, oh my 😣"
categories:
- software
- technology
description: "This is how we found and fixed 'Incorrect string value' errors after adding support for emojis to our MySQL 8 database."
---

Running a fairly old application with a similarily old MySQL database is a source of neverending challenges. These are my notes from trying to make a Rails 7 application backed by a MySQL 8 database support emojis.

<!--more-->

Even though we've jumped through all the hoops to make our [MySQL](https://www.mysql.com/) 8 database accept emojis (and other characters, but really, it's all about the emojis), we'd still see errors from our [exception tracker](https://www.honeybadger.io/) indicating stuff wasn't working as intended:

> ActiveRecord::StatementInvalid: Mysql2::Error: Incorrect string value: '\xF0\x9D\x97\xA5\...' for column 'description' at row 1

## Verify the database supports emojis

First of all, let's verify the character set configuration for our production MySQL database. After connecting to it from my local machine using the `mysql` client, we can run the following to see the character set and collation used for the column:

```sql
mysql> SELECT column_name, character_set_name, collation_name FROM information_schema.columns WHERE table_name = 'entries' and column_name='description';
+-------------+--------------------+--------------------+
| COLUMN_NAME | CHARACTER_SET_NAME | COLLATION_NAME     |
+-------------+--------------------+--------------------+
| description | utf8mb4            | utf8mb4_0900_ai_ci |
+-------------+--------------------+--------------------+
```

That looks correct, so let's see if we can insert an emoji:

```sql
mysql> insert into entries (description) values ('😄');
Query OK, 1 row affected (0.06 sec)

mysql> select id, description from entries where created_at is null;
+-------+-------------+
| id    | description |
+-------+-------------+
| 53828 | 😄            |
+-------+-------------+
```

It worked, so we now know the following:

- The column in the production database supports emojis (ie the `utf8mb4` character set).
- We can insert emojis into the column using the `mysql` client.

In other words, the database itself is not the problem here, let's move up the stack.

## Verify emojis can be inserted by ActiveRecord

This particulary application is hosted on [Heroku](https://heroku.com), so an interactive console with the full [Rails](https://rubyonrails.org/) application isn't far away:

```bash
npx heroku run rails console --sandbox --remote production
```

When connected we can run the [ActiveRecord](https://api.rubyonrails.org/classes/ActiveRecord/Base.html)-equivalent of the above SQL query:

```ruby
Entry.create!(:description => "😄")
```

This fails with the reported error message:

> app/vendor/bundle/ruby/3.1.0/gems/mysql2-0.5.5/lib/mysql2/client.rb:151:in `_query': Mysql2::Error: Incorrect string value: '\xF0\x9F\x98\x84' for column 'description' at row 1 (ActiveRecord::StatementInvalid)

Good('ish) news - at least we've got something reproducible and we can rule out browser-issues or any potentielt clientside problems.

- The column in the production database supports emojis (ie the `utf8mb4` character set).
- We can insert emojis into the column using the `mysql` client.
- We cannot insert emojis using ActiveRecord.

## Reproduce the problem locally

All of the above has been connected to the production resources, now let's see if we can reproduce the problem locally; that's a better place to fix problems, usually.

Firing up the local `rails console` and running the above code nets a different result, however:

```ruby
Entry.create!(:description => "😄")
 =>
#<Entry:0x000000010b50f120
```

It actually creates the `Entry`` with an emoji in `description` without problems. This means we're dealing with a production-only issue and explains why we haven't caught it during development. While it's annoying to have a problem only in production, it does let us add a bit more knowledge:

- The column in the production database supports emojis (ie the `utf8mb4` character set).
- We can insert emojis into the column using the `mysql` client.
- We cannot insert emojis using ActiveRecord in production.
- Application-specific settings or code is not the problem, since we can insert emojis using ActiveRecord in development.

## Verify connection details

MySQL has a few places where [character sets etc can be configured](https://dev.mysql.com/doc/refman/8.0/en/charset-connection.html):

- Client
- Connection
- Database
- Server

We've ruled out the server and the database in the first 2 steps, and the client in the last step (since we use [mysql2](https://github.com/brianmario/mysql2) in both development and production), so it's time to focus on the connection.

First of all, let's see how the correct settings look. In the `mysql` client window we opened to the database in step 1, we can run the following query:

```sql
mysql> SELECT * FROM performance_schema.session_variables WHERE VARIABLE_NAME IN (   'character_set_client', 'character_set_connection', 'character_set_results', 'collation_connection') ORDER BY VARIABLE_NAME;
+--------------------------+--------------------+
| VARIABLE_NAME            | VARIABLE_VALUE     |
+--------------------------+--------------------+
| character_set_client     | utf8mb4            |
| character_set_connection | utf8mb4            |
| character_set_results    | utf8mb4            |
| collation_connection     | utf8mb4_0900_ai_ci |
+--------------------------+--------------------+
```

This looks good, as expected. Both client, connection, and results use `utf8mb4`.

Now let's run the same query, but through our production ActiveRecord connection. In the `rails console`` window started in step 2, we can run the query as raw SQL:

```ruby
ActiveRecord::Base.connection.select_rows("SELECT * FROM performance_schema.session_variables WHERE VARIABLE_NAME IN ('character_set_client', 'character_set_connection', 'character_set_results', 'collation_connection') ORDER BY VARIABLE_NAME;")
=>
[["character_set_client", "utf8mb3"],
 ["character_set_connection", "utf8mb3"],
 ["character_set_results", "utf8mb3"],
 ["collation_connection", "utf8_general_ci"]]
```

That's not correct. `utf8mb3` is leaving us a full byte short, think of all the emojis we're missing! This would definitely explain the errors we're seeing. Time to add a crucial fact to our list of stuff we know:

- The column in the production database supports emojis (ie the `utf8mb4` character set).
- We can insert emojis into the column using the `mysql` client.
- We cannot insert emojis using ActiveRecord in production.
- Application-specific settings or code is not the problem, since we can insert emojis using ActiveRecord in development.
- The production connection is established with an encoding of `utf8mb3`, not `utf8mb4`.

## Time to fix it

Usually in a Rails application the database encoding is configured in `config/database.yml` and sure enough, we have this in development:

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
```

However, the application is hosted on Heroku where the database connection is configured as a connection string stored in a `DATABASE_URL` environment variable, and I have no idea how to specify an encoding via a URL.

Looking at the [documentation for our mysql2 adapter](https://github.com/brianmario/mysql2#using-active-records-database_url), we find the following example of a `DATABASE_URL`:

> mysql2://sql_user:sql_pass@sql_host_name:port/sql_db_name?option1=value1&option2=value2

As it turns out, options outside the usual adapter-, host- and usernames can be specified as query parameters. So we can tack on `?encoding=utf8mb4` to our existing `DATABASE_URL` variable on Heroku.

After having done so, we can run the above verifications again (remember to disconnect and reconnect the production Rails console):

```ruby
ActiveRecord::Base.connection.select_rows("SELECT * FROM performance_schema.session_variables WHERE VARIABLE_NAME IN ('character_set_client',
 'character_set_connection', 'character_set_results', 'collation_connection') ORDER BY VARIABLE_NAME;")
=>
[["character_set_client", "utf8mb4"],
 ["character_set_connection", "utf8mb4"],
 ["character_set_results", "utf8mb4"],
 ["collation_connection", "utf8mb4_0900_ai_ci"]]
```

And following up with an actual insert into the table:

```ruby
Entry.create!(:description => "😄")
=>
#<Entry:0x00007f027fa12790
```

Success! Hopefully this marks the end of a year-long process of adding support for handling emojis.
