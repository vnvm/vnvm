<?php

$i = imagecreatetruecolor(600, 600);
$c1 = imagecolorallocate($i, 0, 0, 0);
$c2 = imagecolorallocate($i, 255, 255, 255);
imagettftext($i, 32, 0, 100, 100, $c2, 'epminbld.ttf', 'Hello world &#x3042;');

imagepng($i, 'test.png');