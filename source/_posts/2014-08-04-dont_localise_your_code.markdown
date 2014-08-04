---
title: Don't localise your code
date: '2014-08-04 14:33:58 +0100'
published: true
categories:
- development
- programming
---
English isn't my first language. None of my customers are native english speakers. All of my coworkers speak danish.

But for some reason we write our code in english - and I'd argue this is a good thing.

<!--more-->

## Programming languages are english

Traditionally, programming languages have been english; all the keywords and standard libraries are english, thus to prevent mixing languages we create our business objects in english as well.

When we talk with stakeholders about business domain objects, we have to spend energy translating terms from the code to terms in their language - and vice versa when we go to implement their features. This adds a - perhaps not insignificant - cognitive load.

However, we read code way more than we talk with stakeholders. The total cognitive load from reading mixed language code is bound to be higher than the load of translating when talking.

## Resources are in english

It isn't just programming languages themselves that tend to be english. Pretty much every programming resource you can find is in english.

All developers use [Stack Overflow](http://stackoverflow.com) several times every week. This is in part made possible by having a common language.

Blog posts, tutorials, cheat sheets, podcasts by overwhelming majority are english (or perhaps this is just my bias that is showing).

## Language can be a barrier to growing your team

Imagine you've spent a few years working on the next Facebook killer application. In order to speed up development, you've hired a freelancer from far away.

But now there's a problem; you've written everything with danish variable names, danish class names, and comments. Your new hire doesn't speak a word of danish.

Why limit your talent pool like that? Except, of course, if you're worried your job is going to be outsourced to India, thus see localised variable names as a form of job security.

## It can be localised

It might make sense, though, for some very specific cases, to use the local language. In particular, if your application deals a lot with local law, the translation to english domain object names might be a risk. I would argue that perhaps a localised DSL would make a whole lot of sense here.

## Localised programming languages do exist

Localised programming languages do exists, though. Macros/formulas in Excel use localised names, and there is a project like [JS-i18n](http://fhtr.org/js-i18n/) that translates Javascript keywords between different languages.

It can be done, question is, should it?

## Thanks

Thanks a lot to everyone who chimed in on [my original question](https://twitter.com/mentalizer/status/296610644520747009), giving me fodder for this article: [@vruz](https://twitter.com/vruz), [@schourode](https://twitter.com/schourode), [@drunkcod](https://twitter.com/drunkcod), [@peter_lind](https://twitter.com/peter_lind), [@vingband](https://twitter.com/vingband), [@jacobat](https://twitter.com/jacobat), [@rasmusrn](https://twitter.com/rasmusrn), [@chopmo](https://twitter.com/chopmo), [@jesperbjensen](https://twitter.com/jesperbjensen), [@tutec](https://twitter.com/tutec).
