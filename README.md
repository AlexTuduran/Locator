# Locator

Unix command "locate" front-end. A Linux alternative to voidtool's "Everything", written in Lazarus.

Although releases are available containing Linux binaries, you can build Locator yourself.

# Building

Dependencies:
- Lazarus 1.4.0 (FPC 2.6.4)

Get the source code from GitHub (https://github.com/AlexTuduran/Locator):

$ git clone https://github.com/AlexTuduran/Locator.git
$ cd Locator

Load locator.lpr with Lazaru and build. Binary should be created under "/_.bin".

Although you could build it for Windows as well, it wouldn't make much sense, since no "locate" command is natively available and better, free solution "Everything" is available.
