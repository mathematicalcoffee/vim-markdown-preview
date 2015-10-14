"============================================================
"                    Vim Markdown Preview
"   git@github.com:JamshedVesuna/vim-markdown-preview.git
"============================================================
" Usage: ^W to toggle on-write generation in that tab; ^P to force a preview
"
let b:vim_markdown_preview_browser = get(g:, 'vim_markdown_preview_browser', 'Google Chrome')
" either 0 (temp file) or 1 (local file)
let b:vim_markdown_preview_use_local = get(g:, 'vim_markdown_preview_use_local', 0)
let b:vim_markdown_preview_remove_output = get(g:, 'vim_markdown_preview_remove_output', 0)
let b:vim_markdown_preview_command = get(g:, 'vim_markdown_preview_command', 'pandoc --toc --standalone -t html INFILE > OUTFILE')
let g:vim_markdown_preview_on_write = get(g:, 'vim_markdown_preview_on_write', 0)
if !exists("g:vim_markdown_preview_hotkey")
    let g:vim_markdown_preview_hotkey='<C-p>'
endif
if !exists("g:vim_markdown_preview_toggle_hotkey")
    let g:vim_markdown_preview_toggle_hotkey='<C-k>'
endif

" o'wise disabled by default.
" b:vim_markdown_preview_enabled: -1 means default to 
function! Vim_Markdown_Preview_Toggle_On_Write()
  if !exists("b:vim_markdown_preview_on_write")
    let b:vim_markdown_preview_on_write = g:vim_markdown_preview_on_write
  endif
  let b:vim_markdown_preview_on_write = 1 - b:vim_markdown_preview_on_write

  if b:vim_markdown_preview_on_write == 1
    echom "preview-on-write enabled for this tab"
  elseif b:vim_markdown_preview_on_write == 0
    echom "preview-on-write disabled for this tab"
  else
    echom "Error, b:markdown_preview_on_write is " . b:vim_markdown_preview_on_write
  endif
endfunction

function! Vim_Markdown_Preview_On_Write()
  if !exists("b:vim_markdown_preview_on_write")
    let b:vim_markdown_preview_on_write = g:vim_markdown_preview_on_write
  endif
  if b:vim_markdown_preview_on_write == 1
      :call Vim_Markdown_Preview()
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

  let curr_file = expand('%:p')  " full path
  let out_file = '/tmp/vim-markdown-preview.html'
  let out_file_windowname = 'vim-markdown-preview.html'
  if b:vim_markdown_preview_use_local == 1 
      let out_file = curr_file . '.html' " includes path prefix
      let out_file_windowname = expand('%:t') . '.html' " without path prefix
  endif

  let cmd = substitute(substitute(b:vim_markdown_preview_command, "INFILE", curr_file, ""), "OUTFILE", out_file, "")
  if cmd == b:vim_markdown_preview_command
      let cmd = cmd . ' ' . shellescape(curr_file) . ' > ' . shellescape(out_file)
  endif
  call system(cmd)

  if OSNAME == 'unix'
    let chrome_wid = system("xdotool search --name '". out_file_windowname . " - " . b:vim_markdown_preview_browser . "'")
    if !chrome_wid
      call system('see ' . out_file . ' &> /dev/null &')
    else
      let curr_wid = system('xdotool getwindowfocus')
      call system('xdotool windowmap ' . chrome_wid)
      call system('xdotool windowactivate ' . chrome_wid)
      call system("xdotool key 'ctrl+r'")
      call system('xdotool windowactivate ' . curr_wid)
    endif
  endif

  if OSNAME == 'mac'
    call system('open -g ' . out_file)
  endif

  if b:vim_markdown_preview_remove_output == 1
    sleep 1000m
    call system('rm ' . out_file)
  endif
endfunction

:exec 'autocmd Filetype markdown,md map <buffer> ' . g:vim_markdown_preview_toggle_hotkey . ' :call Vim_Markdown_Preview_Toggle_On_Write()<CR>'
:exec 'autocmd Filetype markdown,md map <buffer> ' . g:vim_markdown_preview_hotkey . ' :call Vim_Markdown_Preview()<CR>'
autocmd BufWritePost *.markdown,*.md :call Vim_Markdown_Preview_On_Write()
