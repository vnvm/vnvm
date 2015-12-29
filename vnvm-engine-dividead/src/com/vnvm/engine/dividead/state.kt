package com.vnvm.engine.dividead

import com.vnvm.common.IRectangle

class GameState {
	data class Option(val pointer:Int, val text: String)
	data class MapOption(val pointer:Int, val rect: IRectangle)

	public var options = arrayListOf<Option>()
	public var optionsMap = arrayListOf<MapOption>()
	public var flags: IntArray = IntArray(1000)
	public var title: String = "NoTitle"
	public var mapImage1: String = ""
	public var mapImage2: String = ""
	public var background: String = ""
}