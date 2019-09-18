I learned a lot about reverse engineering network protocols when I made this. I also learned a lot about separation of concerns. The code in this repository is not particularly good, but, I still like what I made.

***

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
