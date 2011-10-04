#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'
require 'ostruct'
require './dancemachine'

options = {
    secret: 'honk',
    server: 'irc.freenode.net',
    channel: '2legit2commit',
    nick: 'dancemachine',
    port: '6667',
  }

DanceMachine::Bot.go(options)
