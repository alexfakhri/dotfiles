function! JF_RunRelevantTest()
  if g:jf_test_runner ==? '!npm test' || g:jf_test_runner ==? '!grunt test'
    exec g:jf_test_runner
  else
    exec g:jf_test_runner g:jf_test_file
  endif
endfunction

function! JF_IsInTestFile()
  let fullpath = expand('%:p')
  if match(fullpath, 'test') != -1 || match(fullpath, 'spec') != -1
    return 1
  endif
endfunction

function! JF_StoreCurrentTestFile()
  let g:jf_test_file=expand('%')
endfunction

function! JF_StoreTestRunner(runner)
  let g:jf_test_runner=a:runner
endfunction

" based on a similar script in Ben Orenstein's vimrc.
function! JF_ExecuteRelevantTestFile()
  let filename = expand('%')
  if JF_IsInTestFile() == 1
    call JF_StoreCurrentTestFile()
    if match(filename, '\.rb') != -1
      call JF_ProcessRubyTestFile()
    elseif match(filename, '\.js') != -1
      call JF_ProcessJSTestFile()
    endif
  endif
  call JF_RunRelevantTest()
endfunction

function! JF_ProcessRubyTestFile()
  let fullpath = expand('%:p')
  if match(fullpath, '_spec\.rb$') != -1
    call JF_StoreTestRunner('!rspec')
  elseif match(fullpath, '\.rb') != -1
    call JF_StoreTestRunner('!ruby -Itest')
  endif
endfunction

function! JF_ProcessJSTestFile()
  let fullpath = expand('%:p')
  let searchForPackageJsonOutput = system('find . -name "package.json" -depth 1 2>/dev/null')
  let searchForGruntOutput = system('find . -name "Gruntfile.js" -depth 1 2>/dev/null')
  if match(searchForGruntOutput, './Gruntfile.js') != -1
    call JF_StoreTestRunner('!grunt test')
  else
    if match(searchForPackageJsonOutput, './package.json') != -1
      call JF_StoreTestRunner('!npm test')
    else
      call JF_StoreTestRunner('!node')
    endif
  endif
endfunction
