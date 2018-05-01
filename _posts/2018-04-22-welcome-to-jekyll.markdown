---
layout: post
title:  "Welcome to Jekyll!"
date:   2018-04-22 07:45:02 +0200
categories: blogpost
---
I spend this weekend making a blog page for posting my random Powershell scribblings. Since all help in Powershell is to be written in markdown, I thought it would be a good idea to make the page as markdown close as possible.

Github provides a perfect platform for this purpose. Using github for the page also places the blog closer to the Gists and Repositories used in the blog anyway.

Cute little demo of what markdown and Github Pages can do for Powershellers:

{% highlight powershell %}
Get-Process Powershell
Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
    543      45   166740      62800      20,34   1100   4 powershell
    705      50    93436      71792      42,98   1176   4 powershell
    525      41   101308      47988      17,94   6544   4 powershell
{% endhighlight %}

Getting this far was as hard a journey as any other involving getting to know new concepts and new notations.

I had a detour around a local Jekyll server. Since I work on a Windows 10 machine, that involved installing Debian on the Linux Subsystem. The [guide](https://jekyllrb.com/docs/windows/) for that, which I found after installing Debian, is actually quite exact. It starts with "is not officailly supported on Windows" disclaimer and continues with YOU SHOULD USE UBUNTU - Dang!

Well, couldn't be bothered with changing the distro and continued with the guide. After what seemed an eternity of installing and updating gems and Jekyll, I ended u with a local server, where I could test my new page, prior to publication.

Unfortunately my local server was not aware of the themes in Github, and I ended up calling it a day, before I had anything working.

New day, new plan. I decided to post publish directly to Github from VS Code. That worked quite a lot better. I started out with the cayman theme, but no matter what I tried, I had no luck making the site blog aware. The front page worked, and that was it.

Even though I do not have a lot of hair, I had even less after spending a few hours trying to make the blogpart work. Eventually I gave up, and changed the theme to minima, by copying the index.md, about.md, _config.yml and the _posts folder with content to my site, replacing all existing files, and suddenly my blogfiles were there.

For some reason there was no footer displaying my Twitter and Github pages. After a lot of playing around with the -layout files from the minima theme, I realized, that if you include these files in your own build, they override the ones in the gem. Then I remembered, that I at some poiunt had placed a blank footer.html file in the _includes folder. I deleted the file and presto, the footer was on all my pages.

I'm certain I'll have lots of fun and hours of frustration playing around with markdown and Github!
