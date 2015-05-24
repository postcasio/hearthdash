# Hearthdash

Hearthdash is a card tracking application for Hearthstone.

![Screenshot](https://github.com/postcasio/hearthdash/raw/master/images/game.png)

![Deck editor](https://github.com/postcasio/hearthdash/raw/master/images/deck.png)

## Features

* Uses packet capturing for foolproof tracking.
* See your opponents play history broken down by turn.
* Sapped your opponents minion? Hearthdash will show it in their hand so you don't forget.
* Easy to use deck editor.

## Downloads

You can download Hearthdash from the [releases](https://github.com/postcasio/hearthdash/releases) page. Currently only builds for OS X are available.

## Building

### Requirements

* OS X, Windows
* nodejs v0.12
* coffee-script
* protobuf

Homebrew is the best way to install Node and protobufs on OS X:

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install node protobuf
    npm install -g coffee-script

### Building

    npm install
    cd capture
    npm install
    cd ../tools
    npm install
    coffee build.coffee --card-xml-path=<path>

Where `path` is the path to the `cardxml0.unity3d` file in the Hearthstone Data directory. If you don't set this paramater, default value is /Applications/Hearthstone/Data/OSX/cardxml0.unity3d

Hearthdash should now be in the `build` directory.

You probably need run with sudo to make sure it can capture network packs.

    sudo build/Hearthdash.app/Contents/MacOS/Atom

