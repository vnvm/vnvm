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

function object_to_string($v) {
	return json_encode($v);
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
	public $instructions;

	function __construct($version = "ymk") {
		$this->opcodes = array();

		$files = glob("../engine/ymk/rio_op*.nut");
		foreach (array(false, true) as $include_version) {
			foreach ($files as $file) {
				if (preg_match('@^rio_op_version_(\\w+)\\.nut$@Umsi', basename($file), $matches)) {
					if (!$include_version) continue;
					if ($matches[1] != $version) continue;
				} else {
					if ($include_version) continue;
				}
				echo "{$file}\n";
				$nut = file_get_contents($file);

				if (preg_match_all('@</ id=0x(.*), format="(.*)".*function (\w+)\\(@Umsi', $nut, $matches, PREG_SET_ORDER)) {
					//print_r($matches);
					foreach ($matches as $match) {
						$id = hexdec($match[1]);
						$format = $match[2];
						$name = $match[3];
						$this->opcodes[$id] = (object)array(
							'id'     => $id,
							'name'   => $name,
							'format' => $format,
						);
					}
				}
			}
		}
		
		//exit;
		
		//print_r($this->opcodes);
	}
	
	function loadData($data) {
		$this->f = fopen('php://memory', 'r+b');
		fwrite($this->f, $data);
		fseek($this->f, 0);
		$this->instructions = array();
	}
	
	static function extractFormat($f, $format, $level = 0) {
		$params = array();
		$current_count = 0;
		//printf("extractFormat('%s', %d)\n", $format, $level);
		if (feof($f)) {
			return array();
			//die("extractFormat :: feof\n");
		}
		for ($n = 0, $l = strlen($format); $n < $l; $n++) {
			$c = $format[$n];
			//printf("PARAM:%08X: '%s'\n", ftell($f), $c);
			switch ($c) {
				case '*':
					throw(new Exception("Unprocessed opcode"));
				break;
				case '.': fread($f, 1); break;
				case 3:
					$params[] = array(ord(fread($f, 1)), ord(fread($f, 1)), ord(fread($f, 1)));
				break;
				case '1': case 'O': case 'o': case 'k': $params[] = ord(fread($f, 1)); break;
				case '2': case 'f': case 'F': list(,$params[]) = unpack('v', fread($f, 2)); break;
				case 'l': case 'L': case '4': list(,$params[]) = unpack('V', fread($f, 4)); break;
				case 'C':
					list(,$current_count) = unpack('v', fread($f, 2));
					//printf("COUNT: %d\n", $current_count);
				break;
				case 'c':
					$current_count_2 = ord(fread($f, 1));
					switch ($current_count_2) {
						case 3:
							//$current_count = 7;
							$sub_params = array();
							//for ($m = 0; $m < 7; $m++) $sub_params[] = ord(fread($f, 1));
							//list(,$params[]) = unpack('v3', fread($f, 6));
							fread($f, 1);
							list(,$params[]) = unpack('v', fread($f, 2));
							fread($f, 1);
							list(,$params[]) = unpack('v', fread($f, 2));
							fread($f, 1);
							//list(,$params[]) = unpack('v', fread($f, 1));
							//$params[] = $sub_params;
						break;
						case 6:
							//$current_count = 5;
							//fread($f, 4);
							list(,$params[]) = unpack('V', fread($f, 4));
							fread($f, 1);
						break;
						default:
							//$current_count = 0;
						break;
					}
					//printf("COUNT2: %d, %d\n", $current_count_2, $current_count);
				break;
				case '[':
					$curl = 0;
					$start = $n + 1;
					for (; $n < $l; $n++) {
						if ($format[$n] == '[') {
							$curl++;
						} else if ($format[$n] == ']') {
							$curl--;
							if ($curl == 0) break;
						}
					}
					$end = $n;
					$sub_params = array();
					$sub_format = substr($format, $start, $end - $start);
					while ($current_count-- > 0) {
						$sub_params[] = static::extractFormat($f, $sub_format, $level + 1);
					}
					$params[] = $sub_params;
				break;
				case ']':
					assert(0);
				break;
				case 's': case 't':
					$s = '';
					while (!feof($f)) {
						$cc = fread($f, 1);
						if ($cc == "\0") break;
						$s .= $cc;
					}
					if ($c == 't') {
						//echo "$s\n";
					}
					$params[] = $s;
				break;
				default:
					throw(new Exception("Unknown format '{$c}'"));
				break;
			}
		}
		return $params;
	}
	
	function extractOpcodes() {
		$f = $this->f;
		$this->instructions = array();
		try {
			while (!feof($f)) {
				$position = ftell($f);
				$op = ord(fread($f, 1));
				//printf("OP: %02X\n", $op);
				$opi = &$this->opcodes[$op];
				$format = $opi->format;
				$name = $opi->name;
				if (!isset($format)) {
					throw(new Exception(sprintf("Unknown opcode 0x%02X\n", $op)));
				}
				//echo "$format\n";
				$params = static::extractFormat($f, $format);
				
				$this->instructions[] = (object)array(
					'opcode'   => $opi,
					'position' => $position,
					'params'   => $params
				);
			}
		} catch (Exception $e) {
			print_r(array_slice($this->instructions, -4));
			throw($e);
		}
	}
	
	function dumpInstructions() {
		if (!count($this->instructions)) $this->extractOpcodes();
		$lines = array();
		foreach ($this->instructions as $instruction) {
			if ($instruction->opcode->name == "RUN_SAVE") {
				print_r($instruction->params);
			}
			$lines[] = sprintf("%08d:%s %s", $instruction->position, $instruction->opcode->name, object_to_string($instruction->params));
		}
		return $lines;
	}
	
	function extractTexts() {
		$texts = array();
		if (!count($this->instructions)) $this->extractOpcodes();
		foreach ($this->instructions as $i) {
			//print_r($params);
			switch ($i->opcode->name) {
				case 'TEXT_ADD':
				case 'TEXT':
					//print_r($params);
					$texts[$i->params[0]] = (object)array(
						'op'    => $i->opcode->id,
						'id'    => $i->params[0],
						'body'  => $i->params[1],
						'title' => '',
					);
				break;
				case 'TEXT2':
					$texts[$i->params[0]] = (object)array(
						'op'    => $i->opcode->id,
						'id'    => $i->params[0],
						'body'  => $i->params[2],
						'title' => $i->params[1],
					);
				break;
				case 'OPTION_SELECT': // OPTION_SELECT
					$texts[$i->params[0]] = (object)array(
						'op'    => $i->opcode->id,
						'id'    => -1,
						//'body'  => $params[2],
						//'title' => $params[1]
					);
				break;
			}
		}
		return $texts;
	}
}

//print_r($argv);
@$project_path = __DIR__ . "/../game_data/" . basename($argv[2]);
$translation_folder_base = "{$project_path}/translation";
$lang = 'en';

if (!isset($argv[2])) $argv[1] = '-h';
if (!is_dir($project_path)) {
	fprintf(stderr, "Can't find folder '%s'\n", $project_path);
	$argv[1] = '-h';
}

@$rio = new RIO($argv[2]);
@$arc = new ARC();

switch (@$argv[1]) {
	case '-e': $lang = 'en'; break;
	case '-d': $lang = 'en'; break;
	case '-r': $lang = 'es'; break;
}

$translation_folder = "{$translation_folder_base}/{$lang}";
$acme_folder = "{$translation_folder}/SRC";
$ws_folder = "{$project_path}/WS";


@mkdir($translation_folder, 0777, true);
@mkdir($acme_folder, 0777, true);
@mkdir($ws_folder, 0777, true);

$arc->loadFile("{$project_path}/rio.arc");

switch (@$argv[1]) {
	case '-d':
		foreach ($arc->getFileNames() as $fileName) {
			$baseName = pathinfo($fileName, PATHINFO_FILENAME);
			echo "{$baseName}...";
			$data = rot2($arc->get($fileName));
			$rio->loadData($data);
			$f = fopen("{$ws_folder}/{$baseName}.ws", 'wb');
				foreach ($rio->dumpInstructions() as $line) {
					fwrite($f, "{$line}\n");
				}
			fclose($f);
			//file_put_contents("{$ws_folder}/{$baseName}.ws", $contents);
			echo "Ok\n";
		}
	break;
	case '-a':
		$effects = array();
		foreach ($arc->getFileNames() as $fileName) {
			$baseName = pathinfo($fileName, PATHINFO_FILENAME);
			$data = rot2($arc->get($fileName));
			$rio->loadData($data);
			$rio->extractOpcodes();
			foreach ($rio->instructions as $i) {
				if ($i->opcode->name == 'TRANSITION') {
					$effect = &$effects[$i->params[0]];
					if (!isset($effect)) $effect = 0;
					$effect++;
				}
			}
		}
		echo "EFFECT USAGE:\n";
		ksort($effects);
		print_r($effects);
	break;
	case '-e':
		foreach ($arc->getFileNames() as $fileName) {
		//foreach (array("SLG_SAVE.WSC") as $fileName) {
		//foreach (array("BATTLE.WSC") as $fileName) {
		//foreach (array("pw0015_1.WSC") as $fileName) {
			$baseName = pathinfo($fileName, PATHINFO_FILENAME);
			echo "{$baseName}...";
			$data = rot2($arc->get($fileName));
			echo "Ok\n";
			$rio->loadData($data);
			$rio->extractOpcodes();
			//$rio->dumpInstructions();
			//print_r($rio->instructions);
			//exit;
			try {
				$texts = $rio->extractTexts();
				if (count($texts)) {
					$f = fopen("{$translation_folder}/{$baseName}.nut", 'wb');
					foreach ($texts as $id => $rio_text) {
						fprintf(
							$f, "translation.add(%d, \"%s\", \"%s\");\n",
							$rio_text->id, addcslashes($rio_text->body, "\n"), addcslashes($rio_text->title, "\n")
						);
					}
					fclose($f);
					$f = fopen("{$acme_folder}/{$baseName}$1.txt", 'wb');
					$count2 = 0;
					$count = 0;
					foreach ($texts as $id => $rio_text) {
						if ($rio_text->title == '') $rio_text->title = '-';
						if ($count == 0) {
							$f = fopen("{$translation_folder}/SRC/{$baseName}\${$count2}.txt", 'wb');
							$count2++;
						}
						$count++;
						fprintf($f, "## POINTER %d\n%s\n%s\n\n", $rio_text->id, $rio_text->title, str_replace('\n', "\n", $rio_text->body));
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
	case '-r':
		$files_texts = array();
		foreach (glob("{$acme_folder}/*.txt") as $file) {
			list($baseName) = explode('$', pathinfo($file, PATHINFO_FILENAME));
			$pointers = explode("## POINTER ", file_get_contents($file));
			foreach (array_slice($pointers, 1) as $pointer) {
				@list($info, $text) = $pointer_e = explode("\n", $pointer, 2);
				$id = (int)$info;
				//$files_texts[$baseName][] = $text = str_replace("\r", "", rtrim($text));
				$files_texts[$baseName][$id] = $text = str_replace("\r", "", rtrim($text));
			}
		}
		
		foreach ($files_texts as $baseName => $texts) {
			$rio->loadData($data = rot2($arc->get("{$baseName}.WSC")));
			$rio_texts = $rio->extractTexts();
			$f = fopen("{$translation_folder}/{$baseName}.nut", 'wb');
			//print_r($texts);
			foreach ($rio_texts as $rio_text) {
				$title = $text = '';
				//printf("%s@%03d:%s\n", $baseName, $rio_text->id, $rio_text->body);
				
				@list($title, $text) = explode("\n", $texts[$rio_text->id], 2);
				
				if ($title == '-') $title = '';
				
				/*
				if (!empty($rio_text->title)) {
					//echo "{$rio_text->title}\n";
					@list($title, $text) = explode("\n", $texts[$rio_text->id], 2);
					//var_dump($texts[$rio_text->id]);
				} else {
					$text = $texts[$rio_text->id];
				}
				*/
				fprintf($f, "translation.add(%d, \"%s\", \"%s\");\n", $rio_text->id, addcslashes($text, "\n\r\t"), addcslashes($title, "\n\r\t"));
			}
			fclose($f);
			//exit;
		}
	break;
	default:
		printf("will_translate <option> <project>\n");
		printf("\n");
		printf("Options:\n");
		printf("  -e - extract in acme format\n");
		printf("  -d - dump script\n");
		printf("  -r - reinsert from acme format\n");
		printf("  -a - analyze script for statistics\n");
		printf("\n");
		printf("Projects:\n");
		printf("  ymk - Yume Miru Kusuri\n");
		printf("  pw  - Princess Waltz\n");
		exit;
	break;
}