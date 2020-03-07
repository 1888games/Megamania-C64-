ENEMIES:{

	.label NumberOfLevels = 2
	.label DrawRows = 7
	.label ShipCollisionMin = 178
	.label MaxEnemyYPosition = 202
	.label MinEnemyYPosition = 40

	Wave_Data: 	.word Level_1, Level_2

	X_Speed:	  		.byte 002, 000, 002
	Y_Speed:	  		.byte 001, 001, 000
	X_Direction:  		.byte 000, 000, 000
	X_Direction_Odd:	.byte 001, 000, 000
	FramesPerX:	  		.byte 000, 000, 000
	FramesPerY:	  		.byte 003, 001, 003
	Time:		  		.byte 060, 040, 060

	Level_1:		.byte 0, 1, 2
	Level_2:		.byte 1, 2

	Wavelengths:	.byte 001, 002
	StartFrames:	.byte 016, 024
	Frames:			.byte 006, 006
	Rows:			.byte 003, 004
	Columns:		.byte 005, 004
	GapX:			.byte 080, 070
	GapY:			.byte 023, 035
	OddOffsetX:		.byte 040, 035
	XStart:			.byte 060, 030
	XStart_Odd:		.byte 060, 255
	XStart_MSB:		.byte 254, 255
	Xstart_MSB_Odd:	.byte 001, 000
	YStart:			.byte 050, 020
	YStart_MSB:		.byte 000, 000
	Colours:		.byte 010, 007
	FramesPerFrame: .byte 003, 003

	CurrentLevelID:			.byte 0
	CurrentWaveID:			.byte 0
	CurrentMovementID:		.byte 0
	CurrentMovementTime:	.byte 0, 0

	CurrentXSpeed:			.byte 0
	CurrentXDirection:		.byte 0, 0
	CurrentYSpeed:			.byte 0
	CurrentXFrames:			.byte 0, 0
	CurrentYFrames:			.byte 0, 0

	CurrentFrame:			.byte 0
	CurrentFrames:			.byte 6

	CurrentRows:			.byte 7
	CurrentColumns:			.byte 5
	CurrentDrawRow:			.byte 0
	CurrentWaves:			.byte 0, 0, 0, 0, 0, 0, 0, 0
	CurrentWaveLength:		.byte 0
	CurrentStartFrame:		.byte 0

	CurrentGapX:			.byte 0
	CurrentGapY:			.byte 0
	CurrentOddOffsetX:		.byte 0
	CurrentXStart_LSB:		.byte 0, 0
	CurrentYStart_LSB:		.byte 0
	CurrentXStart_MSB:		.byte 0, 0
	CurrentYStart_MSB:		.byte 0
	CurrentFramesPerFrame:	.byte 0
	FrameCounter:			.byte 0

	EnemiesSpawned:			.byte 0
	EnemiesReady:		.byte 0
	LevelActive:		.byte 0


	// Positional Data

	PosX_MSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	PosX_LSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	OddorEven:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	PosY_MSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0
	PosY_LSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0

	OrigPosX_MSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	OrigPosX_LSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	OrigPosY_MSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0
	OrigPosY_LSB:		.byte 0, 0, 0, 0, 0, 0, 0, 0

	IRQ_Data:			.byte 0, 1, 2, 3, 4, 5, 6
	RowFirstEnemyIndex:	.byte 0, 5, 10, 15, 20, 25, 30, 40


	// Lookup

	Times2:			.byte 0, 2, 4, 6, 8, 10, 12


	Reset:{

		
		lda #0
		sta LevelActive
		sta EnemiesReady



		rts
	}
	

	ResetLevel: {

		lda #99
		sta CurrentDrawRow

		lda 0
		sta BULLET.EnemyToFire

		ldx #0

		XLoop:

			lda PosX_MSB, x
			cmp #03
			beq EndXLoop

			lda OrigPosX_MSB, x
			sta PosX_MSB, x

			lda OrigPosX_LSB, x
			sta PosX_LSB, x

			EndXLoop:

			inx
			cpx #18
			beq CopyY
			jmp XLoop

		CopyY:

		ldx #0

		YLoop:

			txa
			sta IRQ_Data, x

			cpx CurrentRows
			bcs EndYLoop

			lda OrigPosY_MSB, x
			sta PosY_MSB, x

			lda OrigPosY_LSB, x
			sta PosY_LSB, x

			EndYLoop:

			inx
			cpx #07
			beq Finish
			jmp YLoop

		Finish:



		rts
	}


	PlayerReady: {

		lda LevelActive
		beq LoadNewLevel

		lda #1
		sta EnemiesReady

		jmp Finish

		LoadNewLevel:

			jsr NewLevel
			jsr SpawnWave

			lda #1
			sta LevelActive


		Finish:

		rts
	}


	PlayerDied: {

	
		ldx #0
		stx VIC.SPRITE_0_X + 2
		stx EnemiesReady
		stx VIC.SPRITE_0_X + 4			
		stx VIC.SPRITE_0_X + 6
		stx VIC.SPRITE_0_X + 8
		stx VIC.SPRITE_0_X + 10
		stx VIC.SPRITE_0_X + 12
		stx VIC.SPRITE_0_X + 14

		lda VIC.SPRITE_MSB
		and #%00000001		// reset MSB positions
		sta VIC.SPRITE_MSB


		rts
	}



	SetXPosition: {

		 ldx CurrentDrawRow
		 lda IRQ_Data, x
		 sta RowIRQIndex
		 tay

		ldx #0	// reset sprite positions so that unused sprites won't be seen
		stx VIC.SPRITE_0_X + 2
		stx VIC.SPRITE_0_X + 4			
		stx VIC.SPRITE_0_X + 6
		stx VIC.SPRITE_0_X + 8
		stx VIC.SPRITE_0_X + 10
		stx VIC.SPRITE_0_X + 12
		stx VIC.SPRITE_0_X + 14

		lda VIC.SPRITE_MSB
		and #%00000001		// reset MSB positions
		sta VIC.SPRITE_MSB

		ldy RowIRQIndex			// Get current enemy row being drawn
		lda RowFirstEnemyIndex, y // Get start of XPos data for row
		tax
		
		ldy #0

		// y = 0 to number of columns in this level
		// x = X data start to X data start + no columns

	 	Loop:

	 		sty Column // store in ZP for later

	 		// check whether enemy is active, 2=dead, 255 = x < 0
	 		lda PosX_MSB, x
			cmp #0
	 		beq MSB_Off

	 		cmp #1
	 		beq MSB_On

	 		jmp EndLoop

			MSB_On:

				lda VIC.SPRITE_MSB
				ora VIC.MSB_On + 1, y
				sta VIC.SPRITE_MSB
				jmp XPosition

			MSB_Off:

				lda VIC.SPRITE_MSB
	 			and VIC.MSB_Off + 1, y
	 			sta VIC.SPRITE_MSB

	 		XPosition:

	 			// load X position and store in correct sprite register
	 			lda Times2, y
	 			tay
	 			
				lda PosX_LSB, x
				sta VIC.SPRITE_0_X + 2, y

		
		EndLoop:
			// check whether all columns in this level handled, loop if not
			ldy Column
			inx
			iny
	 		cpy CurrentColumns
	 		beq Finish
			jmp Loop


	 Finish:

	 	rts



 }

	SetYPosition: {

		ldy RowIRQIndex
		ldx CurrentDrawRow

		// y = data row being drawn
		// x = physical row being drawn

		lda PosY_LSB, y

		sta VIC.SPRITE_0_Y + 2
		sta VIC.SPRITE_0_Y+  4
		sta VIC.SPRITE_0_Y + 6
		sta VIC.SPRITE_0_Y + 8
		sta VIC.SPRITE_0_Y + 10
		sta VIC.SPRITE_0_Y + 12
		sta VIC.SPRITE_0_Y + 14

		inx
		cpx #DrawRows
		beq AllRowsDrawn	

		stx CurrentDrawRow
		jmp Finish

		AllRowsDrawn:

			ldy #99
			sty CurrentDrawRow	


		Finish:


		rts


	}

	SetSpritePointers: {

		

		lda CurrentStartFrame
		clc

		adc CurrentFrame

		sta SPRITE_POINTERS + 1
		sta SPRITE_POINTERS + 2
		sta SPRITE_POINTERS + 3
		sta SPRITE_POINTERS + 4
		sta SPRITE_POINTERS + 5
		sta SPRITE_POINTERS + 6
		sta SPRITE_POINTERS + 7


		rts
	}


	DrawRow: {


		jsr SetXPosition
		jsr SetYPosition
	


		Finish:

		rts
	

		
	}




	GetNextIRQLine: {


		CheckLoop:

			ldy CurrentDrawRow

			cpy #99
			bcs FinishedDrawing

			lda IRQ_Data, y
			tax
			lda PosY_MSB,x

			cmp #01
			bcs NextRow

			lda PosY_LSB, x
			sec
			sbc #12
			tay

			cmp #36
			bcc NextRow

			
			Okay:

			jmp Finish

				NextRow:

				inc CurrentDrawRow
				ldy CurrentDrawRow
				cpy CurrentRows	
				bcc CheckLoop

				jmp FinishedDrawing
			

			FinishedDrawing:

			ldy #255

		Finish:

		rts


	}


	NewLevel: {

		jsr RESET.EnemyData
		rts


	}



	UpdateXPositionOld:{


		ldx #0

	 	LoopX:

		lda VIC.SPRITE_0_X + 2, x
		clc
		adc CurrentXSpeed
		sta VIC.SPRITE_0_X + 2, x

		inx
		cpx #14
		beq Finish
		jmp LoopX

		Finish:




		rts
	
	}

	UpdateXPosition: {



		lda CurrentXFrames
		beq ReadyToMove

		dec CurrentXFrames
		jmp Finish

		ReadyToMove:

			lda CurrentXFrames + 1
			sta CurrentXFrames

			ldx #0

		Loop:

			stx CurrentID

			lda PosX_MSB, x
			cmp #3
			bne Continue

			jmp EndLoop

			Continue:

			lda OddorEven, x
			tay
			lda CurrentXDirection, y
			beq MoveRight

			MoveLeft:

			lda PosX_LSB, x
			sec  
			sbc CurrentXSpeed
			sta PosX_LSB, x

			lda PosX_MSB, x
			sbc #00
			sta PosX_MSB, x

			CheckLeftWrap:

				bne CheckCollision

				lda PosX_LSB, x

				cmp #10
				bcs CheckCollision
 
				lda #150
				sta PosX_LSB, x

				lda #1
				sta PosX_MSB, x
				jmp EndLoop


			MoveRight:


			lda PosX_LSB, x
			clc
			adc CurrentXSpeed
			sta PosX_LSB, x

			lda PosX_MSB, x
			adc #00
			sta PosX_MSB, x

			CheckXWrap:

				cmp #01
				beq CheckLSB

				jmp CheckCollision

				CheckLSB:

				lda PosX_LSB, x
				cmp #150
				bcc CheckCollision

				lda #0
				sta PosX_LSB, x

				lda #0
				sta PosX_MSB, x
				jmp EndLoop

			
			CheckCollision:

				lda BULLET.Active
				bne BulletLive 

				jmp EndLoop

				lda BULLET.Destroy
				beq BulletLive

				jmp EndLoop

				BulletLive:

				lda PosX_MSB, x
				beq OkayToCollide

				cmp #1
				beq OkayToCollide

				jmp EndLoop

				OkayToCollide:

					lda PosX_LSB, x
					//clc
					//adc #4
					sec
					//sbc #3  // enemy sprite offset
					sbc BULLET.PosX
					sta Diff_LSB

					lda PosX_MSB, x
					sbc BULLET.MSBX
					sta Diff_MSB

					bcs Positive

				Negative:

					lda Diff_LSB
					sbc #00
					eor #$ff
					sta Diff_LSB

					lda Diff_MSB
					sbc #00
					eor #$ff
					sta Diff_MSB
		
				Positive:

					lda Diff_MSB
					bne TooFarAway

					lda Diff_LSB
					cmp #9
					bcs TooFarAway	

					// COLLISION ON AXIS


				//pha
				//lda PosX_LSB, x
				//tax
				//ldy BULLET.PosX
				//pla

				//.break

				

				ldy #1	// look ahead to the next row and see if enemy ID is below that start value
						// for last row + 1 use total number of enemies

			

				CheckYPosition:

			 		lda RowFirstEnemyIndex, y
			 		cmp CurrentID
			 		bcc NextRow

			 		//.break

			 		dey

			 		lda PosY_MSB, y
			 		bne NoYCollision

			 		lda PosY_LSB, y
			 		clc
			 		adc #16
					sec
			 		//sbc #8
			 		sbc BULLET.PosY
					
			 		bcs PositiveDiff

			 		eor #$ff
			 		adc #01

			 		PositiveDiff:

			 		cmp #8
			 		bcs TooFarAway
			 		// pha
			 		// lda PosY_LSB, y
			 		// tay
			 		// ldx BULLET.PosY
			 		// pla

			 	//	inc $d021

			 		lda #3
			 		sta PosX_MSB, x
			 		sta BULLET.Destroy
			 		dec EnemiesSpawned

			 		sfx(2)

					jmp EndLoop

					NextRow:

					
						cpy CurrentRows
						iny
						bne ContinueToNextRow

						ContinueToNextRow:
						jmp CheckYPosition

				NoYCollision:

			
				TooFarAway:

				ldx CurrentID
				//jsr CheckWhetherToFire

				// dec $d020

			EndLoop:

				ldx CurrentID
				
				inx
				cpx #18
				beq Finish
				jmp Loop


		Finish:


		rts
	}



	CheckShipCollision: {

		cmp #ShipCollisionMin
		bcc Finish

		lda RowFirstEnemyIndex, x
		tay

		inx
		lda RowFirstEnemyIndex, x
		sta NextRowStartIndex
		dex

		Loop:

			lda PosX_MSB, y
			cmp SHIP.PosX_MSB
			bne EndLoop

			lda PosX_LSB, y
			sec
			sbc SHIP.PosX_LSB

			bcs Positive

			eor #$ff
			adc #01

			Positive:

			cmp #08
			bcs EndLoop

			jsr SHIP.Kill
			jmp Finish

			EndLoop:

				iny
				cpy NextRowStartIndex
				beq Finish
				jmp Loop


		Finish:

		rts
	}

	UpdateYPosition: {

		lda CurrentYFrames
		beq ReadyToMove

		dec CurrentYFrames
		jmp Finish

		ReadyToMove:

		lda CurrentYFrames + 1
		sta CurrentYFrames

		ldx #0	// x = row number

		Loop:

		 	stx Row

		 	lda PosY_MSB, x
		 	cmp #2
		 	beq EndLoop

		 	cmp #255
		 	beq EndLoop

		 	lda PosY_LSB, x
		 	clc
		 	adc CurrentYSpeed
		 	sta PosY_LSB, x

		 	//ldy IRQ_Data, x
		 	//sec
		 	//sbc YOffsets, y
		 	cmp #MaxEnemyYPosition
		 	bcs WrapY

		 	jsr CheckShipCollision
		 	jmp EndLoop

		 	WrapY:

			lda #MinEnemyYPosition
			//sec
			//sbc YOffsets, y
			sta PosY_LSB, x

			ldy CurrentRows
			dey

			lda IRQ_Data, y 	// y = 6 (last row)
			sta RowLoopEnd

			tya
			tax      // x = 5 ( last row - 1)
			dex

			CopyLoop:

				lda IRQ_Data, x
				sta IRQ_Data, y

				cpx #0
				beq EndCopyLoop

				dex
				dey

				jmp CopyLoop

			EndCopyLoop:

				lda RowLoopEnd
				sta IRQ_Data

			EndLoop:

				ldx Row
			 	inx
			 	cpx #7
			 	beq Finish
			 	jmp Loop




		Finish:

			rts


	}
	

	UpdateSpriteFrameID: {

		lda FrameCounter
		beq UpdateFrame

		dec FrameCounter
		jmp Finish

		UpdateFrame:

		lda CurrentFramesPerFrame
		sta FrameCounter

		inc CurrentFrame
		lda CurrentFrame
		cmp CurrentFrames
		bcc SetPointers

		lda #0
		sta CurrentFrame

		SetPointers:

		jsr SetSpritePointers

		Finish:

			rts


	}



	UpdateWave: {

		lda CurrentMovementTime
		beq MovementComplete

		dec CurrentMovementTime
		jmp Finish

		MovementComplete:


			ldx CurrentMovementID
			inx
			cpx CurrentWaveLength
			bcc NextMovement

			ldx #0

			NextMovement:

				stx CurrentMovementID
				jsr SetupWave

		Finish:

			rts



	}



	CheckWhetherLevelComplete: {


		lda EnemiesSpawned
		bne Finish

		lda #1
		sta SHIP.Paused

		lda #1
		sta ENERGY.LevelComplete

		lda #0
		sta LevelActive

		ldx CurrentLevelID
		inx
		cpx #NumberOfLevels
		bcc StoreLevel

		ldx #0

		StoreLevel:

		stx CurrentLevelID


		Finish:


		rts


	}

	Update: {

		jsr UpdateSpriteFrameID

		lda SHIP.Paused
		bne Finish


		jsr UpdateWave
		jsr UpdateYPosition
		jsr UpdateXPosition
		jsr CheckWhetherToFire

		jsr CheckWhetherLevelComplete
		//jsr UpdateXPositionOld

		Finish:

		rts
	}

	
	CheckWhetherToFire: {

		lda SHIP.Paused
		bne Finish

		lda BULLET.EnemyToFire
		bne Finish

		lda BULLET.Active + 1
		beq Okay

		lda BULLET.Active + 2
		beq Okay

		jmp Finish

		Okay:

		jsr RANDOM.Get

		and #%01111111

		cmp #18
		bcs Finish

		tax

		lda PosX_MSB, x
		cmp #2
		bcc OkayOnX

		jmp Finish

		OkayOnX:

			ldy #1

			Loop:

				txa
				cmp RowFirstEnemyIndex, y
				bcc FoundRow

				iny
				jmp Loop

			FoundRow:

			dey
			lda PosY_LSB, y

			cmp #140
			bcs Finish

			cmp #48
			bcc Finish

		sta BULLET.EnemyFireY

		lda #1
		sta BULLET.EnemyToFire
		
		lda PosX_MSB, x
		sta BULLET.EnemyFireX_MSB

		lda PosX_LSB, x
		sta BULLET.EnemyFireX_LSB

		Finish:


		rts
	}

	SetupWave: {

		ldx CurrentMovementID

		lda CurrentWaves, x
		tax

		lda X_Speed, x
		sta CurrentXSpeed

		lda X_Direction, x
		sta CurrentXDirection

		lda X_Direction_Odd, x
		sta CurrentXDirection + 1

		lda FramesPerX, x
		sta CurrentXFrames + 1
		sta CurrentXFrames

		lda Y_Speed, x
		sta CurrentYSpeed

		lda FramesPerY, x
		sta CurrentYFrames + 1
		sta CurrentYFrames

		lda Time, x	
		sta CurrentMovementTime + 1
		sta CurrentMovementTime
	

		rts

	}

	SpawnWave: {

		lda CurrentLevelID
		asl
		tax
		lda Wave_Data, x
		sta WaveDataAddress + 1
		inx
		lda Wave_Data, x
		sta WaveDataAddress + 2

		ldx #0
		ldy CurrentLevelID

		lda Wavelengths, y
		sta CurrentWaveLength

		WaveDataAddress:

			lda $BEEF, x
			sta CurrentWaves, x
			inx
			txa
			cmp CurrentWaveLength
			beq FinishWaves

			tax
			jmp WaveDataAddress

		FinishWaves:

			lda StartFrames, y
			sta CurrentStartFrame

			lda FramesPerFrame, y
			sta CurrentFramesPerFrame

			lda Frames, y
			sta CurrentFrames

			lda Rows, y
			sta CurrentRows

			lda Columns, y
			sta CurrentColumns

			lda GapX, y
			sta CurrentGapX

			lda GapY, y
			sta CurrentGapY

			lda OddOffsetX, y
			sta CurrentOddOffsetX

			lda YStart, y
			sta CurrentYStart_LSB

			lda XStart, y
			sta CurrentXStart_LSB

			lda XStart_Odd, y
			sta CurrentXStart_LSB + 1

			lda Xstart_MSB_Odd, y
			sta CurrentXStart_MSB + 1

			lda XStart_MSB, y
			sta CurrentXStart_MSB


			lda YStart_MSB, y
			sta CurrentYStart_MSB

			lda Colours, y
			sta VIC.SPRITE_COLOR_1
			sta VIC.SPRITE_COLOR_2
			sta VIC.SPRITE_COLOR_3
			sta VIC.SPRITE_COLOR_4
			sta VIC.SPRITE_COLOR_5
			sta VIC.SPRITE_COLOR_6
			sta VIC.SPRITE_COLOR_7


			lda #0
			sta CurrentWaveID
			sta CurrentMovementID
			sta CurrentMovementTime
			sta CurrentXSpeed
			sta CurrentYSpeed
			sta CurrentFrame
			sta CurrentDrawRow
			
			sta EnemiesSpawned

			// Get Y Positions

			ldy #0
			lda CurrentYStart_LSB

		Loop:
			
			iny
			cpy CurrentRows
			beq Finish

		Finish:

		ldx #0	// enemy ID
		stx VIC.SPRITE_0_X + 2
		stx VIC.SPRITE_0_X + 4			
		stx VIC.SPRITE_0_X + 6
		stx VIC.SPRITE_0_X + 8
		stx VIC.SPRITE_0_X + 10
		stx VIC.SPRITE_0_X + 12
		stx VIC.SPRITE_0_X + 14

		jsr SetupWave
		jsr SpawnEnemies

		rts


	}


	ClearEnemies: {


		lda #2
		sta PosY_MSB
		sta PosY_MSB + 1
		sta PosY_MSB + 2
		sta PosY_MSB + 3
		sta PosY_MSB + 4
		sta PosY_MSB + 5
		sta PosY_MSB + 6

		lda #0

		sta PosY_LSB
		sta PosY_LSB + 1
		sta PosY_LSB + 2
		sta PosY_LSB + 3
		sta PosY_LSB + 4
		sta PosY_LSB + 5
		sta PosY_LSB + 6

		ldx #0

		Loop:

			lda #3
			sta PosX_MSB, x
			sta OrigPosX_MSB, x

			lda #0
			sta PosX_LSB, x
			sta OrigPosX_LSB, x
		
			inx
			cpx #18
			beq Finish
			jmp Loop


		Finish:


		rts
	}

	SpawnEnemies:	{


		ldy #0		// current row
		sty EnemiesSpawned
		sty RowIsOdd

		lda CurrentYStart_MSB
		sta CurrentY_MSB

		lda CurrentYStart_LSB
		sta CurrentY_LSB

		jsr ClearEnemies


		RowLoop:

			//.break


			sty Row
			lda Row
			lsr
			bcc EvenRow

			OddRow:

			
				lda #1
				sta RowIsOdd
				tay

				clc
				lda CurrentXStart_LSB + 1
				jmp StoreStartX

			EvenRow:

				lda #0
				sta RowIsOdd
				tay

				lda CurrentXStart_LSB
				clc
				adc CurrentOddOffsetX
	
			StoreStartX:

				sta CurrentX_LSB

				lda CurrentXStart_MSB, y
				adc #00
				sta CurrentX_MSB

				
			StoreYForRow:

				ldy Row
				lda CurrentY_LSB
				sta PosY_LSB, y
				sta OrigPosY_LSB, y

				lda CurrentY_MSB
				sta PosY_MSB, y
				sta OrigPosY_MSB, y

				lda EnemiesSpawned
				sta RowFirstEnemyIndex, y	
	 
				ldx #0

			ColumnLoop:

				stx Column

				ldx EnemiesSpawned
				inc EnemiesSpawned

				lda RowIsOdd
				sta OddorEven, x

				lda CurrentX_LSB
				sta PosX_LSB, x
				sta OrigPosX_LSB, x

				lda CurrentX_MSB
				sta PosX_MSB, x
				sta OrigPosX_MSB, x

				//.break

				ldx Column
				inx
				cpx CurrentColumns
				beq EndRowLoop

				NextColumn:

					lda CurrentX_LSB
					clc
					adc CurrentGapX
					sta CurrentX_LSB

					lda CurrentX_MSB
					adc #00
					sta CurrentX_MSB
					jmp ColumnLoop


			EndRowLoop:

				iny

				cpy CurrentRows
				beq Finish

				//.break


				lda CurrentY_LSB
				clc
				adc CurrentGapY
				sta CurrentY_LSB

		
				lda CurrentY_MSB
				adc #00
				sta CurrentY_MSB

			

				jmp RowLoop


		Finish:
	

		lda #99
		iny
		sta RowFirstEnemyIndex, y

		lda #1
		sta EnemiesReady



		rts

	}






}