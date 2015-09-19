#!/bin/bash

# NAME 
#   eptolite - a small bash library for robust and maintainable scripts
#
# SYNTAX
#   . /usr/lib/eptolite.sh
#
# DESCRIPTION
#   eptolite is a small framework and library for developing industrial strength
#   shell scripts of high quality, readability, and maintainability. 
#
#   It makes handling of errors, process exits, tracing (logging), and options
#   uniform, streamlined and often easy.
#
#   It does "set -eu" for fail-fast behaviour (-e) and exiting if the script
#   references a variable that has not been set, not even to "" (-u).
#   If you do not want that, disable it with "set +eu" after sourcing
#   eptolite.
#   
#  If you use the standards options that eptolite supports,
#  (that is, unless nostdopts is called before parsing options), 
#  the following standard options are handled:
#      [-DvV] [-A logfile] [-F logfile]
#
#  The program comment for your program needs to include the above line
#  in the SYNTAX section, and the OPTIONS section can be copied from
#  the options section in this comment.
#   
#  If your program "xyz" uses options "[-agX] [-E errorlevel]" and arg "file"
#  your SYNTAX section of the program comment would preferably look like:
#      xyz [-aDgvVX] [-A logfile] [-E errorlevel] [-F logfile] file
#   
# OPTIONS 
#   -A logfile    append.  Append logs and traces to the given file.
#   -D            debug.   Do "set -x". Use it twice (eg. -DD) to do "set -vx"
#   -F logfile    logfile. Truncate and use logfile for logs and traces. 
#   -v            version. Print version and exit.
#   -V            Verbose. Turn on verbose mode.
#    
# EXAMPLES
#   Assume variable 'progname' has value xyz, 
#   Full syntax (including program name is):
#       xyz [-aDgvVX] [-A logfile] [-E errorlevel] [-F logfile] file
#
#   Here we go:
#
#
#     . /usr/lib/epto
#     
#     setsyntax "[-aDgvVX] [-A logfile] [-E errorlevel] [-F logfile] file"
#     setversion 1.0          # or leave this out if not relevant
#     
#     parse_and_shift_away_options
#     
#     all=
#     really_all=
#     global=true
#     extract=
#     errlvl=0
#     
#     [ $opt_a ]  &&  all=true
#     [ $opt_g ]  &&  global= 
#     [ $opt_X ]  &&  extract=true; 
#     [ $opt_E ]  &&  errlvl=$opt_E_arg
#
#     [ $opt_a_count -gt 1 ]  &&  really_all=true   # even dot files
#
#     isint $errlvl   ||  syndie "-E takes int argument, got '$errlvl'."
#     [ $# -eq 1 ]    ||  syndie "Expected 1 argument, got $#"
#     
#
#     file=$1
#     
#     [ -r "$file" ]  ||  die "Unreadable or non-existent file: $file]
#     
#     
#     if [ $extract ]
#     then
#         :
#         :
#         :
#         :
#     fi
#
#     :
#     :
#     :
#     
#     exit 0
#
#---------------------     
#   Some more exaples.   
#     
#   In the comments below, that describe ouput or effect,
#   syntax stands for the full syntax, the file is a.txt,
#   \n is used to indicate linebreak.
#
#   
#     msg      			    # outputs nothing
#     msg "Can't open file $file"   # outputs: xyz: Can't open file a.txt
#     errmsg blaha 		    # like msg but output to standard error
#     die "$file empty"		    # does: errmsg "$@"; exit 1
#     syndie "No args."		    # does: errmsg "No args.\n$syntax"; exit 2
#     msgdie "All is well."	    # does: msg "All is well."; exit 0
#     logfile			    # echo current logfile. default: /dev/fd/2
#     logfile blah.log		    # new current logfile is blah.log
#     dolog blah		    # appends "blah" to current logfile
#     multilog blah		    # does: msg "blah"; dolog "blah"
#     grexist blah $file	    # no output. exit 0 if match, else not 0 
#     assert grexist blah $file     # exit != 0 --> die "Assertion failed: $@"
#     isint $i  		    # 34 -9 returns 0. 23f a &7 returns not 0.
#     
#   To reset current logfile to its original value, do "setlog /dev/fd/2".
#  
# VARIABLES  
#   progname   - Set by eptolite. The programs name. 
#   syntax     - Set by you in your shell script. 
#                It should follow the pattern "progname [-opts] args"
#
# COPYRIGHT
#   Copyright (c) 20110-2015 jenmol@users.noreply.github.com
#   
#   This copyright and this softwares license does not extend 
#   to files that include, or otherwise use, this file. 
#
# LICENSE   
#   MIT license
#   
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files
#   (the "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so,
#   subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
#   OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
#   THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
	
set -eu

###################################
################################### Public eptolite functions.
###################################


msg        () { [ $# -gt 0 ]  &&  echo "$progname_:" "$@"; :;}
errmsg     () { msg "$@" >&2; }

die        () { errmsg "$@"; exit 1; }
funcdie    () { die "${FUNCNAME[1]}: $@"; }  # only use in your functions
syndie     () { errmsg "$@"; echo "$syntax_"; exit 2; }
msgdie     () { msg "$@"; exit 0; }
assert     () { "$@"  ||  die "Assertion failed:" "$@"; }

isint      () { echo "$1" | grep -P '^\s*-?[0-9]+\s*$' >& /dev/null; } 
incr       () { local n_=1; [ $# -eq 2 ] && n_=$2; eval $1=$(($1 + n_)); }
decr       () { local n_=1; [ $# -eq 2 ] && n_=$2; eval $1=$(($1 - n_)); }

grexist    () { grep "$@" >/dev/null 2>&1; }

logmsg     () { msg "$@" >>$logfile_; }
vlogmsg    () { [ $verbose ] && log "$@"; :; }
vvlogmsg   () { [ $veryverbose ] && log "$@"; :; }

logcmd     () { logmsg "$@"; "$@"; }
vlogcmd    () { [ $verbose ] && logcmd "$@"; :; }
vvlogcmd   () { [ $veryverbose ] && logcmd "$@"; :; }

trace      () { msg "trace:    $(datetime): $@" >>$logfile_; }
vtrace     () { [ $verbose ] && trace "$@"; :; }
vvtrace    () { [ $veryverbose ] && trace "$@"; :; }
	
tracecmd   () { msg "tracecmd: $(datetime): $@" >>$logfile_; "$@"; }
vtracecmd  () { [ $verbose ] && tracecmd "$@"; :; }
vvtracecmd () { [ $veryverbose ] && tracecmd "$@"; :; }

multilog   () { msg "$@"; logmsg "$@"; }

logfile    () { assert [ $# -eq 0 ]; echo $logfile_; }
setlog     () { logfile_=$1;[ -f "$logfile_" ] && >$logfile_; :; }
appendlog  () { logfile_=$1; }

first      () { nth 0 "$@"; }
rest       () { [ $# -eq 0 ] && return 0; shift; echo ${@+"$@"}; }
nth        () { [ $# -le "$1" ] && return 0; shift $1; shift; echo $1; } 
nelems     () { echo $#; }

for_each   () { local f_=$1 i_; shift; for i_ in "$@"; do $f_ $i_; done; }
abspath    () { echo $1|perl -wlpe 'chomp($p=`pwd`);$_=$p."/$_" if!m:^\s*/:;'; }

pushv      () { eval $1+=\(\"\$2\"\); }        # add after last element
topv       () { eval echo \"\${$1[@]: -1}\"; } # last element (highest index)
popv       () { eval unset $1[\${#$1[@]}-1]; } # unset last element 
 
datetime   () { date '+%Y-%m-%d: %H.%M.%S: %z'; }

nostdopts  () { nostdopts_=true; }
setsyntax  () { [ $# -eq 1 ] || funcdie "1 arg only";syntax_=$1;setopts_ "$1"; }
setversion () { progversion_="$@"; }
setoptions () { opts_=$1; }  # only need to use if setsyntax doesn't work (rare)

shopt -s expand_aliases

alias parse_and_shift_away_options='optparse_ ${opts_}$stdopts_ "$@" && 
                                    handle_standard_options_ && 
                                    shift $(expr $OPTIND - 1)'


###################################
###################################  Internal eptolite functions, Stay away.
###################################  Do not change anything (unless you really
###################################  know what you're doing).
###################################



init_opt_        () { eval opt_$1=; }
init_optarg_     () { eval opt_$1_arg=; }
init_optcount_   () { eval opt_$1_count=0; }
init_optarg_all_ () { eval opt_$1_all=; }
init_optarg_argv_() { eval declare -ga opt_$1_argv=; }


optparse_ ()   # example:  optparse "abcd:e:qz" "$@"
{
    local optstr=$1
    local opts_woarg   # letters for options without arguments, space separated
    local opts_warg    # letters for options with arguments, space separated
    local allopts      # all option letters, separated by space
    local opt          # used in getopts


    shift

    opts_woarg=$(echo $optstr | sed 's/[a-zA-Z]://g' | sed 's/\(.\)/\1 /g')

    opts_warg=$(echo $optstr                         |
                sed 's/[a-zA-Z]*\([a-zA-Z]\)/\1/g'   |
                sed 's/[a-zA-Z]$//'                  |
                sed 's/:/ /g')


    allopts="$opts_woarg $opts_warg"


    for_each init_opt_  $allopts
    for_each init_optarg_  $opts_warg
    for_each init_optcount_  $allopts
    for_each init_optarg_all_  $opts_warg
    for_each init_optarg_argv_  $opts_warg

    while getopts ":$optstr"  opt
    do
        case $opt in
            [a-zA-Z])  handle_opt_ $opt ${OPTARG:+"$OPTARG"};;
	    \?) syndie "Illegal option: -$OPTARG";;
	    :)  syndie "Option requires an argument: -$OPTARG";;
        esac
    done

    shift `expr $OPTIND - 1` # Locally shift away options to get arguments.
                             # We also have to shift the real command line
                             # outside any function.
    return 0;
}


# handle_opt_ optletter [optarg]
#
handle_opt_ ()
{
    local letter=$1; shift

    eval opt_$letter=true
    incr opt_${letter}_count

    if [ $# -gt 0 ]  # if arg exist, handle that
    then
        eval opt_${letter}_arg=\"\$*\"
        eval opt_${letter}_all=\"\$opt_${letter}_all\ \$*\"

	pushv opt_${letter}_argv "$*"
    fi
    
    return 0;
}





handle_standard_options_ ()
{
    [ $nostdopts_ ]  &&  return 0

    verbose=
    veryverbose=

    [ $opt_v ] && { msgdie  "Version: $progversion"; }

    [ $opt_D ]             && set -x
    [ $opt_D_count -ge 2 ] && set -v

    [ $opt_V ] && verbose=true
    [ $opt_V_count -ge 2 ] && veryverbose=true

    [ $opt_F ]  &&  [ $opt_A ]  &&  syndie "You can't specify both -A and -F"

    [ $opt_F ]  &&  setlog "$opt_F_arg"
    [ $opt_A ]  &&  appendlog "$opt_A_arg"

    return 0;
}

setopts_ () 
{
    echo "$1" | grexist grep -P '^\s*\['  &&  syntax_="$progname_ $1"
    [ -n "$opts_" ]  &&  return 0;
    opts_=$1
    
    
    opts_=$(echo "$opts_" | perl -lpe 's/\-\-.*$//g') # del -- and beyond

    
    opts_=$(echo "$opts_" | perl -lpe 's/^[^[]*//')   # del progname
    opts_=$(echo "$opts_" | perl -lpe 's/\][^[]+\[/\] \[/g') # del between ] [
    opts_=$(echo "$opts_" | perl -lpe 's/\][^[]+$/\]/') # del tail after last ]

    opts_=$(echo "$opts_" | perl -lpe 's/\[\s*/[/g; s/\s*\]/]/g') # del spc

    opts_=$(echo "$opts_" | perl -lpe 's/\[[^-][^]]+\]//g') # del non-options
    opts_=$(echo "$opts_" | perl -lpe 's/\[\-[^a-zA-Z].*?\]//g') #del non-letter
    opts_=$(echo "$opts_" | perl -lpe 's/\[(\-[a-zA-Z]+)\s+.*?\]/\[$1 \: \]/g')
    opts_=$(echo "$opts_" | perl -lpe 's/\s|\[|\]|\-//g') # del spc [ ] -
}


nostdopts_=
progname_=`basename $0`
progversion_=${progversion:-"N/A"}

logfile_=/dev/fd/1

opts_=
stdopts_="A:DF:vV"  # standard options


:



