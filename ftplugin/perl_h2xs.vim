" Vim filetype plugin file
" Language:	Perl
" Maintainer:	Colin Keith <vim_@_ckeith.clara.net>
" Last Change:	Wed Oct 30 16:56:53 EST 2002
" URL:	http://vim.sourceforge.net/script_search.php?keywords=perl_h2xs

" With this plugin you can edit a new perl module and have Vim automatically
" run h2xs and then edit the default module for you.

" Check we're dealing with a perl module:
let fn = expand('<afile>')
if(fn !~ '\.pm$') | finish | endif

" Without h2xs, its pretty pointless doing anything :)
let h2xs = has('win32') ? 'h2xs.bat' : 'h2xs'
if(executable(h2xs) != 1) | finish | endif

" Roughly equivalent to a BufNewFile autocmd w/o the test being in a .vimrc
if(filereadable(fn)) | finish | endif

" Ask if we actually want to create the module
if(!exists('g:perl_h2xs_autocreate'))
  let ans =input('The module '.fn.' does not exist. Do you want to create it?')
  if(ans !~ '^[Yy]') | finish | endif
endif

" Fix module name and generate name of file the module will be placed in:
"  Yes this does seem to make a subst, then undo it, but this allows the
"  user to specify multiple source filenames.
" I.e. Eg::Test.pm, Eg/Test.pm ===all===> Eg/Test
let fn = substitute(fn, '\\', '/', 'g')  " for Win32 :p

" See if we're trying to start a module in a certain dir
let pwd = getcwd()

" /usr/local/src/perl_modules/Test::Arse.pm notation
if(fn =~ '::' && fn =~ '/')
  let dir = substitute(fn, '^\(.*/\)[^/]\+$', '\1', '')
  let fn  = substitute(fn, '^\(.*/\)\([^/]\+\)$', '\2', '')
  if(dir != '') | execute ':cd '. dir | endif
" /usr/local/src/perl_modules/Test/Arse.pm notation:
else
  let dir = ''
  while(fn =~ '/')
    let idx = stridx(fn, '/') +1
    if(isdirectory(dir. strpart(fn, 0, idx)))
      let dir = dir . strpart(fn, 0, idx)
      let fn  = strpart(fn, idx)
    else
      if(dir != '') | execute ':cd '. dir | endif
      break
    endif
  endwhile
endif

let fn = substitute(fn, '::', '/', 'g')
let fn = substitute(fn, '\.pm$', '', '')

" Generate the Perl module name from the filename Eg/Test => Eg::Test
let pm = substitute(fn, '/', '::', 'g')

" Convert the filename to h2xs mod name: Eg/Test => Eg/Test/Test.pm
let dir = fn
let fn  = substitute(fn, '\v(/.+)$', '\1\1.pm', '')


" Roll camera:
let flags = exists('g:perl_h2xs_flags') ? g:perl_h2xs_flags : '-XAn'
call system(h2xs. ' '. flags. ' '. pm)


" If the module's file Eg/Test/Test.pm was successfully created
if(!filereadable(fn))
  echoerr "Error. h2xs did not create filename '".fn."', or not readable."
  echoerr h2xs. ' '. flags. ' '. pm
  finish
endif

" If we set an author address, fix up the Makefile.PL
if(exists('g:perl_h2xs_author') && filereadable(dir. '/Makefile.PL'))

  " Just in case we broke it :p (although this could also break it)
  let g:perl_h2xs_author = substitute(g:perl_h2xs_author, "'", "\\'", 'g')

  silent execute ':edit! '. dir. '/Makefile.PL'
  silent execute ":%g/AUTHOR/s/'.*'/'". g:perl_h2xs_author. "'/"
  write
endif

" Do we use CVS?
if((isdirectory('CVS') || exists('g:perl_h2xs_usecvs')) && executable('cvs'))

    " If so, we'll need to tell ExtUtils not to complains about the CVS
    " directory for this new module by excluding the CVS dirs in MANIFEST.SKIP
    silent execute ':edit! '. dir. '/MANIFEST.SKIP'
    call append(line('$'), 'CVS')
    call append(line('$'), 'CVS/Root')
    call append(line('$'), 'CVS/Repository')
    call append(line('$'), 'CVS/Entries')
    write

    " We then add this file to the MANIFEST so ExtUtils doesn't get upset
    " about this newly created file it knows nothing about.
    silent execute ':edit! '. dir. '/MANIFEST'
    call append(line('$'), 'MANIFEST.SKIP')
    write

    " Now, do we want to auto CVS's it?
    if(exists('g:perl_h2xs_usecvs'))
      if(isdirectory('CVS'))
        " Already part of a cvs respository, so we read all of the files
        " in the directory from the MANIFEST file (cunning, huh? :)
        let i = 1
        let f = ''
        while(i<line('$'))
          let f = f. ' '. dir. '/'. getline(i)
          let i = i+1
        endwhile

        call system('cvs add '. dir. f)
      else
        let cl = input('cvs import ', pm. ' PerlCoder '. pm. '_0_0_1')
        if(cl != '')
          call system('cvs import '. cl)
        endif
      endif
    endif
endif

" Now we start editing the newly created file
silent execute ":edit! ". fn

" And if we've set an author name, replace the default address with this.
if(exists('g:perl_h2xs_author'))
  " Note no further escaping of 's as it was done above
  silent execute ':%s/^A\. U\. Thor.*/'. g:perl_h2xs_author. '/'
  write
  :1
endif

" Now tidy up the file we created to start this whole process rolling
call delete(expand('<afile>'))
silent execute ':cd '. pwd
