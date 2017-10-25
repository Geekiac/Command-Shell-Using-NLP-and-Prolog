% test.pl - Steven Smith      2017 January 02

% Tests the translation engine of os.pl by executing tests against both
% windows and posix OS variants, comparing the output command string against
% the expected command string for some input
%
% The main predicate is execute_tests/0. (requires et.pl and os.pl)

% get_command(+OS,+Input,+Words,+SimplifiedWords,-CommandString)
%
get_command(OS,Input,Words,SimplifiedWords,CommandString) :-
  open_string(Input,Stream),
  process_input(OS,Stream,Words,SimplifiedWords,Command),
  atomics_to_string(Command,CommandString).

% execute_a_test(+Test,-Passed,-Failed)
%   executes a test(OS,Input,Expected)=Test using get_command/5 and increments
%   Passed or Failed if the Test passes or fails.
execute_a_test(Test,Passed,Failed) :-
  test(OS,Input,Expected) = Test,
  get_command(OS,Input,Words,SimplifiedWords,CommandString),
  atomics_to_string([Expected],ExpectedString),
  test_result(OS,Input,Words,SimplifiedWords,CommandString,
              ExpectedString,Passed,Failed).

% test_result(+OS,+Input,+Words,+SimplifiedWords,+CommandString,
%              +ExpectedString,-Passed,-Failed)
%   determines if a test has Passed or Failed, by checking if CommandString
%   matches the ExpectedString

% if the test failes write out debug information to help and increment Failed
test_result(OS,Input,Words,SimplifiedWords,CommandString,
            ExpectedString,Passed,Failed) :-
  CommandString \= ExpectedString,
  !,
  format('Test Failed (~a): ~a ~n',[OS,Input]),
  format('~k~n', [[Words,SimplifiedWords,CommandString,ExpectedString]]),
  Passed = 0,
  Failed = 1.

% if the test passes increment Passed
test_result(OS,Input,_,_,_,_,Passed,Failed) :-
  format('Test Passed (~a): ~a~n',[OS,Input]),
  Passed = 1,
  Failed = 0.

% execute_tests(+Tests,-Passed,-Failed)
%   executes each of the tests in Tests and increments either Passed or Failed
%   dependent on whether the test passes or fails.

% initialises Passed and Failed to 0
execute_tests([],0,0).

execute_tests([H|T],Passed,Failed) :-
  execute_tests(T,NewPassed,NewFailed),
  execute_a_test(H,P,F),
  Passed is NewPassed + P,
  Failed is NewFailed + F.

% execute_tests
%   executes tests against both windows and posix OS variants, comparing the
%   output command string against the expected command string for some input
%   text.
%   NOTE: the first test should fail, this means there should always be one
%   test that fails.  This checks that it is possible for a test to fail.
execute_tests :-
  % reverse is used to put the tests in the correct order when recursing over
  % them in execute_tests/3 (the order should be the same as below)
  reverse([
    % -----------------------------------------------------------------------
    % Windows
    % -----------------------------------------------------------------------
    % To show that tests can fail.
    test(windows,'This test fails','This test SHOULD FAIL'),
    % No match is found
    test(windows,'This test finds no match',''),
    test(windows,'This test also finds no match',''),
    % Test [all,files,on,drive,X]
    test(windows,'all files on drive c','dir c:'),
    test(windows,'give me all the files on drive c','dir c:'),
    test(windows,'can you show me every file on drive c','dir c:'),
    test(windows,'what are all the files on drive c','dir c:'),
    test(windows,'show me everything on drive c','dir c:'),
    test(windows,'are there any files on drive c','dir c:'),
    test(windows,'i would like you to show me every file on drive c','dir c:'),
    % Test [X,files,on,drive,Y]
    test(windows,'pl files on drive c','dir c:*.pl'),
    test(windows,'can you show me the pl files on drive c','dir c:*.pl'),
    test(windows,'can you list me the pl files on drive c','dir c:*.pl'),
    test(windows,'can you give me the pl files on drive c','dir c:*.pl'),
    test(windows,'what are the pdf files on drive c','dir c:*.pdf'),
    test(windows,'which pdf files are on drive c','dir c:*.pdf'),
    test(windows,'are there any pdf files on drive c','dir c:*.pdf'),
    % Test [copy,files,from,X,to,Y]
    test(windows,
      'copy files from C:\\test1\\ to C:\\test2\\',
      'copy c:\\test1\\ c:\\test2\\'),
    test(windows,
      'please copy the files from C:\\test1\\ to C:\\test2\\',
      'copy c:\\test1\\ c:\\test2\\'),
    test(windows,
      'can you copy the files from C:\\test1\\ to C:\\test2\\',
      'copy c:\\test1\\ c:\\test2\\'),
    test(windows,
      'please would you copy the files from C:\\test1\\ to C:\\test2\\',
      'copy c:\\test1\\ c:\\test2\\'),
    test(windows,
      'i would like you to copy the files from C:\\test1\\ to C:\\test2\\',
      'copy c:\\test1\\ c:\\test2\\'),
    % Test [files,on,directory,X]
    test(windows,'files on directory \\users\\steve','dir \\users\\steve'),
    test(windows,
      'please can you show me the files in directory \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'what files are in directory \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'tell me which files are in directory \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'show me which files are in directory \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'would you show me the files in directory \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'would you list me the files in path \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'would you show me the files in path \\users\\steve',
      'dir \\users\\steve'),
    test(windows,
      'tell me which files are in path \\users\\steve',
      'dir \\users\\steve'),
    % Test [contents,files,X]
    test(windows,'contents file et.pl','c:\\windows\\system32\\more et.pl'),
    test(windows,
      'show the contents of file et.pl',
      'c:\\windows\\system32\\more et.pl'),
    test(windows,
      'please show the contents file et.pl',
      'c:\\windows\\system32\\more et.pl'),
    test(windows,
      'can you show me the contents of file et.pl please',
      'c:\\windows\\system32\\more et.pl'),
    test(windows,
      'could you show me the content of file et2.pl',
      'c:\\windows\\system32\\more et2.pl'),
    test(windows,
      'show the contents of file et2.pl',
      'c:\\windows\\system32\\more et2.pl'),
    test(windows,
      'could you please tell me the content of file et2.pl',
      'c:\\windows\\system32\\more et2.pl'),
    % Test [current,directory]
    test(windows,'current directory','cd'),
    test(windows,'what is the current directory','cd'),
    test(windows,'can you show me the current directory','cd'),
    test(windows,'would you tell me the current directory please','cd'),
    test(windows,'give me the current directory please', 'cd'),
    test(windows,'current path','cd'),
    test(windows,'what is the current path','cd'),
    test(windows,'can you show me the current path','cd'),
    test(windows,'would you tell me the current path please','cd'),
    test(windows,'give me the current path please', 'cd'),
    % Test [change,directory,X]
    test(windows,'change directory .\\test1','cd .\\test1'),
    test(windows,'switch directory .\\test1','cd .\\test1'),
    test(windows,'please change the directory to .\\test1','cd .\\test1'),
    test(windows,'please switch the directory to .\\test1','cd .\\test1'),
    test(windows,'could you change the directory to .\\test1','cd .\\test1'),
    test(windows,'can i switch the directory to .\\test1','cd .\\test1'),
    test(windows,'will you change the directory to .\\test1','cd .\\test1'),
    test(windows,'would you switch the directory to .\\test1 please','cd .\\test1'),
    test(windows,'change path .\\test1','cd .\\test1'),
    test(windows,'switch path .\\test1','cd .\\test1'),
    test(windows,'please change the path to .\\test1','cd .\\test1'),
    test(windows,'please switch the path to .\\test1','cd .\\test1'),
    test(windows,'could you change the path to .\\test1','cd .\\test1'),
    test(windows,'can i switch the path to .\\test1','cd .\\test1'),
    test(windows,'will you change the path to .\\test1','cd .\\test1'),
    test(windows,'would you switch the path to .\\test1 please','cd .\\test1'),
    % Test [make,directory,X]
    test(windows,'make directory .\\test1','mkdir .\\test1'),
    test(windows,'create directory .\\test1','mkdir .\\test1'),
    test(windows,'can you make the directory .\\test1','mkdir .\\test1'),
    test(windows,'can i create the directory .\\test1','mkdir .\\test1'),
    test(windows,'will you make the directory .\\test1 please','mkdir .\\test1'),
    test(windows,'i would like you to create the directory .\\test1','mkdir .\\test1'),
    test(windows,'make path .\\test1','mkdir .\\test1'),
    test(windows,'create path .\\test1','mkdir .\\test1'),
    test(windows,'can you make the path .\\test1','mkdir .\\test1'),
    test(windows,'can i create the path .\\test1','mkdir .\\test1'),
    test(windows,'will you make the path .\\test1 please','mkdir .\\test1'),
    test(windows,'i would like you to create the path .\\test1','mkdir .\\test1'),
    % Test [remove,directory,X]
    test(windows,'remove directory .\\test1','rmdir .\\test1'),
    test(windows,'delete directory .\\test1','rmdir .\\test1'),
    test(windows,
      'could you remove the directory please .\\test1',
      'rmdir .\\test1'),
    test(windows,'would you delete the directory .\\test1','rmdir .\\test1'),
    test(windows,
      'i would like you to remove the directory please .\\test1',
      'rmdir .\\test1'),
      test(windows,'remove path .\\test1','rmdir .\\test1'),
      test(windows,'delete path .\\test1','rmdir .\\test1'),
      test(windows,
        'could you remove the path please .\\test1',
        'rmdir .\\test1'),
      test(windows,'would you delete the path .\\test1','rmdir .\\test1'),
      test(windows,
        'i would like you to remove the path please .\\test1',
        'rmdir .\\test1'),
    % Test [os,using]
    test(windows,'what os am i running','ver'),
    test(windows,'which os am i using','ver'),
    test(windows,'tell me the os i am running','ver'),
    test(windows,'show me the os i am using','ver'),


    % -----------------------------------------------------------------------
    % Posix
    % -----------------------------------------------------------------------
    % Test [copy,files,from,X,to,Y]
    test(posix,
      'copy files from /home/steve/test1/ to /home/steve/test2/',
      'cp /home/steve/test1/ /home/steve/test2/'),
    test(posix,
      'please copy the files from /home/steve/test1/ to /home/steve/test2/',
      'cp /home/steve/test1/ /home/steve/test2/'),
    test(posix,
      'could you copy these files from /home/steve/test1/ to /home/steve/test2/ please',
      'cp /home/steve/test1/ /home/steve/test2/'),
    test(posix,
      'would you copy files from /home/steve/test1/ to /home/steve/test2/',
      'cp /home/steve/test1/ /home/steve/test2/'),
    % Test [files,on,directory,X]
    test(posix,'files on directory /Applications/','ls /Applications/'),
    test(posix,'which files are on directory /Applications/','ls /Applications/'),
    test(posix,'show me the files are on directory /Applications/','ls /Applications/'),
    test(posix,
      'can you tell me the files on directory /Applications/',
      'ls /Applications/'),
    test(posix,'give me the files on directory /Applications/','ls /Applications/'),
    test(posix,'files on path /Applications/','ls /Applications/'),
    test(posix,'which files are on path /Applications/','ls /Applications/'),
    test(posix,'show me the files are on path /Applications/','ls /Applications/'),
    test(posix,'list me the files are on path /Applications/','ls /Applications/'),
    test(posix,
      'can you tell me the files on path /Applications/',
      'ls /Applications/'),
    test(posix,'give me the files on path /Applications/','ls /Applications/'),
    % Test [contents,files,X]
    test(posix,'contents files ./et.pl','less ./et.pl'),
    test(posix,'show contents of file ./et.pl','less ./et.pl'),
    test(posix,'please show me the content of the file ./et.pl','less ./et.pl'),
    test(posix,'give me the content of the file ./et.pl','less ./et.pl'),
    test(posix,'can i see the content of the file ./et.pl','less ./et.pl'),
    test(posix,'i would like to see the content of the file ./et.pl','less ./et.pl'),
    % Test [current,directory]
    test(posix,'current directory','pwd'),
    test(posix,'what is the current directory','pwd'),
    test(posix,'please show me the current directory','pwd'),
    test(posix,'tell me the current directory','pwd'),
    test(posix,'would you give me the current directory','pwd'),
    test(posix,'can I see the current directory please','pwd'),
    test(posix,'i would like to see the current directory please','pwd'),
    test(posix,'current path','pwd'),
    test(posix,'what is the current path','pwd'),
    test(posix,'please show me the current path','pwd'),
    test(posix,'tell me the current path','pwd'),
    test(posix,'would you give me the current path','pwd'),
    test(posix,'can I see the current path please','pwd'),
    test(posix,'i would like to see the current path please','pwd'),
    % Test [change,directory,X]
    test(posix,'change directory ./test1','cd ./test1'),
    test(posix,'switch directory ./test1','cd ./test1'),
    test(posix,'please change the directory to ./test1','cd ./test1'),
    test(posix,'please switch the directory to ./test1','cd ./test1'),
    test(posix,'can you change the directory to ./test1','cd ./test1'),
    test(posix,'could you switch the directory to ./test1 please','cd ./test1'),
    test(posix,'please will you change the directory to ./test1','cd ./test1'),
    test(posix,'would you switch the directory to ./test1','cd ./test1'),
    test(posix,'i would like you to change directory to ./test1','cd ./test1'),
    test(posix,'change path ./test1','cd ./test1'),
    test(posix,'switch path ./test1','cd ./test1'),
    test(posix,'please change the path to ./test1','cd ./test1'),
    test(posix,'please switch the path to ./test1','cd ./test1'),
    test(posix,'can you change the path to ./test1','cd ./test1'),
    test(posix,'could you switch the path to ./test1 please','cd ./test1'),
    test(posix,'please will you change the path to ./test1','cd ./test1'),
    test(posix,'would you switch the path to ./test1','cd ./test1'),
    test(posix,'i would like you to change path to ./test1','cd ./test1'),
    % Test [make,directory,X]
    test(posix,'make directory ./test1','mkdir ./test1'),
    test(posix,'create directory ./test1','mkdir ./test1'),
    test(posix,'please could you make the directory ./test1','mkdir ./test1'),
    test(posix,'can you create the directory ./test1','mkdir ./test1'),
    test(posix,'will you make the directory ./test1 please','mkdir ./test1'),
    test(posix,'please could you create the directory ./test1','mkdir ./test1'),
    test(posix,'I would like you to create the directory ./test1','mkdir ./test1'),
    test(posix,'make path ./test1','mkdir ./test1'),
    test(posix,'create path ./test1','mkdir ./test1'),
    test(posix,'please could you make the path ./test1','mkdir ./test1'),
    test(posix,'can you create the path ./test1','mkdir ./test1'),
    test(posix,'will you make the path ./test1 please','mkdir ./test1'),
    test(posix,'please could you create the path ./test1','mkdir ./test1'),
    test(posix,'I would like you to create the path ./test1','mkdir ./test1'),
    % Test [remove,directory,X]
    test(posix,'remove directory ./test1','rmdir ./test1'),
    test(posix,'delete directory ./test1','rmdir ./test1'),
    test(posix,'would you remove directory ./test1','rmdir ./test1'),
    test(posix,'please delete directory ./test1','rmdir ./test1'),
    test(posix,'i would like you to remove the directory ./test1','rmdir ./test1'),
    test(posix,'remove path ./test1','rmdir ./test1'),
    test(posix,'delete path ./test1','rmdir ./test1'),
    test(posix,'would you remove path ./test1','rmdir ./test1'),
    test(posix,'please delete path ./test1','rmdir ./test1'),
    test(posix,'i would like you to remove the path ./test1','rmdir ./test1'),
    % Test [os,using]
    test(posix,'what os am i running','uname -a'),
    test(posix,'which os am i using','uname -a'),
    test(posix,'tell me the os i am running','uname -a'),
    test(posix,'show me the os i am using','uname -a')
  ],Tests),
  length(Tests,NumTests),
  execute_tests(Tests,Passed,Failed),
  format('~n~10r Tests Executed,~10r Tests Passed,~10r Tests Failed.',
    [NumTests,Passed,Failed]),
  !.
