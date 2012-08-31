import massive.munit.TestSuite;

import engines.tlove.LZTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(engines.tlove.PAKTest);
		add(engines.tlove.LZTest);
		add(extra.ByteArrayTest);
	}
}
