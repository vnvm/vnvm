<?php

function rot2byte($b) {
	return ($b >> 2) | (($b & 3) << 6);
}

function rot2($str) {
	for ($n = 0, $l = strlen($str); $n < $l; $n++) {
		$str[$n] = chr(rot2byte(ord($str[$n])));
	}
	return $str;
}
class ARC {
	public $f;
	public $files;

	function __constructor() {
	}
	
	function loadFile($file) {
		$this->f = $f = fopen($file, 'rb');
		if (!$f) return;
		$types = array();
		list($types_count) = array_values(unpack('V', fread($f, 4)));
		for ($n = 0; $n < $types_count; $n++) {
			$type = rtrim(fread($f, 4), "\0");
			list($files_count, $files_start) = array_values(unpack('V*', fread($f, 8)));
			$types[] = (object)array(
				'name' => $type,
				'count' => $files_count,
				'start' => $files_start,
			);
		}
		$this->files = array();
		foreach ($types as $type) {
			fseek($f, $type->start);
			for ($n = 0; $n < $type->count; $n++) {
				$name = rtrim(fread($f, 9), "\0");
				list($file_size, $file_start) = array_values(unpack('V*', fread($f, 8)));
				$this->files[$type->name][$name] = (object)array(
					'name' => $name,
					'size' => $file_size,
					'start' => $file_start,
				);
			}
		}
	}
	
	function get($name) {
		list($basename, $type) = explode('.', strtoupper($name));
		$file = &$this->files[$type][$basename];
		if (!isset($file)) {
			throw(new Exception("Can't find '{$name}'"));
			return null;
		}
		fseek($this->f, $file->start);
		return fread($this->f, $file->size);
	}
	
	function getFileNames() {
		$ret = array();
		foreach ($this->files as $type => $files) {
			foreach ($files as $file) {
				$ret[] = "{$file->name}.{$type}";
			}
		}
		return $ret;
	}
}

class RIO {
	public $f;
	public $opcodes;

	function __construct() {
		$this->opcodes = array();

		foreach (glob("../engine/ymk/rio_op*.nut") as $file) {
			$nut = file_get_contents($file);
			if (preg_match_all('@</ id=0x(.*), format="(.*)"@Umsi', $nut, $matches, PREG_SET_ORDER)) {
				//print_r($matches);
				foreach ($matches as $match) {
					$id = hexdec($match[1]);
					$format = $match[2];
					$this->opcodes[$id] = $format;
				}
			}
		}
		
		//print_r($this->opcodes);
	}
	
	function loadData($data) {
		$this->f = fopen('php://memory', 'r+b');
		fwrite($this->f, $data);
		fseek($this->f, 0);
	}
	
	static function extractFormat($f, $format) {
		$params = array();
		for ($n = 0, $l = strlen($format); $n < $l; $n++) {
			$c = $format[$n];
			switch ($c) {
				case '*':
					throw(new Exception("Unprocessed opcode"));
				break;
				case '.': fread($f, 1); break;
				case '1': case 'O': case 'o': case 'k': $params[] = ord(fread($f, 1)); break;
				case '2': case 'f': case 'F': list(,$params[]) = unpack('v', fread($f, 2)); break;
				case 'l': case 'L': case '4': list(,$params[]) = unpack('V', fread($f, 4)); break;
				case 's': case 't':
					$s = '';
					while (!feof($f)) {
						$cc = fread($f, 1);
						if ($cc == "\0") break;
						$s .= $cc;
					}
					if ($c == 't') {
						//echo "$s\n";
						$params[] = $s;
					}
				break;
				default:
					throw(new Exception("Unknown format '{$c}'"));
				break;
			}
		}
		return $params;
	}
	
	function extractTexts() {
		$f = $this->f;
		$ops = array();
		$texts = array();
		try {
			while (!feof($f)) {
				$op = ord(fread($f, 1));
				$ops[] = $op;
				//printf("OP: %02X\n", $op);
				$format = &$this->opcodes[$op];
				if (!isset($format)) {
					throw(new Exception(sprintf("Unknown opcode 0x%02X\n", $op)));
					
				}
				//echo "$format\n";
				$params = static::extractFormat($f, $format);
				//print_r($params);
				switch ($op) {
					case 0xB6:
					case 0x41: // TEXT:
						//print_r($params);
						$texts[$params[0]] = array($params[1], '');
					break;
					case 0x42: // TEXT2:
						$texts[$params[0]] = array($params[2], $params[1]);
					break;
				}
				//echo "$op\n";
			}
		} catch (Exception $e) {
			print_r(array_slice($ops, -4));
			throw($e);
		}
		return $texts;
	}
}

@mkdir($translation_folder = __DIR__ . "/../game_data/pw/translation/es", 0777, true);
@mkdir($acme_folder = "{$translation_folder}/SRC", 0777, true);

//print_r($argv);

switch (@$argv[1]) {
	case 'e':
		$rio = new RIO();
		$arc = new ARC();
		$arc->loadFile(__DIR__ . "/game_data/pw/rio.arc");
		foreach ($arc->getFileNames() as $fileName) {
			$baseName = pathinfo($fileName, PATHINFO_FILENAME);
			echo "{$baseName}...";
			$data = rot2($arc->get($fileName));
			echo "Ok\n";
			$rio->loadData($data);
			try {
				$texts = $rio->extractTexts();
				if (count($texts)) {
					$f = fopen("{$translation_folder}/{$baseName}.nut", 'wb');
					foreach ($texts as $id => $text) {
						fprintf($f, "translation.add(%d, \"%s\", \"%s\");\n", $id, addcslashes($text[0], "\n"), addcslashes($text[1], "\n"));
					}
					fclose($f);
					$f = fopen("{$acme_folder}/{$baseName}$1.txt", 'wb');
					$count2 = 0;
					$count = 0;
					foreach ($texts as $id => $text) {
						if ($text[1] == '') $text[1] = '-';
						if ($count == 0) {
							$f = fopen("{$translation_folder}/SRC/{$baseName}\${$count2}.txt", 'wb');
							$count2++;
						}
						$count++;
						fprintf($f, "## POINTER %d\n%s\n%s\n\n", $id, $text[1], str_replace('\n', "\n", $text[0]));
						if ($count >= 200) {
							$count = 0;
						}
					}
					fclose($f);
				}
				//translation.add(0, "¿Ya has terminado la sesión de compras?", "Kouhei");
				//translation.add(1, "No, todavía no.", "Aeka");
				//print_r($texts);

			} catch (Exception $e) {
				echo "$e\n";
			}
		}
	break;
	case 'r':
		$files_texts = array();
		foreach (glob("{$acme_folder}/*.txt") as $file) {
			list($baseName) = explode('$', pathinfo($file, PATHINFO_FILENAME));
			$pointers = explode("## POINTER ", file_get_contents($file));
			foreach (array_slice($pointers, 1) as $pointer) {
				@list($info, $title, $text) = $pointer_e = explode("\n", $pointer, 3);
				if (count($pointer_e) < 3) {
					echo "{$baseName}\n";
					print_r($pointer_e);
				}
				$id = (int)$info;
				$title = trim($title);
				if ($title == '-') $title = '';
				//echo "'$title'\n";
				$files_texts[$baseName][$id] = array(rtrim($text), ($title));
				//echo "$id: $baseName\n";
			}
		}
		foreach ($files_texts as $baseName => $texts) {
			$f = fopen("{$translation_folder}/{$baseName}.nut", 'wb');
			foreach ($texts as $id => $text) {
				fprintf($f, "translation.add(%d, \"%s\", \"%s\");\n", $id, addcslashes($text[0], "\n"), addcslashes($text[1], "\n"));
			}
			fclose($f);
		}
	break;
	default:
		printf("will_translate <option>\n");
		printf("\n");
		printf("Options:\n");
		printf("  e - extract in acme format\n");
		printf("  r - reinsert from acme format\n");
		exit;
	break;
}