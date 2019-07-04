//Zelda 64 Dawn & Dusk - Expansion Disk
//By LuigiBlood

//Uses ARM9 bass

//Ocarina of Time Expansion Hook
print "- Assemble Expansion Disk Code...\n"

seekDisk(0)
base DDHOOK_RAM

ddhook_start:
	db "ZELDA_DD"
ddhook_list_start:
	dw (ddhook_setup | {KSEG1})	//00: 64DD Hook
	dw 0x00000000				//04: 64DD Unhook
	dw 0x00000000				//08: Room Loading Hook
	dw 0x00000000				//0C: Post-Scene Loading
	dw 0x00000000				//10: "game_play" game state entrypoint
	dw 0x00000000				//14: Collision related
	dw 0x00000000				//18: ???
	dw 0x00000000				//1C: 
	dw 0x00000000				//20: 
	dw 0x00000000				//24: 
	dw 0x00000000				//28: map_i_static Replacement
	dw 0x00000000				//2C: 
	dw 0x00000000				//30: 
	dw 0x00000000				//34:
	dw 0x00000000				//38:
	dw 0x00000000				//3C:
	dw 0x00000000				//40: 
	dw 0x00000000				//44: map_48x85_static Replacement
	dw (ddhook_sceneload)		//48: Scene Entry Replacement
	dw 0x00000000				//4C:
	dw 0x00000000				//50:
	dw 0 //(ddhook_removecutscene)	//54: Entrance Cutscene Replacement?
	dw (ddhook_text_table)		//58: Message Table Replacement Setup
	dw 0x00000000				//5C:
	dw 0x00000000				//60: staff_message_data_static Load
	dw 0x00000000				//64: jpn_message_data_static Load
	dw (ddhook_textUSload)		//68: nes_message_data_static Load
	dw 0x00000000				//6C: ???
	dw (ddhook_romtoram)		//70: DMA ROM to RAM Hook
	dw 0x00000000				//74: ??? (Every Frame?)
	dw 0x00000000				//78: Set Cutscene Pointer (Intro Cutscenes)
ddhook_list_end:

//64DD Hook Initialization Code
ddhook_setup: {
	//Arguments:
	//A0=p->Address Table
	//800FEE70 (NTSC 1.0) - Address Table
	//800FF030 (NTSC 1.1)
	//800FF4B0 (NTSC 1.2)
	//	+0x0 = n64dd_Func_801C7C1C (USEFUL! Disk read function)
	//	+0x50 = osSendMesg
	//	+0x88 = Save Context
	//8011A5D0 (NTSC 1.0) - Save Context
	//	+0x1409 = Language (8011B9D9)
	
	addiu sp,sp,-0x10
	sw ra,0x10(sp)
	
	//Save Zelda Disk Address Table Address for later usage
	li a3,(DDHOOK_ADDRTABLE)
	sw a0,0(a3)

	//Version Detection
	//1.0 test
	li a1,0x800FEE70
	beq a0,a1,+
	nop

	//1.1 test
	li a1,0x800FF030
	beq a0,a1,++
	nop

	//else it must be 1.2
	addiu a1,0,2
	sw a1,4(a3)		//1.2
	n64dd_DiskLoad(DDHOOK_VERSIONTABLE, ezlj_vertable2, ezlj_vertable2_end - ezlj_vertable2)
	n64dd_DiskLoad(DDHOOK_VFILETABLE, EZLJ_FILE_TABLE2, EZLJ_FILE_TABLE2.size)
	b _ddhook_setup_entrancetable
	nop

 +;	sw 0,4(a3)		//1.0
	n64dd_DiskLoad(DDHOOK_VERSIONTABLE, ezlj_vertable0, ezlj_vertable0_end - ezlj_vertable0)
	n64dd_DiskLoad(DDHOOK_VFILETABLE, EZLJ_FILE_TABLE0, EZLJ_FILE_TABLE0.size)
	b _ddhook_setup_entrancetable
	nop

 +;	addiu a1,0,1	//1.1
	sw a1,4(a3)
	n64dd_DiskLoad(DDHOOK_VERSIONTABLE, ezlj_vertable1, ezlj_vertable1_end - ezlj_vertable1)
	n64dd_DiskLoad(DDHOOK_VFILETABLE, EZLJ_FILE_TABLE1, EZLJ_FILE_TABLE1.size)
	b _ddhook_setup_entrancetable
	nop

_ddhook_incompatibleversion:
	lui a0,VI_BASE
	lw a0,VI_ORIGIN(a0)
	li a1,{KSEG1}
	addu a0,a0,a1
	li a1,EZLJ_ERROR_VER
	li a2,EZLJ_ERROR_VER.size
	n64dd_LoadAddress(v0, {CZLJ_DiskLoad})
	jalr v0
	nop

_ddhook_incompatible_loop:
	j _ddhook_incompatible_loop
	nop

_ddhook_setup_entrancetable:
	//Load Entrance Table
	//NTSC 1.0 - 800F9C90 (-51E0)
	//NTSC 1.1 - 800F9E50 (-51E0)
	//NTSC 1.2 - 800FA2E0 (-51D0)

	//TODO
	b _ddhook_setup_patch
	nop

_ddhook_setup_entrance_cutscene:
	//Load Entrance Cutscene Table
	//NTSC 1.0 - 800EFD04 (-F16C)
	//NTSC 1.1 - 800EFEC4 (-F16C)
	//NTSC 1.2 - 800F0344 (-F16C)

_ddhook_setup_minimap_table:
	//Load Minimap Table
	//NTSC 1.0 - 800F6914 (-855C)
	//NTSC 1.1 - 800F6AD4 (-855C)
	//NTSC 1.2 - 800F6F54 (-855C)

_ddhook_setup_tunic_colors:
	//Setup Tunic Colors
	//NTSC 1.0 - 800F7AD8 (-7398)
	//NTSC 1.1 - 800F7C98 (-7398)
	//NTSC 1.2 - 800F8128 (-7388)

_ddhook_setup_object_list:
	//Patch Object List
	//NTSC 1.0 - 800F8FF0 (-5E80)
	//NTSC 1.1 - 800F91B0 (-5E80)
	//NTSC 1.2 - 800F9640 (-5E70)

_ddhook_setup_ovl_kaleido_scope:
	//Handle ovl_kaleido_scope

_ddhook_setup_patch:
	//assume 1.0 for now, load patch - A04104B4
	n64dd_ForceRomEnable()
	n64dd_RomLoad(DDHOOK_OVL_PLAYER_ACTOR,0xBCDB70,0x26560)
	n64dd_RomLoad(DDHOOK_OVL_KALEIDO_SCOPE,0xBB11E0,0x1C990)
	n64dd_RomLoad(DDHOOK_OVL_EFFECT_SS_STICK,0xEAD0F0,0x3A0)
	n64dd_RomLoad(DDHOOK_OVL_ITEM_SHIELD,0xDB1F40,0xA10)

	n64dd_RomLoad(DDHOOK_ICON_ITEM_STATIC,0x7BD000,0x888A0)
	n64dd_RomLoad(DDHOOK_MAP_NAME_STATIC,0x8BE000,0x21800)
	n64dd_RomLoad(DDHOOK_ITEM_NAME_STATIC,0x880000 + 0x1EC00,0x1EC00)

	n64dd_RomLoad(DDHOOK_ICON_ITEM_24_STATIC,0x846000,0xB400)
	n64dd_RamFill(DDHOOK_ICON_ITEM_24_STATIC+0x6300,0,0x900)	//Patch out that boss icon

	n64dd_DiskLoad(DDHOOK_GAMEPLAY_DANGEON_KEEP, EZLJ_GAMEPLAY_DANGEON_KEEP, EZLJ_GAMEPLAY_DANGEON_KEEP.size)
	n64dd_DiskLoad(DDHOOK_OBJECT_LINK_CHILD, EZLJ_OBJECT_LINK_CHILD, EZLJ_OBJECT_LINK_CHILD.size)

	n64dd_DiskLoad(DDHOOK_ICON_ITEM_FIELD_STATIC, EZLJ_ICON_ITEM_FIELD_STATIC, EZLJ_ICON_ITEM_FIELD_STATIC.size)
	n64dd_DiskLoad(DDHOOK_ICON_ITEM_NES_STATIC, EZLJ_ICON_ITEM_NES_STATIC, EZLJ_ICON_ITEM_NES_STATIC.size)

	n64dd_DiskLoad(DDHOOK_PATCH, EZLJ_PATCH0, EZLJ_PATCH0_END - EZLJ_PATCH0)
	n64dd_ForceRomDisable()

	li at,DDHOOK_PATCH
    -; lw a0,0(at)		//Get Dest
	beq a0,0,_ddhook_setup_savecontext	//If 0 then done
	nop
	lw a2,4(at)			//Get Size
	addiu a1,at,8		//Get Source
	addu at,a1,a2		//Prepare at for next patch
	n64dd_CallRamCopy()	//Patch
	b -					//Loop
	nop

_ddhook_setup_savecontext:
	//Save Context Change
	n64dd_LoadAddress(a1, {CZLJ_SaveContext})
	ori a2,0,1
	sb a2,0x1409(a1)	//Set the game into English (1)
	sw 0,0x135C(a1)		//Set Game Mode to Normal Gameplay
	//(Map Select does not reset it when disk is present, seems to be a bug)
	
	//Check if save is new
	//TODO

	li a2,0xDB
	//sw a2,0(a1)

	//No Cutscene
	//sw 0,8(a1)

	addiu a0,a1,0x2E
	li a1,EZLJ_SAVE_DATA
	addiu a2,0,EZLJ_SAVE_DATA.size

	//n64dd_LoadAddress(v0, {CZLJ_DiskLoad})
	//jalr v0
	nop

_ddhook_setup_music:
	n64dd_DiskLoad(DDHOOK_AUDIOBANK_TABLE, EZLJ_AUDIOBANK_TABLE, EZLJ_AUDIOBANK_TABLE.size)
	n64dd_DiskLoad(DDHOOK_AUDIOINST_TABLE, EZLJ_AUDIOINST_TABLE, EZLJ_AUDIOINST_TABLE.size)
	n64dd_DiskLoad(DDHOOK_AUDIOSEQ_TABLE, EZLJ_AUDIOSEQ_TABLE, EZLJ_AUDIOSEQ_TABLE.size)

	//Check version and load the appropriate audiobank
	li a0,DDHOOK_VERSION
	lw a0,0(a0)
	sync

	ori at,0,1
	beq a0,at,_ddhook_setup_music_bank1
	nop
	ori at,0,2
	beq a0,at,_ddhook_setup_music_bank2
	nop

_ddhook_setup_music_bank0:
_ddhook_setup_music_bank1:
	n64dd_DiskLoad(DDHOOK_AUDIOBANK, EZLJ_AUDIOBANK0, EZLJ_AUDIOBANK0.size)
	b _ddhook_setup_music_seq
	nop

_ddhook_setup_music_bank2:
	n64dd_DiskLoad(DDHOOK_AUDIOBANK, EZLJ_AUDIOBANK2, EZLJ_AUDIOBANK2.size)

_ddhook_setup_music_seq:
	n64dd_DiskLoad(DDHOOK_AUDIOSEQ, EZLJ_AUDIOSEQ, EZLJ_AUDIOSEQ.size)

	//Update Pointers Audiobank Table
	li a0,DDHOOK_AUDIOBANK
	li a1,DDHOOK_AUDIOBANK_TABLE
	sw a0,4(a1)		// Update Main Pointer
	lhu a2,0(a1)	// Get amount of AudioBank entries

 -;	addiu a1,a1,0x10

	lw a3,0(a1)
	addu a3,a3,a0	// Make Absolute Pointers for all entries
	sw a3,0(a1)

	addiu a2,a2,-1
	bne a2,0,-
	nop

	//Update Pointers Audioseq Table
	li a0,DDHOOK_AUDIOSEQ
	li a1,DDHOOK_AUDIOSEQ_TABLE
	sw a0,4(a1)		// Update Main Pointer
	lhu a2,0(a1)	// Get amount of AudioSeq entries

 -;	addiu a1,a1,0x10

	lw a3,0(a1)
	addu a3,a3,a0	// Make Absolute Pointers for all entries
	sw a3,0(a1)

	addiu a2,a2,-1
	bne a2,0,-
	nop

	// Change Audio Table Pointers
	// VER - ADDRESS  - AUDIOSEQ, AUDIOBANK, AUDIOTABLE, AUDIOINST
	// 1.0 - 80127E60 - 80113B70 80113740 80114260 801139B0
	// 1.1 - 80128020 - 80113D30 80113900 80114420 80113B70
	// 1.2 - 80128730 - 80114220 80113DF0 80114910 80114060

	li a0,DDHOOK_VERSIONTABLE
	lw a0,0(a0)
	sync

	li a1,DDHOOK_AUDIOBANK_TABLE
	li a2,DDHOOK_AUDIOSEQ_TABLE
	li a3,DDHOOK_AUDIOINST_TABLE
	sw a2,0(a0)
	sw a1,4(a0)
	// 8(a0) is AUDIOTABLE_TABLE
	sw a3,0xC(a0)
	

	// Patch osEPiStartDma
	// VER - ADDRESS
	// 1.0 - 800B8250
	// 1.1 - 800B8270
	// 1.2 - 800B88D0

	li a0,DDHOOK_VERSIONTABLE
	lw a0,4(a0)
	sync

	//Copy osEPiStartDma call for regular DMA use
	li a1,_ddhook_loadmusic_startdma
	lw a2,0(a0)
	sync
	sw a2,0(a1)
	lw a2,4(a0)
	sync
	sw a2,4(a1)
	lw a2,8(a0)
	sync
	sw a2,8(a1)

	//Inject custom function call for Audio use
	li a1,_ddhook_setup_musicdma
	lw a2,0(a1)
	sync
	sw a2,0(a0)
	lw a2,4(a1)
	sync
	sw a2,4(a0)
	lw a2,8(a1)
	sync
	sw a2,8(a0)

	b _ddhook_setup_finish
	nop

_ddhook_setup_musicdma:
	li t9,ddhook_loadmusic
	jalr ra,t9
	nop


_ddhook_setup_finish:
	//osWritebackDCache all of the expanded memory
	lui a0, 0x8040
	lui a1, 0x0040
	n64dd_LoadAddress(v0, {CZLJ_osWritebackDCache})
	jalr v0
	nop
	
	//Load text data into RAM (avoid music stop)
	n64dd_DiskLoad(DDHOOK_TEXTDATA, EZLJ_NES_MESSAGE_DATA_STATIC, EZLJ_NES_MESSAGE_DATA_STATIC.size)
	
	lw ra,0x10(sp)
	addiu sp,sp,0x10
	jr ra
	nop
}

//Handle custom music loading (Hack)
ddhook_loadmusic: {	//804102E0
	addiu sp,sp,-0x20
	sw ra,0x18(sp)
	sw a1,0x14(sp)

	lui a3,0x8000
	lw v0,0xC(a1)
	sltu at,v0,a3	// 0 == >= 80000000 / 1 == < 80000000
	bne at,0,_ddhook_loadmusic_startdma
	nop

	lw a0,0x8(a1)	//RAM Dest
	lw a2,0x10(a1)	//Size
	ori a1,v0,0		//RAM Source

	//Copy Text Data from RAM to where it wants
	//Avoid hang from loading from disk directly and stop the music
    n64dd_CallRamCopy()

	lw v0,0x14(sp)	// Notify the game it is loaded
	ori a0,v0,0
	lw a0,4(a0)
	ori a1,v0,0
	ori a2,0,0
	n64dd_LoadAddress(a3,{CZLJ_osSendMesg})
	jalr a3
	nop

	lw ra,0x18(sp)
	addiu sp,sp,0x20
	jr ra
	nop

_ddhook_loadmusic_startdma:
	//Original EPiStartDma code to load from ROM instead (copied from game in runtime)
	lui t9,0x8010
	lw t9,0x17E0(t9)
	jalr t9
	nop

	lw ra,0x18(sp)
	addiu sp,sp,0x20
	jr ra
	nop
}

//nes_message_data_static Load Hook
ddhook_textUSload: {
	//Arguments:
	//A0=p->Message Context
	//	+0 = Offset
	//	+4 = Size
	//	+DC88 = Destination
	
	addiu sp,sp,-0x10
	sw ra,8(sp)
	sw a0,4(sp)
	
	//osWritebackDCache all of the expanded memory
	lui a0, 0x8040
	lui a1, 0x0040
	n64dd_LoadAddress(at, {CZLJ_osWritebackDCache})
	jalr at
	nop
	
	lw a0,4(sp)
	
	lw a2,4(a0) 		//A2 = Size
	lw a1,0(a0)		//A1 = Offset
	li a3,DDHOOK_TEXTDATA	//A3 = DDHOOK_TEXTDATA
	addu a1,a1,a3		//A1 = A3 + Offset
	ori a3,0,0xDC88
	addu a0,a0,a3		//A0 = RAM Dest
	
	//Copy Text Data from RAM to where it wants
	//Avoid hang from loading from disk directly and stop the music
	n64dd_CallRamCopy()
	
	lw ra,8(sp)
	addiu sp,sp,0x10
	jr ra
	nop
}

//Message Table Replacement Setup Hook
ddhook_text_table: {
	//Arguments:
	//A0=p->p->jpn_message_data_static table
	//A1=p->p->nes_message_data_static table
	//A2=p->p->staff_message_data_static table
	//You can change the pointers.
	
	addiu sp,sp,-0x20
	sw ra,0x10(sp)
	sw a0,0xC(sp)
	sw a1,0x8(sp)
	sw a2,0x4(sp)
	
	//osWritebackDCache all of the expanded memory
	lui a0, 0x8040
	lui a1, 0x0040
	n64dd_LoadAddress(at, {CZLJ_osWritebackDCache})
	jalr at
	nop
	
	lw a0,0xC(sp)
	lw a1,0x8(sp)
	lw a2,0x4(sp)
	
	li a0,DDHOOK_TEXTTABLE
	sw a0,0(a1)		//Change nes_message_data_static pointer
	
	//osWritebackDCache all of the expanded memory
	lui a0, 0x8040
	lui a1, 0x0040
	n64dd_LoadAddress(v0, {CZLJ_osWritebackDCache})
	jalr v0
	nop
	
	//Load Message Table to RAM
	n64dd_DiskLoad(DDHOOK_TEXTTABLE, EZLJ_NES_MESSAGE_TABLE, EZLJ_NES_MESSAGE_TABLE.size)
	
	lw ra,0x10(sp)
	addiu sp,sp,0x20
	jr ra
	nop	
}

//Scene Entry Hook
ddhook_sceneload: {
	//Arguments:
	//A0=Scene ID
	//A1=p->Scene Table
	//
	//Return:
	//V0=p->Scene Entry
	
	addiu sp,sp,-0x20
	sw ra,0x10(sp)

	//Check if Scene ID is part of the List
	//Uses the Disk byte in the Scene Entry as Scene ID
	addiu at,0,ddhook_sceneentry_count
	addiu a2,0,0
	li v0, ddhook_sceneentry_data
	-; lbu v1,0x12(v0)
	beq a0,v1,_ddhook_sceneload_custom
	nop
	addiu v0,v0,0x1C
	addiu a2,a2,1
	bne at,a2,-
	nop

_ddhook_sceneload_original:
	//Calculate Scene Entry Address from original Scene List
	addiu a3,0,0x14
	multu a0,a3
	mflo a2		//(0x14 * Scene ID)
	addu v0,a2,a1

	//Disable Room Loading Hook
    li a0,ddhook_list_start
	sw 0,8(a0)
	sw 0,0xC(a0)

	b _ddhook_sceneload_return
	nop

_ddhook_sceneload_custom:
	sw v0,0x14(sp)

	//Setup Room Load Hook
	li a0,ddhook_list_start
	li a1,ddhook_roomload
	sw a1,8(a0)
	li a1,ddhook_postscene
	sw a1,0xC(a0)

	//Load Title Card
	lw a0,8(v0)
	lw a1,0x14(v0)
	lw a2,0x18(v0)

	n64dd_LoadAddress(a3, {CZLJ_DiskLoad})
	jalr a3			//read from disk
	nop

	lw v0,0x14(sp)

_ddhook_sceneload_return:
	lw ra,0x10(sp)
    addiu sp,sp,0x20
	jr ra
	nop
}

//Post-Scene Loading Hook
ddhook_postscene: {
	//Arguments:
	//A0=p->Global Context

	//Load Rooms into buffer
	addiu sp,sp,-0x20
	sw ra,0x20(sp)
	sw a0,0x1C(sp)
	
	//Find Scene Room Command (0x04)
	lw a0,0x00B0(a0)
	addiu a1,a0,0
	addiu a3,0,4

	-; lbu a2,0(a1)
	addiu a1,a1,8
	bne a2,a3,-
	nop

	subiu a1,a1,8
	lbu a2,1(a1)	//A2 = Get number of rooms
	lw a3,4(a1)		//Get Room Segment Address
	li v0,0x00FFFFFF
	and a3,a3,v0	//Isolate relative Address
	addu a1,a0,a3	//A1 = Get Room List Address

	li a0,DDHOOK_SCENE_ROOM_DATA
	addiu a3,0,0
	sw a3,0x0C(sp)	//Current Room ID to load
	sw a2,0x18(sp)	//Room Count
	sw a1,0x14(sp)	//Room List Address
	sw a0,0x10(sp)	//Current Room Buffer Address
	
	-; lw a2,4(a1)		//get End VROM
	lw a1,0(a1)		//get Start VROM

	subu a2,a2,a1	//get Size

	n64dd_LoadAddress(v0, {CZLJ_DiskLoad})
	jalr v0
	nop

	lw a1,0x14(sp)	//Room List Address
	lw v0,0x0C(sp)	//Current Room ID
	sll v0,v0,3		//Multiply by 8
	addu a1,a1,v0
	lw a2,4(a1)		//get End VROM
	lw a1,0(a1)		//get Start VROM
	subu a2,a2,a1	//get Size
	lw a0,0x10(sp)
	li a3,DDHOOK_SCENE_ROOM_TABLE
	addu a3,a3,v0
	sw a0,0(a3)		//Save Start RAM Address to Table
	addu a0,a0,a2
	sw a0,4(a3)		//Save End RAM Address to Table
	sw a0,0x10(sp)

	lw a3,0x0C(sp)	//Current Room ID
	lw a2,0x18(sp)	//Room Count
	addiu a3,a3,1	//ID++
	sw a3,0x0C(sp)	//Current Room ID
	lw a1,0x14(sp)	//Room List Address
	sll v0,a3,3		//Multiply by 8
	addu a1,a1,v0
	bne a3,a2,-		//if not equal then continue to load rooms
	nop

	lw ra,0x20(sp)
	addiu sp,sp,0x20
	jr ra
	nop
}

//Room Loading Hook
ddhook_roomload: {
	//Arguments:
	//A0=p->Global Context
	//A1=p->Room Context
	//A2=Room ID
	
	addiu sp,sp,-0x20
	sw ra,0x10(sp)
	sw a1,0x14(sp)
	sw a2,0x18(sp)
	
	//osWritebackDCache all of the expanded memory
	lui a0, 0x8040
	lui a1, 0x0040
	n64dd_LoadAddress(at, {CZLJ_osWritebackDCache})
	jalr at
	nop
	
	lw a1,0x14(sp)
	lw a2,0x18(sp)

	lw a0,0x34(a1)		//A0=RAM Address Dest
	li a1,DDHOOK_SCENE_ROOM_TABLE
	sll a2,a2,3
	addu a1,a1,a2
	lw a2,4(a1)
	lw a1,0(a1)			//A1=Source
	subu a2,a2,a1		//A2=Size
	
	n64dd_CallRamCopy()
	
	lw a0,0x14(sp)
	addiu a0,a0,0x50
	lw a0,0(a0)		//OsMesgQueue pointer (osSendMesg A0)
	li a1,0			//OSMesg (osSendMesg A1)
	li a2,0			//DO NOT BLOCK until response
	
	n64dd_LoadAddress(a3, {CZLJ_osSendMesg})
	jalr a3			//osSendMesg, to let the engine know that the data is loaded and continue the game
	nop
	
	lw ra,0x10(sp)
	addiu sp,sp,0x20
	jr ra
	nop
}

//Remove Intro Cutscene (avoid softlock)
ddhook_removecutscene: {
	//Arguments:
	//A0=p->Global Context
	//
	//Return:
	//V0=Is Loaded?
	
	addiu v0,0,1
	jr ra
	nop
}

//ROM Loading Hook
ddhook_romtoram: {
	//Arguments:
	//A0=osMesgQueue + 0x18 (?)
	//A1=RAM Address
	//A2=VROM Address
	//A3=Size
	//Return:
	//V0=IsLoaded
	addiu sp,sp,-0x40
	sw ra,0x10(sp)
	sw a0,0x14(sp)
	sw a1,0x18(sp)
	sw a2,0x1C(sp)
	sw a3,0x20(sp)

	//VROM Address Format:
	//00000000+ = Load from ROM / Patch
	//40000000+ = Force Load from ROM (Does not decompress yet)
	//80000000+ = Load from RAM
	//C0000000+ = Load from Disk

	//Check Format
	lui v0,0xF000
	and v1,a2,v0

	//--VROM Format
	beq v1,0,ddhook_romtoram_vrom
	nop

	//--Force ROM Format
	lui v0,0x4000
	beq v1,v0,ddhook_romtoram_force_rom
	nop

	//--RAM Format
	lui v0,0x8000
	beq v1,v0,ddhook_romtoram_ram
	nop

	//--Disk Format
	lui v0,0xC000
	beq v1,v0,ddhook_romtoram_disk
	nop

ddhook_romtoram_vrom:
	//Check for Force ROM flag
	li a0,DDHOOK_FORCEROM
	lw a0,0(a0)
	bnez a0,ddhook_romtoram_vrom_romload
	nop

	//Check for File Replacements
	li a0,DDHOOK_VFILETABLE
	ori a1,0,EZLJ_FILE_COUNT
	ori a3,0,0

	//a2 < end
	-; lw v0,4(a0)
	bge a2,v0,+
	nop

	//a2 > Start
	lw v0,0(a0)
	blt a2,v0,+
	nop
	b ddhook_romtoram_vrom_replace
	nop

	//increment
	+; addiu a3,a3,1
	addiu a0,a0,0x10
	blt a3,a1,-
	nop

ddhook_romtoram_vrom_romload:
	//Load from ROM
	ori v0,0,0
	b ddhook_romtoram_return
	nop

ddhook_romtoram_force_rom:
	//Load from ROM (Force)
	li v0,0x0FFFFFFF
	and a2,a2,v0
	sw a2,0x78(sp)
	ori v0,0,0
	b ddhook_romtoram_return
	nop

ddhook_romtoram_vrom_replace:
	subu a1,a2,v0
	lw a2,8(a0)
	addu a1,a1,a2	//A1 = Source
	lw a2,0x20(sp)	//A2 = Size
	lw a0,0x18(sp)	//A0 = Dest

	//Check if source is RAM
	lui v0,0xF000
	and a3,a1,v0
	bnez a3,ddhook_romtoram_vrom_replace_ram
	nop

ddhook_romtoram_vrom_replace_disk:
	//Load from Disk
	n64dd_LoadAddress(v0, {CZLJ_DiskLoad})
	jalr v0
	nop

	b ddhook_romtoram_success
	nop

ddhook_romtoram_vrom_replace_ram:
	//Copy from RAM Address
	n64dd_CallRamCopy()
	b ddhook_romtoram_success
	nop

ddhook_romtoram_ram:
	//Load from RAM
	addiu a0,a1,0
	addiu a1,a2,0
	addiu a2,a3,0

	//Copy Data from RAM to where it wants
	n64dd_CallRamCopy()

	b ddhook_romtoram_success
	nop

ddhook_romtoram_disk:
	//Load from Disk
	addiu a0,a1,0
	addiu a1,a2,0
	addiu a2,a3,0

	li a3,0x0FFFFFFF
	and a1,a1,a3

	n64dd_LoadAddress(v0, {CZLJ_DiskLoad})
	jalr v0
	nop

ddhook_romtoram_success:
	lw a0,0x14(sp)
	subiu a0,a0,0x18	//go to osMesgQueue
	ori a1,0,0
	ori a2,0,0

	n64dd_LoadAddress(a3, {CZLJ_osSendMesg})
	jalr a3			//osSendMesg, to let the engine know that the data is loaded and continue the game
	nop

	li v0,0x0FFFFFFF
	lw a2,0x78(sp)
	and a2,a2,v0
	sw a2,0x78(sp)

	ori v0,0,1

ddhook_romtoram_return:
	lw ra,0x10(sp)
	lw a0,0x14(sp)
	lw a1,0x18(sp)
	lw a2,0x1C(sp)
	lw a3,0x20(sp)
	addiu sp,sp,0x40
	jr ra
	nop
}

//ROM Loading Hook, for loading from ROM, to patch later
ddhook_romtoram_restore: {
	li a3,ddhook_romtoram
	li v0,ddhook_list_start
	sw a3,0x70(v0)

	ori v0,0,0

	jr ra
	nop
}

ddhook_ramcopy: {
	//Copy Data from RAM to where it wants
	//A0 = Dest, A1 = Offset, A2 = Size, A3 = Used for copy
	 -; lb a3,0(a1)
	sb a3,0(a0)
	addiu a0,a0,1
	addiu a1,a1,1
	subi a2,a2,1
	bnez a2,-
	nop

	jr ra
	nop
}

ddhook_ramfill: {
	//Copy Data from RAM to where it wants
	//A0 = Dest, A1 = Fill Byte, A2 = Size
	 -; sb a1,0(a0)
	addiu a0,a0,1
	subi a2,a2,1
	bnez a2,-
	nop

	jr ra
	nop
}

//Scene Entries
ddhook_sceneentry_data: {
	n64dd_SceneEntry("Cave Passage",		EZLJ_SCENE07, 0x00000000, 0x00, 0x00, 0x07)
	n64dd_SceneEntry("Red Ice Cavern",		EZLJ_SCENE09, EZLJ_SCENENAME09, 0x00, 0x00, 0x09)
	n64dd_SceneEntry("Dusk Palace Chamber",	EZLJ_SCENE15, 0x00000000, 0x00, 0x1D, 0x15)
	n64dd_SceneEntry("Dawngrove House 1",	EZLJ_SCENE2C, 0x00000000, 0x00, 0x00, 0x2C)
	n64dd_SceneEntry("Dawngrove Shop",		EZLJ_SCENE2E, 0x00000000, 0x00, 0x00, 0x2E)
	n64dd_SceneEntry("Dawngrove Inn",		EZLJ_SCENE34, 0x00000000, 0x00, 0x00, 0x34)
	n64dd_SceneEntry("Dawngrove House 2",	EZLJ_SCENE35, 0x00000000, 0x00, 0x00, 0x35)
	n64dd_SceneEntry("Great Dusk Chasm",	EZLJ_SCENE54, EZLJ_SCENENAME54, 0x00, 0x00, 0x54)
	n64dd_SceneEntry("Dawngrove Village",	EZLJ_SCENE55, EZLJ_SCENENAME55, 0x00, 0x09, 0x55)
	n64dd_SceneEntry("Dusk Palace Gardens",	EZLJ_SCENE59, EZLJ_SCENENAME59, 0x00, 0x2E, 0x59)
	n64dd_SceneEntry("Dawngrove",			EZLJ_SCENE5B, EZLJ_SCENENAME5B, 0x00, 0x2E, 0x5B)
	n64dd_SceneEntry("Cutscene Map",		EZLJ_SCENE60, 0x00000000, 0x00, 0x00, 0x60)
}
//constant ddhook_sceneentry_count(12)

ddhook_end:

if (origin() >= (0x785C8 + 0x1060)) {
  print (origin() - 0x785C8)
  error "\n\nFATAL ERROR: MAIN DISK CODE IS TOO LARGE.\nPlease reduce it and load the rest during 64DD Hook Initialization Code.\n"
}

//Initial loading from OoT File Start
seekDisk(0x1060)
dw (ddhook_start - ddhook_start)	//Source Start
dw (ddhook_end - ddhook_start)		//Source End
dw (ddhook_start | {KSEG1})		//Dest Start
dw (ddhook_end | {KSEG1})		//Dest End
dw (ddhook_list_start | {KSEG1})	//Hook Table Address

seekDisk(0)
base 0
seekDisk(0x1080)
ezlj_vertable0:
	dw 0x80127E60	// Address to Audio Tables Pointers
	dw 0x800B8250	// Address to osEPiStartDma Patch
ezlj_vertable0_end:

ezlj_vertable1:
	dw 0x80128020	// Address to Audio Tables Pointers
	dw 0x800B8270	// Address to osEPiStartDma Patch
ezlj_vertable1_end:

ezlj_vertable2:
	dw 0x80128730	// Address to Audio Tables Pointers
	dw 0x800B88D0	// Address to osEPiStartDma Patch
ezlj_vertable2_end:
