---
title: "SimpleLocalize on Rails"
categories:
- Rails
- software
- technology
description: "Learn to integrate SimpleLocalize with Rails for efficient translation management. Ideal for developers on multi-language Rails apps."
---

When your application spans across multiple countries and languages, managing your translations using Rails' default locale files in git becomes too cumbersome. We recently moved a clients Rails app to [SimpleLocalize](https://simplelocalize.io/?rid=MMsFDINJt5NS) to give translators and developers a better workflow around translations. This is how we did it.

<!--more-->

## The setup

* [Rails](https://rubyonrails.org) 6 using [I18n](https://guides.rubyonrails.org/i18n.html) with the default backend spanning 7 different languages.
* Deployment to [Linode](https://www.linode.com/lp/refer/?r=10d4761839ce04859fb9d81decae7fb5c7a69818) servers via [Hatchbox](https://www.hatchbox.io/).
* [Circle CI](https://circleci.com/) runs tests and prepares deployments.

## Install the CLI

We're going to make use of [SimpleLocalizes CLI tool](https://simplelocalize.io/docs/cli/get-started/) to move translations around, so we start by installing that.

I am not a big fan of the `curl | bash` process outlined [in their docs](https://simplelocalize.io/docs/cli/get-started/), especially not when it then asks for root access 😬, so I've opted for downloading the CLI from [their releases page](https://github.com/simplelocalize/simplelocalize-cli/releases). But you do whatever fits you and your setup here, the important thing is that we get a `simplelocalize` command to run.

## Configure CLI for Rails defaults

Having installed the CLI we can run

```bash
simplelocalize init
```

to generate a default config file in the directory, we're in. Personally I prefer having config files stored in `/config`, so let's move it elsewhere there and add it to git.

```
mv simplelocalize.yml config/
git add config/simplelocalize.yml
```

Do note that this means we have to add a `-c` option to all `simplelocalize` commands for it to pick up our config file.

Now feel free to customize your config file as you please. I'd recommend the following options, though, as they match what we're used to in Rails:

```yaml
uploadPath: ./config/locales/application.{lang}.yml
uploadFormat: yaml
uploadOptions:
  - 'MULTI_LANGUAGE'
  - 'REPLACE_TRANSLATION_IF_FOUND'

downloadPath: ./config/locales/application.{lang}.yml
downloadFormat: yaml
downloadOptions:
  - 'MULTI_LANGUAGE'
  - 'WRITE_NESTED'
```

Most of the CLI commands need to be authorized with `--apiKey`. The API key can be found in the 'Integrations > Project credentials > API Key'.

You can keep your API key in the config file or you can provide it on the CLI whenever you call the CLI, that's up to you. Keeping secret keys out of git is a good practice, though. Ultimately, storing the API key in an environment variable is probably the best approach.

## Import your existing translations

After signing up for [SimpleLocalize](https://simplelocalize.io/?rid=MMsFDINJt5NS) and creating a project for your application, you want to seed the project with all your existing translations. Head to the "Data" tab in SimpleLocalize and choose YAML file under Import translations.

To configure the import for the format used by I18n's YAML files, use the following settings:

- Multi-language file: Even though each file only contains a single language, the file is formatted like a multi-language file with the locale name as a root-level key.
- Overwrite translations: Not strictly necessary, but if you end up importing more than once, it does come in handy.
- Leave Namespace empty.

Now, upload each of your language files one by one (sidenote, being able to choose and upload multiple files at once here would be great).

Alternatively, you can use the CLI to perform the above process, assuming you've configured everything as described:

```bash
simplelocalize -c config/simplelocalize.yml upload --apiKey $API_KEY
```

## Download translations to development

Now that SimpleLocalize is the ultimate source of truth for translations, we should remove them from our repository. You _could_ still have them in git, and it would ease some things (like deployment). We have found, though, that the overall cost in terms of merge conflicts and confusion as to what translations are the most recent makes that solution untenable.

So...

```bash
git rm config/locales/*
touch config/locales/.gitkeep
echo config/locales >> .gitignore
git add config/locales/.gitkeep
git commit -m "Remove translation files"
```

Now, your up-to-date translations is no more than a

```bash
simplelocalize -c config/simplelocalize.yml download --apiKey $API_KEY
```

away.

## Download translations during deployment

Now that we have removed our translations from the project, they'll no longer be included when we run a deployment. Instead we'll have to download the most recent translations from SimpleLocalize during deployment.

This application uses [Hatchbox](https://www.hatchbox.io/) for deployments, so the following applies directly to that service. However, you should be able to replicate this using whatever hosting provider you use.

During the build phase (we use a Custom build script) we can download the translations from SimpleLocalize using the CLI - assuming it's installed:

```bash
simplelocalize -c config/simplelocalize.yml download --apiKey $API_KEY
```

This is just like we do in development and you might consider wrapping this in a script that you can run whenever/wherever needed (we've got a `script/translations/pull`) that does exactly this.

During the pre-build phase we'll make sure the CLI is installed on the build server. Your milage may vary, but we found that downloading a specific release

How you install the CLI on your build server is up to you, but you could do it via a script like the following:

```bash
wget --no-verbose https://github.com/simplelocalize/simplelocalize-cli/releases/download/2.6.0/simplelocalize-cli-linux
mv simplelocalize-cli-linux ~/bin/simplelocalize
chmod a+x ~/bin/simplelocalize
```

## Download translations on CI

We use [Circle](https://circleci.com/) as our CI server and we need the translations downloaded there as well in order to run tests and build the project assets.

Unfortunately we ran into issues with the most recent versions of the CLI. Because Circle is running older versions of Ubuntu we can't run the newer CLI releases:

    simplelocalize: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.33' not found (required by simplelocalize)
    simplelocalize: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.34' not found (required by simplelocalize)

We ended up just installing a legacy version of the CLI (2.1.1), which works, and subsequently using it to download translations:

```bash
curl -s https://get.simplelocalize.io/2.1.1/install | bash
simplelocalize -c config/simplelocalize.yml download --apiKey $API_KEY
```

(on CI I am not too worried about the `curl | bash` pattern - should I be?)

## Closing notes

Now all that is left is inviting your developers and translators to SimpleLocalize and start localizing.
