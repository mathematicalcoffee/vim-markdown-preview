Vim Markdown Preview
====================

- [Intro](#intro)
- [Installation](#installation)
- [Usage](#usage)
- [Requirements](#requirements)
    - [Max OS X](#mac-os-x)
    - [Unix](#unix)
- [Options](#options)
    - [Writing to a local or temp file](#output)
    - [Deleting the output file](#temp)
    - [Save on buffer write](#toggle)
    - [Manual compiling](#manual)
    - [Pandoc command](#command)
    - [Browser](#browser)
    - [Github Flavoured Markdown](#github)
- [Behind the Scenes](#behind-the-scenes)

Intro
-----
A small Vim plugin for previewing markdown files in a browser.

The aim of this plugin is to be light weight with minimal dependencies. Thus, there is *no* polling engine or webserver involved.

Oct 2015: Modified to call `pandoc` by default and allow specification of the command (see [`vim_markdown_preview_command`](#command)).

![Screenshot](images/screenshot.gif?raw=true "Preview on buffer write using Unix")

Installation
------------

* With [Pathogen](https://github.com/tpope/vim-pathogen): Place `vim-markdown-preview/` in `.vim/bundle/`.
* With [Vundle](https://github.com/VundleVim/Vundle.vim):
    * Add `Plugin 'JamshedVesuna/vim-markdown-preview'` to your `.vimrc`.
    * Launch `vim` and run `:PluginInstall`

See more [Options](#options).

Usage
-----

By default, when in a `.markdown` or `.md` file, and  `Ctrl-p` is pressed, this plugin will either open a preview in your browser, or refresh your current preview (can be remapped, see [Options](#options)).

Pressing `Ctrl-k` will toggle whether compilation happens automatically on writing the file, for the current tab (by default it is off).

Your cursor will remain in Vim.

Requirements
------------

### Mac OS X:

* [Markdown](http://daringfireball.net/projects/markdown/) or [grip](https://github.com/joeyespo/grip) (for [GitHub flavoured markdown](#github))
* [Safari](https://www.apple.com/safari/)

### Unix:

* [Markdown](http://daringfireball.net/projects/markdown/) or [grip](https://github.com/joeyespo/grip) (for [GitHub flavoured markdown](#github))
* [xdotool](https://github.com/jordansissel/xdotool)
* [Google Chrome](https://www.google.com/chrome/browser/) or [other browser](https://github.com/JamshedVesuna/vim-markdown-preview/wiki/Use-other-browser-to-preview-markdown#ubuntu-or-debian)

Options
-------
All options have default values and work out of the box. If you prefer to change these, just add the following lines to your [.vimrc](http://vim.wikia.com/wiki/Open_vimrc_file) file.
Note that after changing an option, you have to restart Vim for the change to take effect.

<a name='output'></a>
### The `vim_markdown_preview_use_local` option

By default the output HTML file is `/tmp/vim-markdown-preview.html`. This avoids polluting your current directory, but also means that relative images to paths will not render properly. If you wish, you may instead have the output HTML file be generated in the current directory (as `current_file_name.html`, e.g. `README.md.html`), by setting this option to `1`.

Default: 0

Example: Render the output HTML file locally rather than a temp directory.
```vim
let vim_markdown_preview_use_local=1
```

<a name='temp'></a>
### The `vim_markdown_preview_temp_file` option

By default, this plugin keeps the rendered `.html` file. If you would automatically like to remove the html file after opening it in a browser, set this option to `1`. Note that removing the rendered html file with a slow browser may err. This can be helpful in conjuction with setting `vim_markdown_preview_use_local` to 1 if you do not wish to clutter your local directory, but you want images/links with relative paths to render in the HTML file.

Default: `0`

Example: Remove the rendered preview.
```vim
let vim_markdown_preview_temp_file=1
```

<a name='toggle'></a>
### The `vim_markdown_preview_on_write` and `vim_markdown_preview_toggle_hotkey` option

The plugin can do an automatic preview whenever you save the file. This is tab-specific. To enable it for the current tab, use `<Ctrl-k>`. To change this hotkey, set the `vim_markdown_preview_toggle_hotkey` option. Don't forget to add the single quotation marks.

Default: `'<C-k>'`

Example: Mapping Control M.
```vim
let vim_markdown_preview_toggle_hotkey='<C-m>'
```

By default, preview-on-write is initially disabled for each tab. To initially enable it for all markdown files (so that the first `C-k` will disable it), set `vim_markdown_preview_on_write` to 1.

Default: 0

Example: To have all markdown files preview automatically on write by default.
```vim
let vim_markdown_preview_on_write=1
```

<a name='manual'></a>
### The `vim_markdown_preview_hotkey` option

By default, this plugin maps `<C-p>` (Control p) to activate the preview. To remap Control p to a different hotkey, change the binding. Don't forget to add the single quotation marks.

Default: `'<C-p>'`

Example: Mapping Control M.
```vim
let vim_markdown_preview_hotkey='<C-m>'
```

<a name='command'></a>
### The `vim_markdown_preview_command` option

By default, this plugin uses `pandoc --toc --standalone -t html ` to compile the document.
You can change the command.

Example: adding `--mathjax` to the command:

```vim
let g:vim_markdown_preview_command = 'pandoc --mathjax --toc --standalone -t html '
```

<a name='browser'></a>
### The `vim_markdown_preview_browser` option

By default, if you are using Unix, [Google Chrome](https://www.google.com/chrome/) is the default browser. If you are on Mac OS X, [Safari](https://www.apple.com/safari/) is the default.
Note that bug [#16](https://github.com/JamshedVesuna/vim-markdown-preview/issues/16) does not allow cross operating system and browser support. See the [wiki page](https://github.com/JamshedVesuna/vim-markdown-preview/wiki/Use-other-browser-to-preview-markdown) for more help.

Default: `'Google Chrome'`

Example: Using Google Chrome.
```vim
let vim_markdown_preview_browser='Google Chrome'
```

<a name='github'></a>
### The `vim_markdown_preview_github` option

If you prefer [GitHub flavoured markdown](https://help.github.com/articles/github-flavored-markdown/) you need to install [Python grip](https://github.com/joeyespo/grip). Note that this makes a request to [GitHub's API](https://developer.github.com/v3/markdown/) (causing latencies) and may require [authentication](https://github.com/joeyespo/grip#access). This option also requires a network connection.

Default: `0`

Example: Use GitHub flavoured markdown.
```vim
let vim_markdown_preview_github=1
```

Behind The Scenes
-----------------

1. First, this plugin renders your markdown as html and creates a temporary html file.
    * If [image rendering](#toggle) is on, the html file will be in your [working directory](https://en.wikipedia.org/wiki/Working_directory).
    * Otherwise, it will be in `/tmp/`.
2. Next, this plugin either opens the html file or refreshes the Google Chrome or Safari tab.
    * If you are using GitHub flavoured markdown, `grip` will make a call to the GitHub API and retrieve the html.
3. Lastly, if you choose, this plugin will remove the temporary file.

![Screenshot](images/screenshot-with-images.gif?raw=true "Render images and preview on buffer write using Mac OS X")
