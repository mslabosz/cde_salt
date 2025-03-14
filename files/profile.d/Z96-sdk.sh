#alias sudo='sudo env PATH=$PATH'

if [ -d ~/sdk ]; then
    sdk_root=~/sdk
else
    sdk_root=/opt/sdk
fi

if [ -f ~/.onet_segment ]; then
    export ONET_SEGMENT=$(cat ~/.onet_segment)
fi
# check if stdout is a terminal...
#
#

if [ -t 1 ]; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi


_sdk_use_package_json() {
    # zapozyczone z skryptow bamboo, pewnie od Jozka
    local ARCH=`uname -i`
    local SDK_LIST=''
    local RE=''

    #Pobieramy liste dostepnych SDK
    SDK_LIST=`ls --color=never -1 $sdk_root \
    | grep $(uname -i) \
    | grep node_ \
    | sed -r "s/node_(.*)_$ARCH/\1/" \
    | sort -V -r`

    RULE=`cat ./package.json | grep '"node":' | sed -r 's/\s*"node":\s*"(.*)"\s*/\1/'`

    # Tworzymy regexp na podstawie reguly
    if   [ "$RULE" = "*" ]; then
        RE='.*'
    elif [ -n "$(echo $RULE | grep -ixE '~[0-9]+\.[0-9]+\.[0-9]+')" ]; then
        RE=`echo "$RULE" | sed -r 's/~([0-9]+)\.([0-9]+)\.[0-9]+/\1\\.\2\\.[0-9]*/g'`
    elif [ -n "$(echo $RULE | grep -ixE '>=\s*[0-9]+\.[0-9]+\.[0-9]+')" ]; then
        RE='.*'
    elif [ -n "$(echo $RULE | grep -ixE '[x0-9]+\.[x0-9]+\.x+')" ]; then
        RE=`echo "$RULE" | sed -r 's/\./\\./g' | sed -r 's/x/[0-9]+/g'`
    elif [ -n "$(echo $RULE | grep -ixE '[0-9]+\.[0-9]+\.[0-9]+')" ]; then
        RE=`echo "$RULE" | sed -r 's/\./\\./g'`
    fi
    sdk=`echo "$SDK_LIST" | grep -xE "$RE\.[0-9]+" | head -n1`

}

_sdk_use() {
    if [ $# -eq 1 ]; then
        if [ -d "$sdk_root/$1_$(uname -i)/" ]; then
            sdk_version="$1_$(uname -i)"
        else
            echo "${red}Error sdk not found!${normal}"
            return 1
        fi
    else
        if [ -f "app.yaml" ];  then
            echo "${blue}Reading app.yaml${normal}"
	        sdk=$(cat app.yaml  | grep sdk_version | cut -d ' ' -f2 | sed  s/"\""//g | sed s/"'"//g | sed -e 's/\r$//')
            sdk_version="${sdk}_$(uname -i)"
        elif [ -f "package.json" ]; then
            echo "${blue}Reading package.json${normal}"
            _sdk_use_package_json
            if [ -z "$sdk" ]; then
                echo "${red} SDK not found!${normal}"
                return 1
            fi
            sdk_version="node_${sdk}_$(uname -i)"
        else
            echo "${red}Error app.yaml and package.json not found!${normal}"
            return 1
        fi
        if [ ! -d "$sdk_root/$sdk_version/" ]; then
            echo "${red}Error sdk doesnt exist! $sdk_path${normal}"
            return 1
        fi
    fi
    #echo "${green}Use $sdk_root/${sdk_version}${normal}"
    if [ !  -n "$_OLD_PATH_CDE" ] ; then
        _OLD_PATH_CDE="$PATH"
        export _OLD_PATH_CDE
        _OLD_PS1_CDE="$PS1"
        export _OLD_PS1_CDE
    fi
    _CDE_SDK_LANG=$(echo $sdk_version | cut -d '_' -f 1)
    if [ "$_CDE_SDK_LANG" = "python" ] ;  then
        alias python='python3'
    fi
    sdk_shortname=$(echo $sdk_version | cut -d '_' -f 2)
    #PS1="(${sdk_shortname}) $_OLD_PS1_CDE"

    #alias automator_install=$sdk_root/$sdk_version/automator/install
    alias automator_installdev=$sdk_root/$sdk_version/automator/installdev
    alias automator_startdev=$sdk_root/$sdk_version/automator/startdev
    alias automator_start=$sdk_root/$sdk_version/automator/start
    alias automator_test=$sdk_root/$sdk_version/automator/test

    #export PS1
    export VIRTUAL_ENV=/tmp/$_CDE_SDK_LANG-$sdk_shortname

    NEW_PATH=$sdk_root/$sdk_version/bin/:$_OLD_PATH_CDE

    export PATH=$NEW_PATH
    export NODE_PATH=$sdk_root/$sdk_version/lib/node_modules
    echo "${green}Using ${sdk_version}${normal}"

#    _chown_sdk > /dev/null

    if [ -n "$ONET_SEGMENT" ]; then
       echo "${green}ONET_SEGMENT set to $ONET_SEGMENT${normal}"
    else
        echo "${yellow}ONET_SEGMENT not set${normal}"
    fi

}

_help_function()
{
    echo "Usage: sdk command [params]

Commands:
    use SDK             set PATH with choice SDK
    use                 set PATH with app.yaml or package.json SDK version
    |--- when using SDK you can run alias (without command sdk)
       |- automator_installdev - to install libs 
       |- automator_test - to run test 
    versions            print available SDK versions
    current             print current usage SDK version
    deactivate          deactivate used SDK
    onet_segment SEG    set value of ONET_SEGMENT
    onet_segment        print current value of ONET_SEGMENT
    get VAR             print current value of VAR
    set VAR VALUE       set value of VAR to VALUE"
    return 1
}

_onet_segment()
{

if [ $# -eq 1 ]; then
    echo "${green}Setting ONET_SEGMENT to $1${normal}"
    export ONET_SEGMENT=$1
else
    if [ $ONET_SEGMENT != "" ]; then
       echo "${green}ONET_SEGMENT set to $ONET_SEGMENT${normal}"
    else
       echo "${red}ONET_SEGMENT not set!${normal}"
    fi
fi
}
_bad_command_function()
{
    echo "${red}sdk: can't find command '$1'. Please use -h or --help${normal}"
    return 1
}

_all_available_versions()
{
    result=$(ls -l $sdk_root/ | grep "node\|python" | rev |cut -d' ' -f1 | rev | cut -d'_' -f-1,2)
    echo "$result"
    return 1
}

_current_nodesdk_version()
{
    result=$(echo $PATH | cut -d':' -f1 | cut -d'/' -f4 | cut -d'_' -f-1,2)
    echo "$result"
    return 1
}
_deactivate()
{
    unset VIRTUAL_ENV
    #unset ONET_SEGMENT
    if [  -n "$_OLD_PATH_CDE" ] ; then
        export PATH=$_OLD_PATH_CDE
        export PS1=$_OLD_PS1_CDE
        unset _OLD_PATH_CDE
        unset _OLD_PS1_CDE
    if [ $_CDE_SDK_LANG = "python" ] ;  then
        unalias python
    fi
       #unalias automator_install
       unalias automator_installdev
       unalias automator_start
       unalias automator_startdev
       unalias automator_test
    fi
}
_chown_sdk()
{
    if [ "$USER" = "root"  ]; then
        return
    fi
    for owner in $(ls -l $sdk_root/ | cut -d' ' -f3)
    do
        if [ $owner != "$USER" ]; then
            sudo chown -R $USER:$USER $sdk_root/* >/dev/null
            break
        fi
    done

}
_set_env_var()
{
    if [ $# -eq 2 ];     then 
        export $(echo "$1")=$2
        echo "${green}Setting $1 to $2${normal}"
    else
        echo "${red}To few parameters given!"
	    _help_function
    fi  
}
_get_env_var()
{
    local val=''
    if [ $# -eq 1 ];  then
        val=$(env | grep $1 | cut -d'=' -f 2)
        echo "${green} $1 setted to $val${normal}"
    else
        echo "${red}To few parameters given!"
	    _help_function
    fi  
}

function sdk () {
if [ $# -eq 0  ]
then
    _help_function
fi
arg="$1";

case "$arg" in
    deactivate) _deactivate ;;
    use) _sdk_use $2 ;;
    -h | --help) _help_function ;;
    versions) _all_available_versions;;
    current) _current_nodesdk_version ;;
    onet_segment) _onet_segment $2 ;;
    set) _set_env_var $2 $3 ;;
    get) _get_env_var $2 ;;
    *) _bad_command_function $1;;
esac

}
