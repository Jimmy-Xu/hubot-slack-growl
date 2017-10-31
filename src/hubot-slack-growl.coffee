# Description:
#   notify slack message via growl
#
# Dependencies:
#   node-growl
#
# Configuration:
#   HUBOT_SLACK_MYNAME
#   HUBOT_SLACK_KEYWORDS
#   HUBOT_GNTP_SERVER
#   HUBOT_GNTP_PASSWORD
#
# Commands:
#
#
# Author:
#   Jimmy Xu <xjimmyshcn@gmail.com>
#

# Hidden
#   hubot slack-growl add_keywords <key1,key2...> - Append new sensitive words
#   hubot slack-growl set_keywords <key1,key2...> - Change the whole sensitive words
#   hubot slack-growl get_keywords                - List current sensitive words

nodeGrowl = require 'node-growl'

module.exports = (robot) ->


#==============================
# variable
#==============================
  gntpOpts =
    server: process.env.HUBOT_GNTP_SERVER
    password: process.env.HUBOT_GNTP_PASSWORD
    appname: "hubot-slack-growl"
  keywords = if process.env.HUBOT_SLACK_KEYWORDS then process.env.HUBOT_SLACK_KEYWORDS.split "," else []
  robot.logger.debug ">keywords:#{keywords}"

  #==============================
  # get keyword
  #==============================
  robot.respond /slack-growl get_keywords/i, (response) ->
    if robot.adapterName isnt "slack"
      robot.logger.info ">[Ignore] hubot adapter should be slack, current is #{robot.adapterName}"
      return
    _senderName = response.message.user.name
    robot.logger.debug "#{_senderName} wants to get current keywords"
    if process.env.HUBOT_SLACK_MYNAME isnt _senderName
      robot.logger.debug ">[Ignore] sender is #{_senderName} but HUBOT_SLACK_MYNAME is #{process.env.HUBOT_SLACK_MYNAME}, skip"
      return
    # reply response
    _msgContent = "current keywords is `#{keywords}`"
    response.reply _msgContent
    robot.logger.info "[Reply To #{_senderName}] #{_msgContent}"
  ###
  # send direct message
  room = robot.adapter.client.rtm.dataStore.getDMByName response.message.user.name
  robot.messageRoom room.id, msgContent
  ###


  #==============================
  # set keyword
  #==============================
  robot.respond /slack-growl set_keywords (.*)/i, (response) ->
    if robot.adapterName isnt "slack"
      robot.logger.info ">[Ignore] hubot adapter should be slack, current is #{robot.adapterName}"
      return
    _senderName = response.message.user.name
    robot.logger.debug "#{_senderName} wants to change keywords to: #{response.match[1]}"
    if process.env.HUBOT_SLACK_MYNAME isnt _senderName
      robot.logger.debug ">[Ignore] sender is #{_senderName} but HUBOT_SLACK_MYNAME is #{process.env.HUBOT_SLACK_MYNAME}, skip"
      return
    keywords = if response.match[1] then response.match[1].split "," else []
    # reply response
    response.reply "keywords updated to `#{keywords}`"
    robot.logger.info ">[Reply to #{_senderName}] changed the keywords to #{keywords}"


  #==============================
  # add keyword
  #==============================
  robot.respond /slack-growl add_keywords (.*)/i, (response) ->
    if robot.adapterName isnt "slack"
      robot.logger.info ">[Ignore] hubot adapter should be slack, current is #{robot.adapterName}"
      return
    _senderName = response.message.user.name
    robot.logger.debug "#{_senderName} wants to append keywords: #{response.match[1]}"
    if process.env.HUBOT_SLACK_MYNAME isnt _senderName
      robot.logger.debug ">[Ignore] sender is #{_senderName} but HUBOT_SLACK_MYNAME is #{process.env.HUBOT_SLACK_MYNAME}, skip"
      return
    _newKeywords = if response.match[1] then response.match[1].split "," else []
    keywords = keywords.concat _newKeywords
    # reply response
    response.reply "appended keywords`#{keywords}`"
    robot.logger.info ">[Reply to #{_senderName}] appended new keywords #{keywords}"


  #==============================
  # watch keyword
  #==============================
  robot.catchAll (resp) ->
    if not resp.message.text
      return
    # check adapter
    if robot.adapterName isnt "slack"
      robot.logger.info ">[Ignore] hubot adapter should be slack, current is #{robot.adapterName}"
      return
    _regSet = /hubot.*slack-growl set_keywords (.*)/i
    _regAdd = /hubot.*slack-growl add_keywords (.*)/i
    _regGet = /hubot.*slack-growl get_keywords/i
    if _regSet.test(resp.message.text) or _regGet.test(resp.message.text) or _regAdd.test(resp.message.text)
      robot.logger.debug ">[Ignore] this is respond message '#{resp.message.text}'"
      return
    # resolve room and message
    _room = robot.adapter.client.rtm.dataStore.getChannelGroupOrDMById resp.message.user.room
    _msgTitle = "From Slack[\##{_room.name} #{resp.message.user.name}]"
    _msgContent = resp.message.text
    # check keywords in message
    suffix = "[gen]"
    _found = keywords.filter (x) ->
      _reg = new RegExp(x, 'i')
      _reg.test resp.message.text
    if _found.length > 0
      robot.logger.debug ">keywords is matched: #{_found}"
      suffix = "[key]"
    else
      robot.logger.debug ">keywords isn't matched: #{_found}"
    if _room.name is "DM"
      suffix = "[dm]"
    # send notify to growl
    _gntpOpts =
      server: gntpOpts.server
      password: gntpOpts.password
      appname: gntpOpts.appname + suffix
    nodeGrowl _msgTitle, _msgContent, _gntpOpts, (text) ->
      if text isnt null
        robot.logger.info ">[room:\##{_room.name} sender:#{resp.message.user.name}] gntp-send failed(#{text})"
      else
        robot.logger.info ">gntp-send OK"
