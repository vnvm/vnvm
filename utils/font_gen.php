<?php

$block_w = 32;
$block_h = 32;
$font_size = 24;
$characters_per_row = 16;
$characters_per_column = 16;

$i = imagecreatetruecolor($block_w * $characters_per_row, $block_h * $characters_per_column);
$ci = imagecreatetruecolor($block_w, $block_h);
$c1 = imagecolorallocate($ci, 0, 0, 0);
$c2 = imagecolorallocate($ci, 255, 255, 255);

for ($n = 0; $n < 256; $n++) {
	//$cc = 0x3042 + $n;
	$cc = $n;

	imagefilledrectangle($ci, 0, 0, $block_w, $block_h, $c1);
	$info = imagettfbbox($font_size, 0, 'epminbld.ttf', '&#' . $cc . ';');
	//$y = -$info[7] + $info[3];
	$y = $font_size;
	echo "$n\n";
	//print_r($info);
	imagettftext($ci, $font_size, 0, 0, $y, $c2, 'epminbld.ttf', '&#' . $cc . ';');

	imagecopy($i, $ci, ($n % $characters_per_row) * $block_w, (int)($n / $characters_per_row) * $block_h, 0, 0, $block_w, $block_h);

	//imagettftext($i, 32, 0, 100, 100, $c2, 'epminbld.ttf', 'Hello world &#x3042;');

	imagepng($i, 'test.png');
}