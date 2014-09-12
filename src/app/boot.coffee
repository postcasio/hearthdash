path = require 'path'
{$} = require 'space-pen'
HearthDash = require './hearth-dash'

$ ->
	window.dash = new HearthDash
	dash.initialize()
	dash.dashboardView.fadeIn()
