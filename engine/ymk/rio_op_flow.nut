class RIO_OP_FLOW
{
	function binary_operation(op, a, b, flags = null) {
		switch (op) {
			// JUMP_IF
			case ">="  : return a >= b;
			case "<="  : return a <= b;
			case "=="  : return a == b;
			case "!="  : return a != b;
			case ">"   : return a >  b;
			case "<"   : return a <  b;
			
			// SET
			case "+"   : return a + b;
			case "-"   : return a - b;
			case "%"   : return a % b;
			case "="   : return b;
			case "ref" : return flags[b % State.MAX_FLAGS];
			case "rand": return rand() % b;
			
		}
		throw("Unknown binary_operation::op :: '" + op + "'");
	}

	static ops_set = [ "?", "=", "+", "-", "ref", "%", "rand" ];
	static ops_jump_if = [ "", ">=", "<=", "==", "!=", ">", "<" ];
	
	/*
		MAINMENU@000002D4: Executing OP(0x0C) : TIMER_GET : [867,0]...249
		MAINMENU@000002D8: Executing OP(0x01) : JUMP_IF : [4,867,0,50]...true
	*/

	</ id=0x01, format="Of2l.", description="Jumps if the condition is false" />
	static function JUMP_IF(operation, left_flag, right_value_or_flag, relative_position)
	{
		local is_right_flag = (operation >> 4);
		local operator = RIO_OP_FLOW.ops_jump_if[operation & 0x0F];
		local left = this.state.flags[left_flag % State.MAX_FLAGS];
		local right = right_value_or_flag;
		if (is_right_flag) right = this.state.flags[right_value_or_flag % State.MAX_FLAGS];
		
		local result = RIO_OP_FLOW.binary_operation(operator, left, right);
		//printf("JUMP_IF %d(%d) %s %d(%d)...\n", left_flag, left, operator, right_value_or_flag, right);
		
		if (!result) {
			this.jump_relative(relative_position);
			//printf("result: %d\n", result ? 1 : 0);
			//this.TODO();
		}
		
		return result;
	}

	// 03 - SET (=+-) op(1) variable(2) kind(1) variable/value(2)          //
	// // [OP.03]: [1, 993, 0, 1000, 0, ] ('12121', 'SET')
	</ id=0x03, format="ofkF.", description="Sets the value of a flag" />
	static function SET(operation, left_flag, is_right_flag, right_value_or_flag)
	{
		local left  = this.state.flags[left_flag % State.MAX_FLAGS];
		local right = right_value_or_flag;
		if (is_right_flag) right = this.state.flags[right_value_or_flag % State.MAX_FLAGS];
	
		if (operation == 0) {
			for (local n = 0; n < 1000; n++) this.state.flags[n] = 0;
			//printf("**SET_ALL_TEMPORAL_FLAGS_TO_ZERO()\n");
		} else {
			this.state.flags[left_flag % State.MAX_FLAGS] = RIO_OP_FLOW.binary_operation(RIO_OP_FLOW.ops_set[operation], left, right, this.state.flags);
			//printf("**SET %d=%d\n", left_flag, this.state.flags[left_flag % State.MAX_FLAGS]);
		}
		//this.TODO();
	}
	
	</ id=0x04, format="", description="Ends the execution" />
	static function EXIT()
	{
		this.exit();
	}

	</ id=0x06, format="L1", description="Jumps always" />
	static function JUMP(absolute_position, param)
	{
		this.jump_absolute(absolute_position);
	}

	</ id=0x07, format="s", description="Switches to an script" />
	static function SCRIPT(name)
	{
		this.load(name, 0);
	}

	</ id=0x09, format="s", description="Calls a script" />
	static function SCRIPT_CALL(name)
	{
		this.load(name, 1);
	}

	</ id=0x0A, format="1", description="Returns from a script" />
	static function SCRIPT_RET(param)
	{
		this.script_return();
	}

	</ id=0xFF, format="", description="" />
	static function EOF()
	{
		this.TODO();
	}
}
