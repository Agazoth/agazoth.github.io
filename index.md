---
---
## Welcome my Powershell Blog

Here you will find random ramblings about my daily Powershell voyages. 



        {% for post in site.posts %}
          <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ post.url }}">{{ post.title }}</a></li>
        {% endfor %}
