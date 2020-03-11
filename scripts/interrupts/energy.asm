ENERGY: {
	

	Timer:	.byte 5, 28, 0
	CurrentCharacter: .byte 0
	CurrentFillValue:	.byte 0

	.label EnergyBarStartColumn = 11
	.label EnergyBarEndColumn = 30
	.label EnergyBarRow = 20
	.label StartCharacterID = 24
	.label NumberOfCharacters = 20
	.label InitialDelay = 180


	Decreasing:	.byte 0
	LiveLost:	.byte 0
	LevelComplete:		.byte 0


	Reset: {


		lda #0
		sta CurrentCharacter
		sta CurrentFillValue
		sta Decreasing
		sta LiveLost
		sta LevelComplete

		lda Timer + 2
		sta Timer

		sfx(3)


		rts

	}



	SetEnergyZero: {

		lda #0
		sta CurrentCharacter
		sta CurrentFillValue

		lda #StartCharacterID

		ldx #0

		Loop:

			sta SCREEN_RAM + 811, x
			inx
			cpx #20
			beq Finish
			jmp Loop

		jsr BULLET.ResetLevel

		Finish:

		rts
	}

	Draw: {

		lda #EnergyBarStartColumn
		clc
		adc CurrentCharacter
		tax

		ldy #EnergyBarRow

		lda #StartCharacterID
		clc
		adc CurrentFillValue

		//.break

		jsr PLOT.PlotCharacter


		rts
	}



	

	Update: {

		lda SHIP.Dead
		beq Okay

		jmp Finish

		Okay:

		lda Timer
		beq TimerExpired

		dec Timer
		jmp Finish

		TimerExpired:

			lda LevelComplete
			beq CheckWhetherDecreasing

			lda Timer + 2
			sta Timer

			jmp Decrease


		CheckWhetherDecreasing:

			lda Decreasing
			beq IncreaseBar

		DecreaseBar:

			lda Timer + 1
			sta Timer

		Decrease:

			dec CurrentFillValue
			lda CurrentFillValue
			cmp #255
			bcc OkayToDraw

			PrevCharacter:

				dec CurrentCharacter
				lda CurrentCharacter
				cmp #255
				bne NotDead

				lda LevelComplete
				beq Died


			BarClearEndLevel:

				jsr Reset
			
				jmp Finish

			Died:

				lda #1
				sta LiveLost


				jsr SHIP.Kill

				jmp Finish

			NotDead:

				lda #3
				sta CurrentFillValue

				jmp OkayToDraw

		IncreaseBar:

			lda Timer + 2
			beq Switch

			lda #0
			sta Timer + 2
			jmp Time

			Switch:

			lda #1
			sta Timer + 2

			Time:

			sta Timer

			inc CurrentFillValue

		
			lda CurrentFillValue
			cmp #5
			bcc OkayToDraw

			NextCharacter:

				inc CurrentCharacter
				lda CurrentCharacter
				cmp #NumberOfCharacters

				bne NoReverse

			ReverseDirection:

				lda #0
				sta SHIP.Paused

				lda #1
				sta Decreasing

				lda #InitialDelay
				sta Timer

				jsr ENEMIES.PlayerReady

				dec CurrentCharacter
				jmp Finish

			NoReverse:

				lda #1
				sta CurrentFillValue

		OkayToDraw:

			jsr Draw


		Finish:


		rts
	}



}