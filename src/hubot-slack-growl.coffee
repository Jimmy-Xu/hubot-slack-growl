# Description:
#   notify slack message via growl
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MYNAME
#   HUBOT_KEYWORDS
#   HUBOT_GNTP_SERVER
#   HUBOT_GNTP_PASSWORD
#
# Commands:
#   hubot slack-growl change <keywords> - Change the sensitive words
#
# Author:
#   Jimmy Xu <xjimmyshcn@gmail.com>
#

nodeGrowl    = require 'node-growl'

module.exports = (robot) ->

###################################################
# func
###################################################
  gntpOpts =
    server: process.env.HUBOT_GNTP_SERVER
    password: process.env.HUBOT_GNTP_PASSWORD
    appname: "hubot-slack-growl"
  keywords = if process.env.HUBOT_KEYWORDS then process.env.HUBOT_KEYWORDS.split "," else []

  ###################################################
  # change keyword
  ###################################################
  robot.respond /slack-growl change (.*)/i, (msg) ->
    keywords = if msg.match[1] then msg.match[1].split "," else []
    msg.send "Changed the keywords to:", keywords

  ###################################################
  # watch keyword
  ###################################################
  robot.hear /.*/i, (data) ->
    msgContent = data.message.text
    senderName = data.message.user.name
    if robot.adapterName is "slack"
      room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById data.message.user.room
      roomName = room.name
      console.log "[Heard from Slack] room:[\##{roomName}], sender:[#{senderName}], message:[#{text}]"
    else
      roomName = data.message.user.room
      console.log "[Heard from #{robot.adapterName}] room:[#{roomName}], sender:[#{senderName}], message:[#{text}]"

    if process.env.HUBOT_MYNAME is senderName
      found = keywords.filter (x) -> msgContent.indexOf x >= 0
      if found.length > 0
        console.log "keyword matched:", found
        msgTitle = "From Slack[\##{roomName} #{senderName}]"
        nodeGrowl msgTitle, msgContent, gntpOpts, (text) ->
          console.log "gntp result:", if text is null then "OK" else text
      else
        console.log "no keyword matched, ignore"
    else
      console.log "sendName:", senderName, " but HUBOT_MYNAME is ", process.env.HUBOT_MYNAME
