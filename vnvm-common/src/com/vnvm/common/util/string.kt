package com.vnvm.common.util

import com.vnvm.common.clamp

fun String.substr(start: Int, length: Int): String = this.substring(start.clamp(0, this.length), (start + length).clamp(0, this.length))
