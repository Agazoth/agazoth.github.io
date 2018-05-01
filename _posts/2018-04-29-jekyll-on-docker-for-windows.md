---
layout: post
title:  "Jekyll on Docker for Windows"
date:   2018-04-29 19:28:28 +0200
categories: blogpost
---
Creating a local Jekyll site has never been easier. Use a precreated Docker container to get up and running straight away and learn some cool new tech on the fly, if you haven't messed around with Docker before.

Download the Docker Installer [here](https://store.docker.com/editions/community/docker-ce-desktop-windows/)

Just follow the instructions [here](https://docs.docker.com/docker-for-windows/install/#install-docker-for-windows-desktop-app/) and you will be good. Stick with the Linux containers for the Jekyll setup - you can always change this later.

The installaton requires you to log out. 

If your Windows 10 is as vanilla as my Azure Windows 10, Docker will want to install Hyper-V and reboot.
![dockerlogout]({{ site.url }}/images/dockerhyperv.png)

After rebooting, Docker will ask you to create an account. It's free and great for keeping your containers available anhywhere.
![dockeraccount]({{ site.url }}/images/dockeraccount.png)

To get started with Jekyll, clone your favorite theme from Github:
[Themes](https://pages.github.com/themes/)

{% highlight powershell %}
cd C:\Dev\
git clone https://github.com/pages-themes/hacker.git

Cloning into 'hacker'...
remote: Counting objects: 269, done.
Receiving objects:  63% (167/269)   0 (delta 0), pack-reused 269Receiving objects:  54% (146/269)
Receiving objects: 100% (269/269), 71.20 KiB | 1.32 MiB/s, done.
Resolving deltas: 100% (121/121), done.
{% endhighlight %}

Start the Jekyll Container with this command:
{% highlight powershell %}
docker run --rm -v C:\lab\hacker\:/srv/jekyll -p 4000:4000 -it jekyll/jekyll jekyll serve
{% endhighlight %}

Docker will ask you to share the drive referenced in the command:
![dockershare]({{ site.url }}/images/dockershare.png)

Give it your credentials:
![dockersharecredentials]({{ site.url }}/images/dockersharecredential.png)

Docker will start to pull the container. Once it is done, you can browse your new Jekyll theme offline:
![hackerlocal]({{ site.url }}/images/hackerlocal.png)