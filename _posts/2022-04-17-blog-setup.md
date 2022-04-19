---
title: 'Blog Setup'
author: RichMason
layout: post
permalink: /blog-setup/
categories:
  - Tech
---
These are just a few notes to remind me what steps I took getting started with this blog.

Enable github pages, create a repo > settings > pages. You will need to create three DNS records, I use Go Daddy and had to create

A forwarding record to forward richm.cloud to www.richm.cloud

A cname record to point www.richm.cloud to rmason2020.github.io

A CAA record allowing letsencrypt.org to issue certificates for richm.cloud. This last step is if you want to enforce https.

Visual Code installed, git added as an extension and file > preferences > settings > add the git binary location to git: path > sync changes.

Used this bootstrap (https://github.com/chadbaldwin/simple-blog-bootstrap) to setup the blog using jekyll.
