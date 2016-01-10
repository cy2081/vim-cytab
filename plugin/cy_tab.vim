"Cy Tab
"Author: CY
"Email: cy@baow.com
"Version: 1.1


if exists('loaded_cy_tabpage')
    finish
endif

let loaded_cy_tabpage = 1

set winaltkeys=no
com! -nargs=* -complete=file E tabnew <args>

nnoremap <unique> <A-1> 1gt
nnoremap <unique> <A-2> 2gt
nnoremap <unique> <A-3> 3gt
nnoremap <unique> <A-4> 4gt
nnoremap <unique> <A-5> 5gt
nnoremap <unique> <A-6> 6gt
nnoremap <unique> <A-7> 7gt
nnoremap <unique> <A-8> 8gt
nnoremap <unique> <A-9> 9gt

nnoremap <unique> <A-n> gT
nnoremap <unique> <A-d> gT
nnoremap <unique> <A-m> gt
nnoremap <unique> <A-f> gt
nnoremap <silent> <A-H> :call <SID>CyTabMove(-2)<CR>
nnoremap <silent> <A-L> :call <SID>CyTabMove(0)<CR>

function! s:CyTabMove(idx)
    let index = tabpagenr() + a:idx
    if (index < 0)
        return
    endif
    silent execute 'tabmove ' . index
endfunction

function! s:CyGetSysSlash()
    if has('win32') || has('win64') || has('win95')
        return '\'
    else
        return '/'
    endif
endfunction

function! CyTabLabel()
    let tab_num = tabpagenr()
    let label = ''
    let w1 = ''.tabpagenr().': '
    let w2 =  ''
    let w3 = tabpagenr().': < '
    let w4 =  ' >'
    let bufnrlist = tabpagebuflist(v:lnum)
    " Add '+' if one of the buffers in the tab page is modified
    for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
            let label .= '+ '
            break
        endif
    endfor

    let slash = s:CyGetSysSlash()
    let tt = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":t")
    let ext = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":e")
    let path = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":h").slash.'.baow'.slash.tt.'.title'
    if filereadable(path)
        let title = readfile(path)[0]
        "return label . title.'^'.tt
        "return w1.label . title .'__'.ext.w2
        let new_a = w1.label . title .w2
        if ext
            let new_a .= ' | '.ext
        endif
        let new_b = substitute(new_a," ", '\\ ',"g" )
        call s:UpdateTabMenu()
        return new_a
    endif

    let path = fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":h").slash.'.baow'.slash.'title'
    if filereadable(path)
        let title = readfile(path)[0]
        call s:UpdateTabMenu()
        return w3.label . title .w4
    endif
    call s:UpdateTabMenu()
    return w1.label . fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":t") . w2
    "finally
    " Append the buffer name
    "    return label . fnamemodify(bufname(bufnrlist[tabpagewinnr(v:lnum)-1]), ":t")
    "endtry
endfunction

function! s:CyPath(dir_name)
    " Shorten long file names by adding only few characters from
    " the beginning and end.
    let newp = a:dir_name
    let len = strlen(newp)
    if len > 30
        let newp = strpart(newp, 0, 20) .
                    \ '...' . 
                    \ strpart(newp, len - 20)
    endif
    return newp
endfunction

let s:tab = []
function s:UpdateTabMenu()

    for n in s:tab
        execute 'aunmenu CyTab.'.n
    endfor

    let s:tab = []
    let slash = s:CyGetSysSlash()
    for i in range(tabpagenr('$'))
        let bnr = tabpagebuflist(i + 1)[0]
        let bname = bufname(bnr)
        let plus = '  '
        if getbufvar(bnr, "&modified")
            let plus = '+ '
        endif

        if len(bname)==0
            let bname = 'No Name'
        endif

        let tt = expand("#".bnr.":t")
        let path = fnamemodify(expand("#".bnr.":p"), ":h").slash.'.baow'.slash.tt.'.title'
        let path2 = fnamemodify(expand("#".bnr.":p"), ":h").slash.'.baow'.slash.'title'
        if filereadable(path)
            let bname = readfile(path)[0].'  -- '.tt
        elseif filereadable(path2)
            let bname = "< ".readfile(path2)[0]
            let path3 = fnamemodify(expand("#".bnr.":p"), ":h").slash.'.baow'.slash.'name'
            if filereadable(path3)
                let btfn = readfile(path3)
                if len(btfn) > 0
                    let bname = bname . " [".btfn[0]."]"
                endif

            endif
            let bname = bname." >"
        else
            let bname = bufname(bnr)
            if len(bufname(bnr))==0
                let bname = 'No Name'
            else
                let fname = fnamemodify(bufname(bnr), ":t")
                let h_dir = s:CyPath(fnamemodify(bufname(bnr), ":h"))
                let bname = fname.'   ('.h_dir.')'
            endif
        endif
        let new_b = substitute('['.(i+1).'] '.plus.bname," ", '\\ ',"g" )
        let new_b = substitute(new_b,'\.', '\\\.',"g" )

        call add(s:tab, new_b)

        execute 'amenu CyTab.'.new_b.' '.(i+1).'gt<CR>'
    endfor

endfunction

menu CyTab.New :tabnew<CR>
menu CyTab.Close :close<CR>
menu CyTab.-sep- :
set guitablabel=%{CyTabLabel()}
