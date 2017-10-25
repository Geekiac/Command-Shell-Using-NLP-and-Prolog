% os.pl - Steven Smith      2017 January 02

% Natural Language Processing (NLP) of text entered at the command line and
% the execution of commands in an OS shell.
%
% The main predicate is process_commands/0. (requires et.pl)
%
% The system is capable of executing commands on
%       Windows
%       Linux/Mac OS (Posix)
%
% Windows DOS commands supported - see tr/4.
%       dir X:
%       dir Y:*.X
%       copy X Y
%       dir X
%       more X
%       cd
%       cd X
%       mkdir X
%       rmdir X
%       ver
%
% Linux/Mac OS commands supported - see tr/4.
%       cp X Y
%       ls X
%       less X
%       pwd
%       cd X
%       mkdir X
%       rmdir X
%       uname -a

% sr(+List,-Result)
%   Replace List with Result when matched.

% equivalent phrases - like synonyms
sr([directory,to|X],[directory|X]).
sr([disk,in,drive|X],[drive|X]).
sr([disk,in|X],[drive|X]).
sr([what,files|X],[files|X]).
sr([everything|X],[all,files|X]).
sr([any,files|X],[all,files|X]).
sr([files,contents|X],[contents,files|X]).
sr([to,make|X],[make|X]).
sr([to,remove|X],[remove|X]).
sr([to,change|X],[change|X]).
sr([to,copy|X],[copy|X]).
sr([to,show|X],[show|X]).
% synonyms - equivalent words
sr([disk|X],[drive|X]).
sr([file|X],[files|X]).
sr([every|X],[all|X]).
sr([content|X],[contents|X]).
sr([in|X],[on|X]).
sr([create|X],[make|X]).
sr([delete|X],[remove|X]).
sr([switch|X],[change|X]).
sr([bye|X],[quit|X]).
sr([exit|X],[quit|X]).
sr([running|X],[using|X]).
sr([path|X],[directory|X]).
% stop phrases - phrases that are ignored
sr([i,would|X],X).
sr([can,i|X],X).
sr([can,you|X],X).
sr([could,i|X],X).
sr([could,you|X],X).
sr([would,you|X],X).
sr([will,you|X],X).
sr([give,me|X],X).
sr([like,you,to|X],X).
sr([like,to|X],X).
sr([am,i|X],X).
sr([i,am|X],X).
% stop words - words that are ignored
sr([please|X],X).
sr([me|X],X).
sr([the|X],X).
sr([is|X],X).
sr([are|X],X).
sr([a|X],X).
sr([there|X],X).
sr([these|X],X).
sr([any|X],X).
sr([like|X],X).
sr([of|X],X).
sr([see|X],X).
sr([list|X],X).
sr([show|X],X).
sr([tell|X],X).
sr([what|X],X).
sr([which|X],X).
sr([you|X],X).
sr([my|X],X).

% simplify(+List,-Result)
%   Reduces List to it's simplified version,Result
simplify(List,Result) :-
  sr(List,NewList),
  !,
  simplify(NewList,Result).

simplify([W|Words],[W|NewWords]) :-
  simplify(Words,NewWords).

simplify([],[]).

% tr(+OS,+SimplifiedWords,-Command,+OriginalWords)
%   Translates the SimplifiedWords into a command based on the OS and
%   using the OriginalWords (to make sure file/directory names are in the
%   correct case where necessary - posix)

tr(_,[quit],[quit],_).

% windows translations
tr(windows,[all,files,on,drive,X],['dir ',X,':'],_).
tr(windows,[X,files,on,drive,Y],['dir ',Y,':*.',X],_).
tr(windows,[copy,files,from,X,to,Y],['copy ',X,' ',Y],_).
tr(windows,[files,on,directory,X],['dir ',X],_).
tr(windows,[contents,files,X],['c:\\windows\\system32\\more ',X],_).
tr(windows,[current,directory],['cd'],_).
tr(windows,[change,directory,X],['cd ',X],_).
tr(windows,[make,directory,X],['mkdir ',X],_).
tr(windows,[remove,directory,X],['rmdir ',X],_).
tr(windows,[os,using],['ver'],_).

% posix translations - X and Y are converted to there original case as Linux
% and Mac OS are usually case sensitive
tr(posix,[copy,files,from,X,to,Y],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  find_in_list(Y,OriginalWords,ActualY),
  Command=['cp ',ActualX,' ',ActualY].

tr(posix,[files,on,directory,X],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  Command=['ls ',ActualX].

tr(posix,[contents,files,X],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  Command=['less ',ActualX].

tr(posix,[current,directory],['pwd'],_).

tr(posix,[change,directory,X],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  Command=['cd ',ActualX].

tr(posix,[make,directory,X],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  Command=['mkdir ',ActualX].

tr(posix,[remove,directory,X],Command,OriginalWords) :-
  find_in_list(X,OriginalWords,ActualX),
  Command=['rmdir ',ActualX].

  tr(posix,[os,using],['uname -a'],_).

% find_in_list(+X,+List,-Result)
%   Tries to find X in List using a case insensitive search but returns Result,
%   the original case of X in the List.

% When X cannot be found then X is the Result
find_in_list(X,[],X) :- !.

% X is found so set Result to the original case of X in List
find_in_list(X,[H|_],Result) :-
  string_lower(H,LowerH),
  string_lower(X,LowerX),
  LowerX = LowerH,
  !,
  Result = H.

% Current item in List is not X so move to the next item
find_in_list(X,[_|T],Result) :- find_in_list(X,T,Result).

% translate(+OS,+SimplifiedWords,-Command,+OriginalWords)
%   Translates the SimplifiedWords into a command based on the OS and
%   using the OriginalWords (to make sure file/directory names are in the
%   correct case where necessary - posix)
translate(OS,SimplifiedWords,Command,OriginalWords) :-
   tr(OS,SimplifiedWords,Command,OriginalWords),
   !.

% no match has been found so notify the user that the SimplifiedWords
% could not be understood
translate(_,SimplifiedWords,[],_) :-
   format('I do not understand: ~k~n', [SimplifiedWords]).

% current_os(-OS)
%   Determines if the current OS is windows or posix (Linux/Mac OS)

% is windows if / is mapped to \ using prolog_to_os_filename
current_os(OS) :-
  prolog_to_os_filename('/',FilePath),
  FilePath = '\\',
  !,
  OS=windows.

% otherwise the OS is posix
current_os(OS) :- OS=posix.

% process_commands
%   the main loop for natural language processing of text entered at the
%   keyboard and executing the associated commands on the underlying OS.
%   The loop terminates when the user types quit
process_commands :-
   current_os(OS),
   format('The current operating system is ~a~n',OS),
   repeat,
      write('Command -> '),
      process_input(OS,user,_,_,Command),
      pass_to_os(OS,Command),
      Command == [quit],
    !.

% process_input(+OS,+Stream,-Words,-SimplifiedWords,-Command)
%   takes the OS and the Stream and creates a list of starting Words,
%   SimplifiedWords and the associated Command that needs executing on the OS
process_input(OS,Stream,Words,SimplifiedWords,Command) :-
  get_input(Stream,Words,OriginalWords),
  simplify(Words,SimplifiedWords),
  translate(OS,SimplifiedWords,Command,OriginalWords).

% get_input(+Stream,-Words,-OriginalWords)
%   outputs Words and the OriginalWords from a Stream
get_input(Stream,Words,OriginalWords) :-
  read_string(Stream,'\n','\r',_,Input),
  split_string(Input,' ','\r\t\s',OriginalWords),
  maplist(atom_lower,OriginalWords,Words).

% atom_lower(+String,-Atom)
%   String is converted to lower case and then to an Atom
atom_lower(String,Atom) :-
  string_lower(String,LowerString),
  atom_string(Atom,LowerString).

% pass_to_os(+OS,+Command)
%  executes the Command on the OS

% an empty Command causes no command to be executed on the OS
pass_to_os(_,[])     :- !.

% [quit] causes no command to be executed on the OS
pass_to_os(_,[quit]) :- !.

% ['cd ',X] does not result is a shell command being executed, but the
% directory is changed using the working_directory function.
% If cd is executed in the shell, the change of directory is lost when the
% shell exits.
% NOTE: the call to working_directory is wrapped in a catch to display the
% error message but return successfully.
pass_to_os(_,['cd ',X]) :-
  catch(
    working_directory(_,X),
    E,
    (print_message(error,E),true)),
  !.

% a windows Command is executed using process_create rather than shell or
% win_exec. shell does not display output and win_exec displays the output
% too late, as it is asynchronous.  process_create executes synchronously.
% NOTE: the call to process_create is wrapped in a catch to display the
% error message but return successfully.
pass_to_os(windows,Command) :-
  atomics_to_string(Command,'',CommandString),
  split_string(CommandString," ","\s\t\r\n",Args),
  getenv('COMSPEC',CMD), % gets the path to cmd.exe
  catch(
    process_create(CMD,['/C'|Args],[]),
    E,
    print_message(error,E)).

% a posix Command can be executed using shell as it executes synchronously.
% NOTE: the call to shell is wrapped in a catch to display the
% error message but return successfully.
pass_to_os(posix,Command) :-
  atomics_to_string(Command,' ',CommandString),
  catch(
    shell(CommandString),
    E,
    print_message(error,E)).
