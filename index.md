## Welcome to Richard Mason's Blog

Notes made getting started with this blog

Enable github pages, create a repo > settings pages.  You will need to create three DNS records, I use Go Daddy and had to create

A forwarding record to forward richm.cloud to www.richm.cloud

A cname record to point www.richm.cloud to rmason2020.github.io

A CAA record allowing letsencrypt.org to issue certificates for richm.cloud.  This last step is if you want to enforce https.

Visual Code installed, git added as an extension and file > preferences > settings > add the git binary location to git: path > sync changes.



### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

Install MacOS Monterey in Fusion

Download the Installer from AppStore but cancel once download finishes.

hdiutil create -size 15G -fs hfs+ -volname macOSInstaller -type SPARSEBUNDLE /Users/Shared/macOSInstaller

hddiutil attach /Users/Shared/macOSInstaller.sparsebundle


sudo /Applications/Install\ macOS\ Monterey/Contents/Resources/createinstallmedia --volume /Volumes/macOSInstaller —nointeraction

hdiutil makehybrid -o /Users/Shared/macOSInstaller /Users/Shared/macOSInstaller.sparsebundle


### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/rmason2020/blog/settings/pages). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://support.github.com/contact) and we’ll help you sort it out.
