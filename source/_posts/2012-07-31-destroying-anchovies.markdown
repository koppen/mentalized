---
title: Destroying anchovies
date: '2012-07-31 13:45:39 +0200'
mt_id: 2135
categories:
- Rails
- programming
---
When ordering pizza from an unknown pizza joint, I used to order a number 7 without anchovies. I didn't know what pizza number 7 was, but I knew I didn't want anchovies.

The ensuing dialoge usually went like:

> Them: "But... number 7 doesn't have anchovies?"<br/>
> Me: "Perfect!"<br/>
> Them: "So... you want a number 7?"<br/>
> Me: "Yes. Without anchovies."<br/>
> Them: "..."<br/>

I didn't care about the pre-condition of my pizza; I only cared about the post-condition, where it should be without anchovies.

The pizza baker did care about the pre-condition; if the pizza did have anchovies, he'd have to remove them. In his mind, removing anchovies from a pizza without anchovies wasn't a request he could handle. In my mind, if the pizza didn't have anchovies, the request had already been fulfilled.

<!--more-->

## Anchovies, what the hell?

Consider the anchovies#destroy action of the PizzaBakerOnRails app:

    def destroy
      anchovies = Anchovies.find(params[:id])
      anchovies.destroy
    end

If the action cannot find the requested anchovies, it'll throw an exception, present a 404 error page to the user going "I cannot possibly remove anchovies that aren't there, what the heck are you talking about?".

Users think differently, though. They don't are about the current state, they care about the final state. "After clicking this button I want the pizza to not have any anchovies. Make it so".

## But Jakob, that never happens on real projects

The common case is a user double clicking a link or button. The first click on "Delete" actually deletes the object, the next click then tries to delete the same object, but throws up because the object no longer exists.

The user never sees the confirmation from the first request because the browser is busy processing the second response. In the end the user is left thinking, "eh, why can I not remove the anchovies?".

And when they refresh the ingredients list and it turns out the anchovies are gone, they'll go "What the... why did it say it couldn't remove them when it clearly did remove them. Stupid software". Or even worse; "stupid me".

## The friendlier pizza app

A more friendly way of destroying anchovies would be

    def destroy
      if anchovies = Anchovies.find_by_id(params[:id])
        anchovies.destroy
      end
    end

The end result is the same if the anchovies exist, and it has been improved if they don't exist.
