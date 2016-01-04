if [[ -z $AUTOENV_AUTH_FILE ]]; then
    AUTOENV_AUTH_FILE=~/.autoenv_authorized
fi

if [[ -z $COLORS ]]; then
    COLORS=true
fi

if [ -n "$ZSH_VERSION" ]; then
   # assume Zsh
   chpwd_functions+=( autoenv_init )
elif [ -n "$BASH_VERSION" ]; then
   # assume Bash
   cd() { builtin cd "$@" && autoenv_init; }
fi

autoenv_init(){
    _AUTOENV_OLDPATH="$OLDPWD"
    _AUTOENV_NEWPATH="$(pwd)"

    while [[ ! "$_AUTOENV_NEWPATH" == "$_AUTOENV_OLDPATH"* ]]
    do
        if [[ -f "$_AUTOENV_OLDPATH/.out" ]]
        then
            check_and_exec "$_AUTOENV_OLDPATH/.out"
        fi
        _AUTOENV_OLDPATH="$(dirname $_AUTOENV_OLDPATH)"
    done

    if [[ $_AUTOENV_OLDPATH == '/' ]]; then
        _AUTOENV_OLDPATH=''
    fi

    while [[ ! "$_AUTOENV_OLDPATH" == "$_AUTOENV_NEWPATH"  ]]
    do
        _AUTOENV_OLDPATH="$_AUTOENV_OLDPATH$(echo -n '/'; echo ${_AUTOENV_NEWPATH#${_AUTOENV_OLDPATH}} | tr \/ "\n" | sed -n '2p' )"
        if [[ -f "$_AUTOENV_OLDPATH/.env" ]]
        then
            check_and_exec "$_AUTOENV_OLDPATH/.env"
        fi
    done  
}

check_and_run(){
    if [[ $COLORS == true ]]
    then
        echo -e "\x1b[32m> \x1b[31mWARNING\x1b[0m"
        echo -e "\x1b[32m> \x1b[34mThis is the first time you are about to source \x1b[33m\"\x1b[31m$1\x1b[33m\"\x1b[0m"
        echo
        echo -e "\x1b[32m--------------------------------------------------------------------------------\x1b[0m"
        if hash pygmentize 2>/dev/null
        then
            echo
            `whence pygmentize` -f 256 -l shell -g "$1"
        else
            echo -e "\x1b[32m"
            cat $1
        fi
        echo
        echo -e "\x1b[32m--------------------------------------------------------------------------------\x1b[0m"
        echo
        echo -ne "\x1b[34mAre you sure you want to allow this? \x1b[36m(\x1b[32my\x1b[36m/\x1b[31mN\x1b[36m) \x1b[0m"
    else
        echo "> WARNING"
        echo "> This is the first time you are about to source \"$1\""
        echo
        echo "--------------------------------------------------------------------------------"
        echo
        cat $1
        echo
        echo "--------------------------------------------------------------------------------"
        echo
        echo -n "Are you sure you want to allow this? (y/N)"
    fi
    read answer
    if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]
    then
        echo "$1:$2" >> $AUTOENV_AUTH_FILE
        envfile=$1
        shift
        source $envfile
    fi
}

check_and_exec(){
    if which shasum &> /dev/null
    then
        hash=$(shasum "$1" | cut -d' ' -f 1)
    else
        hash=$(sha1sum "$1" | cut -d' ' -f 1)
    fi
    if grep --quiet "$1:$hash" "$AUTOENV_AUTH_FILE"
    then
        envfile=$1
        shift
        source $envfile
    else
        check_and_run $1 $hash
    fi
}