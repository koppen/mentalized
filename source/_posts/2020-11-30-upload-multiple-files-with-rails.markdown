---
title: "How to upload multiple files to a Rails model"
categories:
- development
- process
---

With the advent of [ActiveStorage](https://guides.rubyonrails.org/active_storage_overview.html) uploading files to your Rails application has become easier than ever. However, we recently encountered a blind spot; how to upload more than one file in a user-friendly manner.

<!--more-->

But Jakob, I hear you say, that's as easy as adding a `multiple="true"` attribute to your `input type="file"` field. And while that is correct, that solution has some issues - especially when it comes to the user experience.

In particular on desktop browsers, the file selector is... let's say, oldschool, and selecting more than one file is as easy as holding shift or option or ctrl or whatever while clicking or whatever magic formula is needed.

So we want a better way to upload many files.

## The simplest case

Let's imagine we'd like a sample model, `Post`, to have many photos. After installing ActiveStorage that's a matter of adding a single line in the model:

```ruby
has_many_attached :photos
```

The model can now manage its photos. We also need to add a UI widget for the user to choose the files to add, so we add a new field to `app/views/posts/_form.html.erb`:

```erb
<div class="photos">
  <%= form.label :photos %>
  <%= form.file_field :photos, :multiple => true %>
</div>
```

and we need to allow those attributes to be saved to the model in `app/controllers/posts_controller.rb`:

```ruby
def post_params
  params.require(:post).permit(:title, :photos => [])
end
```

And for good measure, let's actually show those photos again in `app/views/posts/show.html.erb`:

```erb
<div>
  <% @post.photos.each do |photo| %>
    <%= image_tag(photo, :width => 200) %>
  <% end %>
</div>
```

This gives us a perfectly fine file upload field where it's possible to select as many images as we want. We could stop here and everything would work, but it is not without issues.

## Issues

The issues are primarily around the user experience, and is actually mostly a problem on desktop browsers.

1. There is no way to tell what files were chosen after the fact.
2. There is no way to remove a file again if you happened to chose something wrong.
3. There is no way to add an extra file if you happened to forget a file.

Now, there are a ton of heavy file upload widgets that we could use, but we want something simple and as non-obtrusive as possible.

## Just repeat the file field

A solution to issue 1 and 3 above is so painfully straightforwared that I was surprised it even worked, when I tried it. Just add more, identical file upload fields to the form:

```ruby
<%# app/views/posts/_form.html.erb %>
<% 5.times do %>
  <%= form.file_field :photos, :multiple => true %>
<% end %>
```

Unfortunately this does not solve all our problems. We still can't remove an already chosen file, nor does it actually show all files if we've added more than one file to a single field. Also, it looks terrible.

It does, however, hint at a solution. Since we've now proven that repeating the same input field works, we can focus on improving the user interface around those input fields. So what if we instead of adding the fields up front, added them dynamically as needed?

## Enter Stimulus

We're doing Rails, we've got [Webpack](https://webpack.js.org/)[er](https://github.com/rails/webpacker), and we believe in UI sprinkles - let's bring in [Stimulus](https://stimulusjs.org/) to help us out here.

But let's first run through what exactly we need to do:

- We'll show a single input field.
- When the user adds one or more files to that input field, we'll add a new, empty input field for the user to add more files to.

After installing Stimulus and adding it to our application-pack, we can add a new Stimulus controller:

```jsx
import { Controller } from "stimulus"

export default class extends Controller {
  // filesTarget is going to contain the list of input elements we've added
  // files to - in other words, these are the input elements that we're going
  // to submit.
  static targets = ["files"]

  addFile(event) {
    // Grab some references for later
    const originalInput = event.target
    const originalParent = originalInput.parentNode

    // Move the input element that we've added files to, to the list of
    // selected elements
    this.filesTarget.append(originalInput)

    // Create a new blank, input field to use going forward
    const newInput = originalInput.cloneNode()

    // Clear the filelist - some browsers maintain the filelist when cloning,
    // others don't
    newInput.value = ""

    // Add it to the DOM where the original input was
    originalParent.append(newInput)
  }
}
```

Let's use that Stimulus controller in our form:

```erb
<div data-controller="multi-upload">
  <div class="photos">
    <%= form.label :photos %>
    <%= form.file_field :photos, :multiple => true, :data => {:action => "multi-upload#addFile"} %>
  </div>

  <div data-multi-upload-target="files"></div>
</div>
```

The above code is for Stimulus 2.0 - If you're on the older Stimulus 1.x, the last line inside the div needs to be

```html
  <div data-target="multi-upload.files"></div>
```

And voila, we've got an ever growing list of `input type="file"` fields.

## Prettier, better, stronger

However, this still leaves us with a long list of file input fields. As mentioned above that looks terrible - not to mention it's pretty confusing.

What I'd really like is something like the following:

- There is always one blank `input type="file"` field visible.
- When I select a file, it is moved to a list of files where I can see what I've already selected.

Let's add some styling for this to `app/assets/stylesheets/application.css`:

```css
.selected-file {
  background: #ddeeff;
  border-radius: 0.2em;
  margin-top: 1px;
  padding: 0.2em;
}

.selected-file input[type='file'] {
  display: none;
}
```

and we can then change `addFile` in `app/javascript/packs/controllers/multi_upload_controller.js` to

```jsx
addFile(event) {
  // Grab some references for later
  const originalInput = event.target
  const originalParent = originalInput.parentNode

  // Create an element that contains our input element
  const selectedFile = document.createElement("div")
  selectedFile.className = "selected-file"
  selectedFile.append(originalInput)

  // Create label (the visible part of the new input element) with the name of
  // the selected file.
  var labelNode = document.createElement("label");
  var textElement = document.createTextNode(originalInput.files[0].name);
  labelNode.appendChild(textElement);
  selectedFile.appendChild(labelNode);

  // Add the selected file to the list of selected files
  this.filesTarget.append(selectedFile)

  // Create a new input field to use going forward
  const newInput = originalInput.cloneNode()

  // Clear the filelist - some browsers maintain the filelist when cloning,
  // others don't
  newInput.value = ""

  // Add it to the DOM where the original input was
  originalParent.append(newInput)
}
```

and we've now created a fairly easy to use widget that allows users to select as many files as they want and upload them to our upload. Brilliant!
