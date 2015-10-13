"============================================================
"                    Vim Markdown Preview
"   git@github.com:JamshedVesuna/vim-markdown-preview.git
"============================================================
" Usage: ^P to enable on-write in that tab.
" Problem: it's opening a new browser tab every time?
"
let b:vim_markdown_preview_browser = get(g:, 'vim_markdown_preview_browser', 'Google Chrome')
" either 0 (temp file) or 1 (local file)
let b:vim_markdown_preview_temp_file = get(g:, 'vim_markdown_preview_temp_file', 0)
let b:vim_markdown_preview_toggle = get(g:, 'vim_markdown_preview_toggle', 0)
let b:vim_markdown_preview_github = get(g:, 'vim_markdown_preview_github', 0)
let b:vim_markdown_preview_command = get(g:, 'vim_markdown_preview_command', 'pandoc --toc --standalone -t html ')
let b:vim_markdown_preview_on_write = get(g:, 'vim_markdown_preview_on_write', 0)

if !exists("g:vim_markdown_preview_hotkey")
    let g:vim_markdown_preview_hotkey='<C-p>'
endif

" o'wise disabled by default.
" t:vim_markdown_preview_enabled: -1 means default to 
function! Vim_Markdown_Preview_Toggle_On_Write()
  if !exists("t:vim_markdown_preview_on_write")
    let t:vim_markdown_preview_on_write = b:vim_markdown_preview_on_write
  endif
  let t:vim_markdown_preview_on_write = 1 - t:vim_markdown_preview_on_write

  if t:vim_markdown_preview_on_write == 1
    echom "preview-on-write enabled for this tab"
  elseif t:vim_markdown_preview_on_write == 0
    echom "preview-on-write disabled for this tab"
  else
    echom "Error, t:markdown_preview_on_write is " . t:vim_markdown_preview_on_write
  endif
endfunction

function! Vim_Markdown_Preview_On_Write()
  if !exists("t:vim_markdown_preview_on_write")
    let t:vim_markdown_preview_on_write = b:vim_markdown_preview_on_write
  endif
  if t:vim_markdown_preview_on_write == 1
    if b:vim_markdown_preview_toggle == 0
      :call Vim_Markdown_Preview()
    else
      :call Vim_Markdown_Preview_Local()
    end
  end
endfunction

function! Vim_Markdown_Preview()
  let OSNAME = 'Unidentified'

  if has('win32')
    " Not yet used
    let OSNAME = 'win32'
  endif
  if has('unix')
    let OSNAME = 'unix'
  endif
  if has('mac')
    let OSNAME = 'mac'
  endif

  let curr_file = expand('%:p')

  if b:vim_markdown_preview_github == 1
    call system('grip "' . curr_file . '" --export /tmp/vim-markdown-preview.html')
  else
    call system(b:vim_markdown_preview_command . ' ' . shellescape(curr_file) . ' > /tmp/vim-markdown-preview.html')
  endif

  if OSNAME == 'unix'
    let chrome_wid = system("xdotool search --name 'vim-markdown-preview.html - " . b:vim_markdown_preview_browser . "'")
    if !chrome_wid
      call system('see /tmp/vim-markdown-preview.html &> /dev/null &')
    else
      let curr_wid = system('xdotool getwindowfocus')
      call system('xdotool windowmap ' . chrome_wid)
      call system('xdotool windowactivate ' . chrome_wid)
      call system("xdotool key 'ctrl+r'")
      call system('xdotool windowactivate ' . curr_wid)
    endif
  endif

  if OSNAME == 'mac'
    call system('open -g /tmp/vim-markdown-preview.html')
  endif

  if b:vim_markdown_preview_temp_file == 1
    sleep 1000m
    call system('rm /tmp/vim-markdown-preview.html')
  endif
endfunction


"Renders html locally and displays images
function! Vim_Markdown_Preview_Local()
  if b:vim_markdown_preview_toggle == 0 && get(t:, 'vim_markdown_preview_enabled', 0) == 0
      return 0
  endif

  let OSNAME = 'Unidentified'

  if has('win32')
    " Not yet used
    let OSNAME = 'win32'
  endif
  if has('unix')
    let OSNAME = 'unix'
  endif
  if has('mac')
    let OSNAME = 'mac'
  endif

  let curr_file = expand('%:p')
  let curr_file2 = expand('%:t')

  if b:vim_markdown_preview_github == 1
    call system('grip "' . curr_file . '" --export ' . curr_file . '.html')
  else
    " call system('markdown "' . curr_file . '" > ' . curr_file . '.html')
    call system(b:vim_markdown_preview_command . ' ' . shellescape(curr_file) . ' > ' . curr_file . '.html')

  endif

  if OSNAME == 'unix'
    let chrome_wid = system("xdotool search --name '". curr_file2 . ".html - " . b:vim_markdown_preview_browser . "'")
    if !chrome_wid
      call system('see ' . curr_file . '.html &> /dev/null &')
    else
      let curr_wid = system('xdotool getwindowfocus')
      call system('xdotool windowmap ' . chrome_wid)
      call system('xdotool windowactivate ' . chrome_wid)
      call system("xdotool key 'ctrl+r'")
      call system('xdotool windowactivate ' . curr_wid)
    endif
  endif

  if OSNAME == 'mac'
    call system('open -g ' . curr_file . '.html')
  endif

  if b:vim_markdown_preview_temp_file == 1
    sleep 1000m
    call system('rm ' . curr_file . '.html')
  endif
endfunction

:exec 'autocmd Filetype markdown,md map <buffer> ' . g:vim_markdown_preview_hotkey . ' :call Vim_Markdown_Preview_Toggle_On_Write()<CR>'
autocmd BufWritePost *.markdown,*.md :call Vim_Markdown_Preview_On_Write()
