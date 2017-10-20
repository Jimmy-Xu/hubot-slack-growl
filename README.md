hubot-slack-growl
============================================
Hubot plugin for notify slack message via growl


# Dependency

- hubot 2.19.0
- coffee-script@^1.12.6
- [node-growl](https://www.npmjs.com/package/node-growl)
- gntp-send ([source](https://github.com/mattn/gntp-send.git))

# Env

- HUBOT_MYNAME(slack name)
- HUBOT_GNTP_SERVER
- HUBOT_GNTP_PASSWORD

# Installation

## Install hubot

```
$ sudo npm install -g yo generator-hubot

$ mkdir myhubot
$ cd myhubot
$ yo hubot
```

## Install hubot-slack-growl

In hubot project repo, run:

`$ npm install hubot-slack-growl --save`

Then add **hubot-slack-growl** to your `external-scripts.json`:

```json
[
  "hubot-slack-growl"
]
```


# Debug

```
//use slack as adapter
HUBOT_LOG_LEVEL=debug  bin/hubot --name myhubot --adapter slack
```
