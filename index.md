---
title: Instant Automation
---
#Instant Automation

Every once in a while I find time to put down a few lines, that are not code. They can be found here along with the code that drives them.


  <ul>
    {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ul>