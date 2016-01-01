package com.vnvm.ui

import com.vnvm.common.Point
import com.vnvm.common.collection.without

object SpatialMenu {
	data class Item<TOption>(val pos: Point, val option: TOption)

	// From the list options without selectOption which one is to the right
	fun <TOption> moveRight(options: List<Item<TOption>>, sel: Item<TOption>): Item<TOption> {
		return _move2(options, sel, +1, true)
	}

	fun <TOption> moveLeft(options: List<Item<TOption>>, sel: Item<TOption>): Item<TOption> {
		return _move2(options, sel, -1, true)
	}

	fun <TOption> moveDown(options: List<Item<TOption>>, sel: Item<TOption>): Item<TOption> {
		return _move2(options, sel, +1, false)
	}

	fun <TOption> moveUp(options: List<Item<TOption>>, sel: Item<TOption>): Item<TOption> {
		return _move2(options, sel, -1, false)
	}

	fun <TOption> _move2(options: List<Item<TOption>>, sel: Item<TOption>, mult: Int, isx: Boolean): Item<TOption> {
		fun Point.s() = if (isx) this.x else this.y
		return _move(
			options,
			sel,
			{ it, sel -> it.pos.s().compareTo(sel.pos.s()) * mult > 0 },
			{ dx, dy -> if (isx) (dx * dx) / dy else (dy * dy) / dx },
			{ it, sel -> Math.abs(it.pos.s() - sel.pos.s()).toDouble() }
		) ?: sel
	}

	private fun <TOption> _move(
		options: List<Item<TOption>>,
		sel: Item<TOption>,
		filtering: (it: Item<TOption>, sel: Item<TOption>) -> Boolean,
		scoring: (dx: Double, dy: Double) -> Double,
		scoring2: (it: Item<TOption>, sel: Item<TOption>) -> Double
	): Item<TOption>? {
		val availableOptions = options.without(sel).filter { filtering(it, sel) }
		val scores = availableOptions.map {
			val dx = Math.abs(it.pos.x - sel.pos.x).toDouble()
			val dy = Math.abs(it.pos.y - sel.pos.y).toDouble()
			scoring(dx, dy)
		}
		val maxScore = scores.max()
		val bestOption = availableOptions.zip(scores)
			.filter { it.second == maxScore }
			.map { it.first }
			.sortedByDescending { scoring2(it, sel) }
			.firstOrNull()
		return bestOption
	}
}