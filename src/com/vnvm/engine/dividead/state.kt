package com.vnvm.engine.dividead

class GameState {
	public var options = listOf<Any?>()
	public var optionsMap = listOf<Any?>()
	public var flags: IntArray = IntArray(1000)
	public var title: String = "NoTitle"
	public var mapImage1: String = ""
	public var mapImage2: String = ""
	public var background: String = ""
}