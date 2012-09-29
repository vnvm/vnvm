import massive.munit.TestSuite;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(engines.ethornell.CompressedBGTest);
		add(engines.tlove.PAKTest);
		add(engines.tlove.mrs.LZTest);
		add(extra.ByteArrayTest);
		add(extra.MacroTest);
		add(common.MathExTest);
	}
}
