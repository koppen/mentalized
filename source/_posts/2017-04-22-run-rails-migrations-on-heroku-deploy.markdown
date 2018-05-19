---
title: "Run migrations when deploying to Heroku"
categories:
- projects
- Substance Lab
- software
---

We use [Heroku](https://heroku.com) for running some of [our customers](https://substancelab.com/work) applications. Deploying by a simple `git push` is great, but running migrations as part of the process have always been a sore point - until now.

<!--more-->

## Do it yourself

The initial approach we took was to run migrations by hand after deploy:

    $ git push heroku
    $ heroku run rails db:migrate

This works to a degree, but has a few issues:

1. You have to remember to run them.
2. There is a gap between the release of the new version and the migration having run.
3. Deployment requires access to heroku-cli in order to run migrations. This can prove problematic when doing continous deployment from a CI server.
4. If migrations fail your application might be left in a non-functional state until the migration is fixed.

## Script it

The first issue is solvable by scripting deployments in a script - which you should do regardless. We usually have a script like bin/deploy that does the above:

    #!/usr/bin/env bash
    set -e

    echo "Deploying master to production"

    heroku git:remote --app YOUR_APP_NAME --remote production
    git push production
    heroku run --remote production rails db:migrate

This doesn't solve issues 2, 3, or 4, though.

## Custom buildpacks

Another solution is to use custom buildpacks to handle running your migrations. Herokus existing ruby-buildpack runs `rails assets:precompile` and other tasks on deploy for us. Unfortunately, `rails db:migrate` hasn't made the cut.

It is possible to fork the buildpack and run your own, or add a buildpack that handles migrations for you. This isn't a solution we have tried out, but do check out [Adam Pohoreckis post on the subject](http://gunpowderlabs.com/blog/automatically-run-migrations-when-deploying-to-heroku/).

## Herokus "release" phase

Luckily, Heroku has our backs. Late last year, they released a beta feature, called [Release Phase](https://devcenter.heroku.com/articles/release-phase), which does exactly what we need.

It allows us to specify a command that is run after the application has been deployed, but before the new version is made available.

In short, it allows us to add a "release" command to the applications Procfile (which you likely have in your root already):

    web: bundle exec puma -C config/puma.rb
    release: rake db:migrate

Now, when we push to our git remote on Heroku, the buildpacks prepare our application, and right before release our release command takes over:

    remote: -----> Launching...
    remote:  !     Release command declared: this new release will not be available until the command succeeds.
    remote:        Released v270
    remote:        https://my-awesome-application.herokuapp.com/ deployed to Heroku
    remote:
    remote: Verifying deploy... done.
    remote: Running release command......... done.

And just like that, your database is migrated before you release the new version to the public. The benefits of this are plentiful:

1. We cannot forget to run the migrations
2. The database has been migrated when your application is released
3. Migrations can be run by anyone/anything that can push to the git remote
4. If a migration fails, the deployment is halted, your database changes are rolled back ([you did use transactions, right?](https://devcenter.heroku.com/articles/release-phase#design-considerations)), and your application keeps running.

This is great for continous deployment and a stable deployment process in general.
