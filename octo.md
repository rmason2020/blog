---
layout: page
title: OCTO
description: Office of the CTO 
---

Various links and Blog Posts related to the VMware Office of the CTO.

{% for category in site.data.octo %}
{% assign items = category[1] | sort_natural: "name" %}
### {{ category[0] | capitalize }}:
{% for item in items %}
* [{{ item.name }}]({{ item.link }}){:target="_blank"}
  * {{ item.description }}
{% endfor %}
{% endfor %}

----

{% if site.comments_repo %}
{% include comments.html %}
{% endif %}
