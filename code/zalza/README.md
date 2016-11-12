Zalza
=====

**Zalza** was the Python script which I used to maintain my website, 
[zindilis.com][1]. before I switched to [Jekyll][2]. It traverses a directory
with the sources of the website (mostly written in Markdown), and produces HTML
files.

  [1]: https://zindilis.com/
  [2]: https://jekyllrb.com/

This script was triggered by a `post-merge` Git hook, inside the local 
repository of the Markdown sources, on the web server. A `git pull` runs 
periodically on the web server, as a cronjob:

    */10 * * * * cd /var/zalza/zindilis.com && git pull --quiet

...and Git only executes the hook if there are updates. Here's the hook:

    [marios@huey ~]$ cat /var/zalza/zindilis.com/.git/hooks/post-merge 
    #!/bin/bash 
    
    /home/marios/Public/Dropbox/Code/zalza/zalza.py

This code is released under the MIT License. See the LICENSE file for the full 
text of the license.
