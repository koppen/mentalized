---
title: Taming multipart emails in Rails
layout: post
categories:
- programming
- technology
---

[Rails](http://rubyonrails.org) makes sending out multipart emails [deceptively easy](http://guides.rubyonrails.org/action_mailer_basics.html#sending-multipart-emails). Just throw two appropriately named templates in your mailers view-directory, and `ActionMailer` takes care of everything for you.

But email is never as easy it seems. These are a few battle-tested tricks we have learned that makes emails manageable.

<!--more-->

Let's start with the issue of having two email templates. This leaves us with duplicated content; once in text and once in HTML, which seems wasteful and error-prone. What if, instead, we could just have one view and generate both HTML parts from that?

Luckily the problem of generating HTML from text content has been solved numerous times. For example, I am writing this article in [Markdown](https://daringfireball.net/projects/markdown) and you're most likely reading the HTML generated from this. Let's do the same for emails.


## Emails written in Markdown

[Markerb](https://github.com/plataformatec/markerb) allows you to generate multipart emails from a single view. The view is written in [Markdown](https://daringfireball.net/projects/markdown/syntax#link), which is delivered as the text part, but also rendered and delivered as the HTML part.

In short; you write your email in Markdown and it is sent as both text and HTML to your recipients.

* Small tip for [Devise](https://github.com/plataformatec/devise/) users; write your own mailer, use it (`config.mailer = "MyDeviseMailer"`)
), override `devise_mail` (see [this comment](https://github.com/plataformatec/devise/issues/2341#issuecomment-15349423))

An alternative to this is to go the other way; ie write your email in HTML and generate a text version from that. Some email delivery services like [Mandrill](https://mandrill.com) has an option to handle this conversion to text for you, but if you prefer to keep it in your application, [actionmailer-text](https://github.com/dblock/actionmailer-text) has your back.


## Layouts for emails

Another piece of content commonly duplicated across email templates is stuff like the header where you perhaps have a logo and the footer where stuff like sender info and unsubscribe links go.

ActionMailer comes with a perhaps not well known feature that allows us to use layouts for as emails, pretty much like we do for our controllers.

If you create ie `app/views/layouts/application_mailer.html.erb` and `app/views/layouts/application_mailer.text.erb` your `ApplicationMailer` should pick them up and include your email contents in the relevant `yield` parts of the layout.

Note that this also opens up for the possibility of using content blocks to pass content from the individual template to the layout:

    <% content_for :preheader_text do %>Hello!<% end %>

which can then be output anywhere in the layout:

    <%= content_for :preheader_text %>


## Images

It is of course possible to use all the usual asset helpers that we know from our "real" views. A common task is to include images. Aside from the usual issues with showing emails in HTML mails (primarily; many email clients won't), there is at least one Rails-gotcha to be aware of:

ActionMailer has its own `asset_host` setting. This means you should/can configure it separately:

    config.action_mailer.asset_host = "http://localhost:3000"

Also, remember to this in your `config/environments/production.rb` or your images will be broken in emails sent from your production server.


## Building the emails

### Use a template, dummy

Building HTML emails is hard. With inconsistencies between email clients and the lack of images and poor support for CSS you're in for a world of pain.

Look to people who have already solved the problem for you. [Litmus is giving away free email templates](https://litmus.com/resources/free-responsive-email-templates), so is [sendwithus](https://www.sendwithus.com/resources/templates) and [Mailgun](http://blog.mailgun.com/transactional-html-email-templates/) and I'm sure many others.

Seriously, grab one, and customize that. They went through the pain of tables within tables and testing in different email clients to make sure the rendered email looks at least somewhat correct in Outlook Web on Windows Mobile Phone 8 Edition or whatever.

### Preview emails in your browser

Rails 4.1 added a cool little feature called [Mailer Previews](http://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails). By subclassing `ActionMailer::Preview` you can setup "controllers" with "actions" allowing you to view the email you're building directly in a browser.

```ruby
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    DeviseMailer.reset_password_instructions(User.last, "randomtoken")
  end
end
```

With the above in place, you can visit [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers) and see what you're building. Note, this likely won't match what your recipients will actually see in their email client, but it's good enough for building out your templates.

### Deliver emails locally

An alternative to mailer previews is to use [Mailcatcher](http://mailcatcher.me/). It is a local SMTP server that you can send your emails to and it'll show them in a web interface without them ever leaving your machine.

Workflow-wise Mailcatcher is a bit heavier than mailer previews; the previews you can refresh to see changes, where as with Mailcatcher you'd have to actually send the email.

I personally prefer sending emails through to Mailcatcher at least a couple of times to make sure everything works. It can surface some issues, like missing asset hosts.

## Inline all the things!

A classic HTML email painpoint is CSS. [Email clients](https://www.emailsherpa.net/knows/email-client/) don't work with linked stylesheets and many strip out `<style></style>` blocks, so you're left leaving `style` attributes all over the place. This quickly gets unwieldly and unmanageable.

Luckily, [Premailer](https://github.com/premailer/premailer) exists. It (among other things) takes your CSS rules and inlines them, allowing you to keep your styles in a central place while still having them appear inline on the proper elements in the final email.

And using [premailer-rails](https://github.com/fphilipe/premailer-rails) you can simply add 2 lines to your `Gemfile` and not worry about any inline styles again.

* An alternatively to Premailer is [Roadie](https://github.com/Mange/roadie), which appears to be a more modern approach to the same task. We did, however, see better results with Premailer, your milage may vary.

## How about them links?

It isn't uncommon for email design to want to style a call-to-action-link to look like a huge button. However, since we're writing Markdown adding a class to a link is somewhat impossible. So we had to resort to including HTML in our email view:

    <a class="just-do-it" href="https://example.com/signup">Sign up</a>

Unfortunately that is shown exactly as it is in the text part of our emails. So we wanted something that goes through the text part of our email and makes sure that all links are converted to a textual representation of that link.

`Sign up: https://example.com/signup` is more readable to most people than the above HTML snippet and the URL will be made clickable by the email client, so it is just as usable - albeit not as fancy-looking.

We wrote a small [`ActionMailer` interceptor](http://guides.rubyonrails.org/action_mailer_basics.html#intercepting-emails) that does exactly this. You can grab it from [this gist](https://gist.github.com/koppen/00dbbe7572328b46e4f3) and you too will have squeaky clean text emails.

## Go forth and hypertext

With all of the above in place, building HTML emails in Rails is almost acceptable. Now comes the hard part; making them look and work acceptable across as many email clients as possible.

[Good](https://24ways.org/2009/rock-solid-html-emails/) [luck](http://kb.mailchimp.com/campaigns/ways-to-build/about-html-email) [with](http://blog.fogcreek.com/responsive-html-emails-a-different-strategy/) [that](https://support.sendgrid.com/hc/en-us/articles/200184928-HTML-Rendering-The-Do-s-and-Dont-s-of-Cross-Platform-Email-Design).

And a final [word of advice](https://mentalized.net/journal/2009/04/08/testing-html-emails-with-rails-and-litmus/): Use [Litmus](https://litmus.com) to see how your email is rendered across email clients. You'll be surprised at the differences.
