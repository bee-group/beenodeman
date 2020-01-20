# beenodeman

BEENODE wallet/daemon management utilities - version 0.1.28

* This script installs, updates, and manages single-user beenode daemons and wallets
* It is currently only compatible with 32/64 bit linux.
* Multi-user (system directory) installs are not supported

# Install/Usage

To install beenodeman do:

    sudo apt-get install python git unzip pv
    cd ~ && git clone https://github.com/bee-group/beenodeman

To update your existing version 8 32/64bit linux beenode wallet to the latest
beenoded, do:

    beenodeman/beenodeman update

To perform a new install of beenode, do:

    beenodeman/beenodeman install

To overwrite an existing beenode install, do:

    beenodeman/beenodeman reinstall

To update beenodeman to the latest version, do:

    beenodeman/beenodeman sync

To restart (or start) beenoded, do:

    beenodeman/beenodeman restart

To get the current status of beenoded, do:

    beenodeman/beenodeman status


# Commands

## sync

"beenodeman sync" updates beenodeman to the latest version from github

## install

"beenodeman install" downloads and initializes a fresh beenode install into ~/.beenodecore
unless already present

## reinstall

"beenodeman reinstall" downloads and overwrites existing beenode executables, even if
already present

## update

where it all began, "beenodeman update" searches for your beenoded/beenode-cli
executibles in the current directory, ~/.beenodecore, and $PATH.  It will prompt
to install in the first directory found containing both beenoded and beenode-cli.
Multiple wallet directories are not supported. The script assumes the host runs
a single instance of beenoded.

## restart

"beenodeman restart [now]" restarts (or starts) beenoded. Searches for beenode-cli/beenoded
the current directory, ~/.beenodecore, and $PATH. It will prompt to restart if not
given the optional 'now' argument.

<a href="#restart-1">screencap</a>

## status

"beenodeman status" interrogates the locally running beenoded and displays its status

<a href="#status-1">screencap</a>

# Dependencies

* bash version 4
* nc (netcat)
* curl
* perl
* pv
* python
* unzip
* beenoded, beenode-cli - version 8 or greater to update

# Screencaps

### install

<img src="https://raw.githubusercontent.com/bee-group/beenodeman/update/screencaps/beenodeman_0.1-install.png">

### update

<img src="https://raw.githubusercontent.com/bee-group/beenodeman/update/screencaps/beenodeman_0.1-update.png">

### reinstall

<img src="https://raw.githubusercontent.com/bee-group/beenodeman/update/screencaps/beenodeman_0.1-reinstall.png">

### restart

<img src="https://raw.githubusercontent.com/bee-group/beenodeman/update/screencaps/beenodeman_0.1-restart.png">

### status

<img src="https://raw.githubusercontent.com/bee-group/beenodeman/update/screencaps/beenodeman_0.1-status.png">
