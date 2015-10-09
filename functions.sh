#create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

#typing pbpaste & pbcopy is a pain.
#I think what this does is checks if there's anything in the clipboard, and
#paste it if it is, else copy what follows
function clip() {
  [ -t 0 ] && pbpaste || pbcopy;
}

#using arcanist? Then you may end up with a bunch of branches named
#Arcpath-XXX-N littering your repos
#delete them from your local repo with this
function clean_arcpatch(){
  if test ! $(which git)
  then
    echo "Git is not installed. What is wrong with you?"
    exit
  fi
  for ref in $(git for-each-ref --format='%(refname)' refs/heads/arcpatch*); do
    branch_name=`echo $ref | cut -f 3 -d '/'`
    echo $(git branch -D $branch_name)
  done
}

function clean_hotfixes(){
  if test ! $(which git)
  then
    echo "Git is not installed. What is wrong with you?"
    exit
  fi
  branches=$(git for-each-ref --format='%(refname)' refs/heads/hotfix*)
  branch_count=${#branches[@]}
  echo "There were ${branch_count} branches found."
  echo ${branches[@]}
  #why is this returning an array of length 1, but the first entry is an empty string?
  echo "|${branches[0]}|"
  exit 1
  #TODO: count number of refs that match, and how many are deleted
  #TODO: if there are no branches matching the name/pattern, say so
  for ref in $branches; do
    branch_name=`echo $ref | cut -f 3 -d '/'`
    echo $(git branch -D $branch_name)
  done
}

#should operate very similar to pushd
#allow you to switch between git branches quickly
function pushbr(){
  #TODO: where/how does pushd/popd store the directory stack?
  #Cheat by putting it in an environment variable for now?
  #
  # verify that destination branch exists
    # lookup in local branches
  # stash current changes
  # store the id/ref of the stash
  # get current branch name
  # switch to branch specified by arg
  #
  #http://stackoverflow.com/questions/9916551/pushd-popd-global-directory-stac
  echo "pushbr()"
}

#should operate very similar to pushd
#allow you to switch between git branches quickly
function popbr(){
  # reverse of pushbr
  echo "popbr()"
}

# far too clever way to do what should be a simple task
# TODO: make sure this works!
function open_files_matching(){
  SEARCH_REGEX=$1
  PATH=$2
  #TODO: only open if there are matches, else give an error message
  #TODO: why is this failing on a "ag: command not found" error?
  FILE_LIST=$(ag -l $SEARCH_REGEX $PATH)
  echo $FILE_LIST
  #| xargs -o vim -p
}

