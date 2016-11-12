#!/usr/bin/python -tt
'''
This script traverses a directory of Markdown files and generates static HTML
pages for my website. It is triggered by a post-merge Git hook, inside the
local repository on the web server. A Git pull is executed periodically on the
web server, and Git only executes the hook if there are updates.
'''

import hashlib
from markdown2 import markdown
import htmlmin
import os
import shutil
from string import Template
import argparse
import sys

argument_parser = argparse.ArgumentParser()
argument_parser.add_argument('-D', '--dry-run', action='store_true', dest='dry_run', help='run and report without making any changes')
argument_parser.add_argument('-d', '--debug', action='store_true', dest='debug', help='run in debug mode')
argument_parser.add_argument('--source', metavar='LOCAL', dest='source', help='define source directory')
argument_parser.add_argument('--destination', metavar='WEB', dest='destination', help='define web directory')
argument_parser.add_argument('--state', metavar='STATE', dest='state', help='define state directory')
argument_parser.add_argument('--no-minify', action='store_true', dest='no_minify', help='do not minify html')
args = argument_parser.parse_args()

LOCAL = '/var/zalza/zindilis.com'
if args.source:
    LOCAL = args.source
if LOCAL.endswith('/'):
    LOCAL = LOCAL[:-1]

STATE = '/var/zalza/state'
if args.state:
    STATE = args.state
if STATE.endswith('/'):
    STATE = STATE[:-1]

WEB = '/var/www/html'
if args.destination:
    WEB = args.destination
if WEB.endswith('/'):
    WEB = WEB[:-1]

for d in (LOCAL, WEB, STATE):
    if not os.path.isdir(d):
        if args.debug:
            print('Path not found: %s' % (d,))
        sys.exit()

BLOG = os.path.join(LOCAL, 'blog')
SKIP_D = ['.git']
SKIP_F = ['.gitignore', 'README.md']

SITE_NAME = 'Marios Zindilis'
SITE_URL = 'https://zindilis.com/'
SITE_AUTHOR = 'Marios Zindilis'
HEADER = '/home/marios/Public/Dropbox/Code/zalza/tmpl-header.html'
FOOTER = '/home/marios/Public/Dropbox/Code/zalza/tmpl-footer.html'
HEADER = '/opt/zalza/tmpl-header.html'
FOOTER = '/opt/zalza/tmpl-footer.html'
DEBUG = True
# schema.org stuff:
ITEMSCOPE_BLOG = ' itemscope itemtype="http://schema.org/BlogPosting"'
ITEMSCOPE_ARTICLE = ' itemscope itemtype="http://schema.org/Article"'
# Whether or not to recreate the blog pagination:
repaginate = False


def get_headers(absolute_source_path):
    '''
    Reads a source file, and returns key/value pairs as a dictionary.
    '''
    source_headers = {}
    lines = file(absolute_source_path).readlines()
    if lines[0].startswith('<!--'):
        for line in lines:
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip()
                source_headers[key] = value
            if line.endswith('-->\n'):
                break
    return source_headers


'''
Traverses the sources in LOCAL. For directories in LOCAL, it recreates the
directory structure under WEB and STATE directories. For files in LOCAL, it
generates HTML if the source file is Markdown, otherwise it copies the file
verbatim. In both cases, creates the state (MD5 hash of the file).
'''

for root, dirs, files in os.walk(LOCAL):
    for current_dir in dirs:
        section = root[len(LOCAL)+1:].split('/')[0]
        if (root == LOCAL and current_dir in SKIP_D) or section in SKIP_D:
            continue
        # Absolute and relative paths of source directory:
        source_path_abs = os.path.join(root, current_dir)
        source_path_rel = source_path_abs[len(LOCAL)+1:]

        web_path = os.path.join(WEB, source_path_rel)
        state_path = os.path.join(STATE, source_path_rel)
        if not os.path.isdir(web_path):
            os.makedirs(web_path)
            print('Created web directory: %s' % (web_path,))
        if not os.path.isdir(state_path):
            os.makedirs(state_path)
            print('Created state directory: %s' % (state_path,))

    for current_file in files:
        # The `section` is the first level subdirectory of LOCAL:
        section = root[len(LOCAL)+1:].split('/')[0]

        # Absolute and relative paths of source file:
        source_path_abs = os.path.join(root, current_file)
        source_path_rel = source_path_abs[len(LOCAL)+1:]

        if args.debug:
            print('---')
            print('SRC: %s' % (source_path_abs,))

        # Skip drafts, skip files in SKIP_F, skip directories in SKIP_D:
        if current_file.endswith('.draft'):
            if args.debug:
                print(' +-DBG: Skipped draft: %s' % (source_path_abs,))
            continue

        # Skip some files in the root local repository, such as `.gitignore`:
        if root == LOCAL and current_file in SKIP_F:
            if args.debug:
                print(' +-DBG: Skipped file: %s' % (source_path_abs,))
            continue

        # Skip some subdirectories that are first children of the local
        # directory of source documents, such as `.git`:
        if root != LOCAL and section in SKIP_D:
            if args.debug:
                print(' +-DBG: Skipped %s content: %s' % (section, source_path_abs))
            continue

        source_content = file(source_path_abs).read()
        source_hash = hashlib.md5(source_content).hexdigest()
        state_path = os.path.join(STATE, source_path_rel) + '.state'

        if (os.path.isfile(state_path) and
                file(state_path).read() == source_hash):
            continue

        print('Source: %s (in %s)' % (source_path_abs, section))

        # If source is not Markdown, copy verbatim and recreate the state:
        if not current_file.endswith('.md'):
            web_path = os.path.join(WEB, source_path_rel)
            shutil.copyfile(source_path_abs, web_path)
            print('Copied verbatim at: %s' % (web_path,))

            state_file = open(state_path, 'w')
            state_file.write(source_hash)
            state_file.close()
            print('Created state at: %s' % (state_path,))
            continue

        headers = get_headers(source_path_abs)
        # Keys of the tmpl dictionary are used in `string.Template` later:
        tmpl = {}
        tmpl['site_name'] = SITE_NAME
        tmpl['page_title'] = SITE_NAME
        if 'Title' in headers:
            tmpl['page_title'] += ' - %s' % (headers['Title'],)
        if 'Description' in headers:
            tmpl['description'] = headers['Description']
        elif 'Title' in headers:
            tmpl['description'] = headers['Title']
        else:
            tmpl['description'] = SITE_NAME
        tmpl['canonical'] = '%s%s' % (SITE_URL, source_path_rel)
        tmpl['canonical'] = os.path.splitext(tmpl['canonical'])[0] + '.html'
        tmpl['page_id'] = tmpl['canonical'][len(SITE_URL)-1:]
        tmpl['info'] = ''
        if 'Title' in headers:
            tmpl['info'] += '''
                <li>Title:
                    <span itemprop="name">%s</span>
                </li>''' % (headers['Title'],)
        if 'Author' in headers:
            tmpl['info'] += '''
                <li>Author:
                    <span itemprop="author">%s</span>
                </li>''' % (headers['Author'],)
        else:
            tmpl['info'] += '''
                <li>Author:
                    <span itemprop="author">%s</span>
                </li>''' % (SITE_AUTHOR,)
        if 'Editor' in headers:
            tmpl['info'] += '''
                <li>Editor:
                    <span itemprop="editor">%s</span>
                </li>''' % (headers['Editor'],)
        if 'First Published' in headers:
            tmpl['info'] += '''
                <li>First Published:
                    <meta itemprop="datePublished" content="%(fp)s">%(fp)s
                </li>''' % {'fp': headers['First Published']}
        if 'Last Updated' in headers:
            tmpl['info'] += '''
                <li>Last Updated:
                    <meta itemprop="dateModified" content="%(lu)s">%(lu)s
                </li>''' % {'lu': headers['Last Updated']}

        web_path = os.path.join(WEB, source_path_rel)
        web_path = os.path.splitext(web_path)[0] + '.html'

        page_header = Template(file(HEADER).read()).substitute(tmpl)
        page_header = page_header.decode('utf-8')
        page_footer = Template(file(FOOTER).read()).substitute(tmpl)
        page_footer = page_footer.decode('utf-8')

        content = page_header
        if section == 'docs':
            content += '<article%s>' % (ITEMSCOPE_ARTICLE,)
        elif section == 'blog':
            content += '<article%s>' % (ITEMSCOPE_BLOG)
            if not current_file.endswith('index.md'):
                repaginate = True
                print('set repaginate to %s' % (repaginate,))
        else:
            content += '<article>'

        content += markdown(source_content, extras=['fenced-code-blocks'])
        content += page_footer
        if not args.no_minify:
            content = htmlmin.minify(content, remove_comments=True)

        web_file = open(web_path, 'w')
        web_file.write(content.encode('utf-8'))
        web_file.close()
        print('URL: %s' % (tmpl['canonical'],))

        state_file = open(state_path, 'w')
        state_file.write(source_hash)
        state_file.close()


if repaginate:
    posts = {}
    pages = {}
    post = 0
    page = 0
    for traverse_root, traverse_dirs, traverse_files in os.walk(BLOG):
        for traverse_file in traverse_files:
            if traverse_file.endswith('.md'):
                source_path = os.path.join(traverse_root, traverse_file)
                source_path_date = get_headers(source_path)['First Published']
                posts[source_path_date] = source_path
    for date_published in sorted(posts.keys(), reverse=True):
        if post == 0:
            pages[page] = {}
        pages[page][post] = posts[date_published]
        post += 1
        if post == 10:
            post = 0
            page += 1
    for page in sorted(pages.keys()):
        d = {}
        d['site_name'] = SITE_NAME
        d['canonical'] = ''
        if page == 0:
            d['canonical'] = SITE_URL
            target_d = WEB
            target_f = os.path.join(target_d, 'index.html')
            d['page_title'] = SITE_NAME
        else:
            d['canonical'] = '%spage/%d.html' % (SITE_URL, page)
            target_d = os.path.join(WEB, 'page')
            if not os.path.isdir(target_d):
                os.makedirs(target_d)
            target_f = os.path.join(target_d, '%d.html' % (page))
            d['page_title'] = '%s - Page %d' % (SITE_NAME, page)
        d['description'] = d['page_title']
        target_f = open(target_f, 'w')

        content = Template(file(HEADER).read()).substitute(d)
        for post in sorted(pages[page].keys()):
            headers = get_headers(pages[page][post])
            content += '<article%s>' % (ITEMSCOPE_BLOG,)
            source_path_rel = pages[page][post][len(LOCAL):]
            href = os.path.splitext(source_path_rel)[0] + '.html'
            content += '''
                <h1>
                    <a href="%s">%s</a>
                </h1>''' % (href, headers['Title'])
            # Get content temporarily and manipulate:
            tmp_content = file(pages[page][post]).read()
            tmp_content = tmp_content.decode('utf-8')
            tmp_content = markdown(tmp_content, extras=['fenced-code-blocks'])
            skip_lines = False
            for line in tmp_content.split('\n'):
                if line.startswith('<h1>'):
                    continue
                if line.startswith('<ol class=') and 'breadcrumb' in line:
                    skip_lines = True
                    continue
                if skip_lines and line.startswith('</ol>'):
                    skip_lines = False
                    continue
                if skip_lines:
                    continue
                content += '%s\n' % (line.encode('utf-8'))
            content += '''
                <footer>
                    <span class="glyphicon glyphicon-time"></span>
                    Posted on %s
                </footer>''' % (headers['First Published'],)
            content += '</article>'

        content += '<ul class="pagination">'
        if page == 0:
            content += '<li class="disabled"><a href="#">Previous</a></li>'
        elif page == 1:
            content += '<li><a href="/">Previous</a></li>'
        else:
            content += '''
                <li>
                    <a href="/page/%d.html">Previous</a>
                </li>''' % (page - 1)

        for page_link in sorted(pages.keys()):
            if page_link == 0:
                if page == 0:
                    content += '<li class="active"><a href="/">0</a></li>'
                else:
                    content += '<li><a href="/">0</a></li>'
            else:
                if page == page_link:
                    content += '''
                        <li class="active">
                            <a href="/page/%d.html">%d</a>
                        </li>''' % (page_link, page_link)
                else:
                    content += '''
                        <li>
                            <a href="/page/%(pl)d.html">%(pl)d</a>
                        </li>''' % {'pl': page_link}

        if page == (len(pages.keys()) - 1):
            content += '<li class="disabled"><a href="#">Next</a></li>'
        else:
            content += '<li><a href="/page/%d.html">Next</a></li>' % (page + 1)

        content += '</ul>'

        target_f.write(content)
        target_f.close()
