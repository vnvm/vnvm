class RIO_OP_ANIM
{
	</ id=0x43, format="42s", description="" />
	static function TABLE_ANIM_LOAD(unk, unk, file)
	{
		this.scene.table.anim.load(file);
		this.scene.table.enabled = true;
		this.scene.background.enabled = false;
	}
	
	</ id=0x45, format="121", description="" />
	static function TABLE_ANIM_OBJECT_PUT(unk1, index, unk2)
	{
		this.scene.table.anim.active_set(index, 1);
	}

	</ id=0x4F, format="121", description="" />
	static function TABLE_ANIM_OBJECT_UNPUT(unk1, index, unk2)
	{
		this.scene.table.anim.active_set(index, 0);
	}

	</ id=0x50, format="s", description="" />
	static function TABLE_TABLE_LOAD(table_name)
	{
		this.scene.table.table.load(table_name);
		this.interface.enabled = false;
	}
	
	</ id=0x51, format="ff1", description="" />
	static function TABLE_PICK(flag_move_click, flag_mask_kind, unk1)
	{
		this.interface.enabled = false;
		this.scene.table.flag_move_click = flag_move_click;
		this.scene.table.flag_mask_kind = flag_mask_kind;
		//this.TODO();
		this.scene.table.mustUpdate = true;
		gameStep();
		this.scene.table.mustUpdate = false;
	}
}
