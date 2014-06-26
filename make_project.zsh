
PROJECT_HOST="l1"

function _remote_repo_init () {
    REPO="$1.git"
    ssh "$PROJECT_HOST" "cd git && mkdir $REPO && cd $REPO && git init --bare"
}

function _clone_remote_repo () {
   USER=`whoami`
   git clone "$USER@$PROJECT_HOST:git/$1.git"
}

function mkproject () {
     _remote_repo_init "$1" && \
         _clone_remote_repo "$1" && \
        cd "$1"
}

function _git_ignore () {
    echo $1 >> .gitignore
}

function _init_readme () {
   touch README.md
   echo "# $1" >> README.md
 }

function init_py_project () {
    _git_ignore "*.pyc"
    _git_ignore "env"
    _git_ignore "build"
    _git_ignore "__pycache__"
    _git_ignore "*#"
    _git_ignore "*~"
    _git_ignore ".#*"

    touch requirements.txt

    _init_readme "$1"

    echo "from setuptools import setup" > setup.py
    echo "" >> setup.py
    echo "setup(name='$1')" >> setup.py
}

function _initial_commit () {
    pwd
    git add . && \
        git commit -m "Initial commit" && \
        git push
}

function _init_virtualenv () {
    virtualenv -p "$1" env/ && \
        source env/bin/activate && \
        pip install -r requirements.txt
}

function mkpy3proj () {
    mkproject "$1" && \
        init_py_project "$1" && \
        _initial_commit && \
        _init_virtualenv "python3" &&
        source env/bin/activate
}
