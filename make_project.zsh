
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

function _default_git_ignores () {
   _git_ignore "*#"
   _git_ignore "*~"
   _git_ignore ".#*"
   _git_ignore "tags"
   _git_ignore "TAGS"
}

function _init_readme () {
   touch README.md
   echo "# $1" >> README.md
 }

function init_py_project () {
    _default_git_ignores
    _git_ignore "*.pyc"
    _git_ignore "*.egg-info"
    _git_ignore "env"
    _git_ignore "build"
    _git_ignore "__pycache__"

    touch requirements.txt

    _init_readme "$1"

    echo "from setuptools import setup" > setup.py
    echo "" >> setup.py
    echo "setup(name='$1')" >> setup.py
}

function _initial_commit () {
    git add . && \
        git commit -m "Initial commit" && \
        git push
}

function _init_virtualenv () {
    virtualenv -p "$1" env/ && \
        source env/bin/activate && \
		python setup.py develop
}

function mypythonproj () {
    mkproject "$1" && \
        init_py_project "$1" && \
        _initial_commit
}

function mkpy3proj () {
	mypythonproj "$1" && \
        _init_virtualenv "python3" && \
        source env/bin/activate
}

function setup_hs_project () {
	touch README.md

    _default_git_ignores
	_git_ignore "*.hi"
	_git_ignore "*.o"
	_git_ignore ".cabal-sandbox"
	_git_ignore "$1"

	echo "$1: $1.hs" > Makefile
	echo "\tghc --make *.hs" >> Makefile
	echo "main = putStrLn \"Hello world\"" > "$1.hs"
}

function mkhsproject () {
	mkproject "$1" && \
		setup_hs_project "$1" && \
		cabal sandbox init && \
		_initial_commit && \
		make && \
		./$1
}

function setup_rust_project () {
    echo "# $1" >> README.md

    _default_git_ignores
    _git_ignore "target"

    mkdir src
    echo "fn main() {
    println!("Hello, world!");
}" > src/$1.rs

    echo "[package]

name = "$1"
version = "0.0.1"
authors = [ "Jeremy Mikkola <jeremy@jeremymikkola.com>" ]

[[bin]]

name = "$1"
" > Cargo.toml
}

function mkrustproject () {
    mkproject "$1" && \
        setup_rust_project "$1" && \
        cargo build && \
        _initial_commit && \
        ./target/$1
}
