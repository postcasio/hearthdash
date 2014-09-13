# Hearthdash

Hearthdash is a card tracking application for Hearthstone.

![Screenshot](https://github.com/postcasio/hearthdash/raw/master/images/game.png)

![Deck editor](https://github.com/postcasio/hearthdash/raw/master/images/deck.png)

## Features

* Uses packet capturing for foolproof tracking.
* See your opponents play history broken down by turn.
* Sapped your opponents minion? Hearthdash will show it in their hand so you don't forget.
* Easy to use deck editor.

## Getting Started

Hearthdash isn't 100% ready yet, so you need to build it.

### Requirements

* OS X, Windows
* nodejs v0.10
* coffee-script
* protobuf

Homebrew is the best way to install Node and protobufs on OS X:

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install node protobuf
    npm install -g coffee-script

### Building

    cd tools
    npm install
    coffee build.coffee --card-xml-path=<path>

Where `path` is the path to the `cardxml0.unity3d` file in the Hearthstone Data directory.

Hearthdash should now be in the `build` directory.
