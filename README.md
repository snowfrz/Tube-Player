# Tube Player
A free and open-source iOS app that allows you to view, organize, download and share YouTube videos.

Designed by [Justin Proulx](https://www.twitter.com/justinalexp)

# Download
[Version 1.0.0](https://github.com/Sn0wCh1ld/Tube-Player/releases/download/1.0.0/Tube.Player.1.0.0.ipa)

Other versions are available [here](https://github.com/Sn0wCh1ld/Tube-Player/releases)

# How to install
Most people should install Tube Player using [Impactor](http://www.cydiaimpactor.com).

1. Download the .ipa for Tube Player using the link above (in the Download section)
2. Download Impactor
3. Open Impactor
4. Attach your device
5. Trust the computer you are attached to, if asked
6. When Impactor recognizes your device, drag Tube Player's .ipa file (the one you downloaded in step 1) onto its name
7. You will be asked to put in your Apple ID username and password. Enter them.
8. Wait for Tube Player to install.
9. Enjoy!

# Features
- Downloading in SD and HD
- Ability to make playlists
- Ability to save videos to camera roll, and share it in other ways
- Can become a dedicated ASMR player and manager if you're into that
- Open source, so you can modify it to your needs

# Commands
There are some special commands you can use to change app settings. I should have made a settings panel, but (long story) I ended up using a command system instead. Don't worry though, you shouldn't have to change these settings very often.

You use commands by typing a hashtag (#) in the search bar on the Search tab, followed by the command. For example, `#devdl`.

Here are the commands and their functions:

`devdl`: Enables/Disables downloading features

`devpirate`: Re-enables the piracy discouragement notice

`ASMR`: Enables the ASMR filter, turning the app into an ASMR viewer, manager and downloader

# Issues and Limitations
- Can't log in to YouTube accounts (because of the YouTube API)
- Can't reorder playlists, or videos within the playlists
- No shuffle function yet
- No nested playlists (folder system)
- Image disappears sometimes if you exit the app and come back in during playback (you can make it reappear by switching to another tab, then back to the Now Playing tab)

# Note to other developers
If any of you dare to venture into the depths of my code, I apologize in advance. I'm not exactly the best developer ever (my current excuse is that I'm only 17), and I made many mistakes in the creation of this app, some of which were not easily fixable before release. None of them affect the user experience in any way, but might make you sad if you look at them. Just as an example, at first, I was using NSDictionaries to handle video metadata, sending them around as if they were custom video objects. And then, someone suggested to me that I just make a custom video object class with all the metadata as properties, and I was like "huh, true". Now, there's like one place where I use a custom object, and everywhere else uses dictionaries. I'm still learning, and I'm glad to say that I am improving. Thanks for the understanding :)

# What's with the ASMR specialization and other weird stuff in-app?
Well, Tube Player was actually originally called "Relax", and was a dedicated ASMR viewer, manager and downloader, destined for the App Store. Unfortunately, the downloading part violated the App Store terms and conditions, so Relax was rejected. I started changing the app so it would be allowed on the store (removing downloading features, changing IAPs), but I decided to instead just move the ASMR stuff to a command and release the app here. That's why the app icon seems irrelevant and there's a specific ASMR command (I just converted it into a command when I decided to make Tube Player an all-purpose YouTube player). It also explains the `devdl` command, which exists because I needed to disable downloading for the App Store.

# License
This software is licensed under the MIT License, detailed in the file LICENSE.md

In addition to the terms outlined in the MIT License, you must also include a visible and easily useable link to my Twitter account (currently @JustinAlexP), as well as one to my PayPal.me page (https://www.paypal.me/sn0wch1ld). If you really don't want to include one, contact me on Twitter @JustinAlexP and we'll come up with an agreement.
