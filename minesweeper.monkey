Import mojo
Import brl

Import counter
Import tile
Global Game:Game_app

Function Main()
	Game = New Game_app
End

Class Game_app Extends App
	Const tileSize:Int = 21 'pixel width of a tile
	Field blankBack:Image
	Field menu:Image
	Field story:Image
	Field COVtile:Image
	Field FLAtile:Image
	Field option:String 'string containing selected option on menu
	Global GameState:String = "MENU"
	
	'game music
	Field music:Sound
	Field winMusic:Sound
	
	'columns, rows and mines for level
	Field cols:Int
	Field rows:Int
	Field mines:Int
	
	'x and y coordinates for grid on screen
	Field gridX:Int
	Field gridY:Int
	
	Field tiles:Tile[594] 'array storing all tiles
	Field timer:Bool 'if timer is active
	Field start:Int 'start time for a game
	Field time:Counter 'counter to display time elapsed (in seconds)
	Field mineCount:Counter 'counter to display mines unflagged
	
	Field lost:Bool 'if the game has been lost
	Field lostIMG:Image 'image to be displayed if lost
	Field won:Bool 'if the game has been won
	Field wonIMG:Image 'image to be displayed if won
	
	Field rowsChange:Counter 'counter to display number of rows
	Field colsChange:Counter 'counter to display number of cols
	Field minesChange:Counter 'counter to display number of mines
	Field changeMenu:Image 'menu on which above counters appear
	Field currentSelect:String 'which counter is selected
	
	Field leaderBoard:String[4][] 'leaderboard array
	
	'Field concentric:Bool' = True
	Field gameMode:String
	
	Field gameModeScreen:Image
	Field gameMode1:Image
	Field gameMode2:Image
	Field gameMode3:Image
	Field gameMode4:Image
	Field gameMode5:Image
	
	Field options1:Image
	Field options2:Image
	Field options3:Image
	Field optionsImage:Image
	Field doneOver:Image
	Field displayDone:Bool
	
	Field explosion1:Sound
	Field explosion2:Sound
	Field explosion3:Sound
	Field explosion4:Sound
	
	Field click:Sound
	Field rClick:Sound
	Field scream:Sound
	Field gameOver:Sound
	
	Field tilesCleared:Int
	
	Field juicy:Sound
	Field finesweeping:Sound
	Field goodjob:Sound
	Field grr:Sound
	Field merloc:Sound
	Field thechildren:Sound
	Field vn:Sound
	Field work:Sound
	Field youdidit:Sound
	
	Field mute:Bool
	
	Field overlay:Image

	Method OnCreate()
		mute = False'make the music play again
		
		juicy = LoadSound("tunes\voice\juice.ogg")
		finesweeping = LoadSound("tunes\voice\finesweeping.ogg")
		goodjob = LoadSound("tunes\voice\goodjob.ogg")
		grr = LoadSound("tunes\voice\grr.ogg")
		merloc = LoadSound("tunes\voice\merloc.ogg")
		thechildren = LoadSound("tunes\voice\thechildren.ogg")
		vn = LoadSound("tunes\voice\vn.ogg")
		work = LoadSound("tunes\voice\work.ogg")
		youdidit = LoadSound("tunes\voice\youdidit.ogg")
		
		gameOver = LoadSound("tunes\gameover.ogg")
		click = LoadSound("tunes\click.ogg")
		rClick = LoadSound("tunes\flag.ogg")
		scream = LoadSound("tunes\scream.ogg")
		explosion1 = LoadSound("tunes\explosion-01.ogg")
		explosion2 = LoadSound("tunes\explosion-02.ogg")
		explosion3 = LoadSound("tunes\explosion-03.ogg")
		explosion4 = LoadSound("tunes\explosion-04.ogg")
		options1 = LoadImage("options1.png")
		options2 = LoadImage("options2.png")
		options3 = LoadImage("options3.png")
		doneOver = LoadImage("done.png")
		music = LoadSound("tunes\music.ogg")
		winMusic = LoadSound("tunes\success.ogg")
		overlay = LoadImage("overlay.png")
		'Load leaderboard
		For Local i:Int = 0 To 3
			leaderBoard[i] = New String[2]
		Next
		
		'gameMode = "Easy"
		
		'Set to 60fps
		SetUpdateRate 60
		blankBack = LoadImage("blank.png")
		lostIMG = LoadImage("lost.png")
		wonIMG = LoadImage("won.png")
		option = "play.png"
		menu = LoadImage(option)
		story = LoadImage("storyS.png")
		COVtile = LoadImage("tiles\COVtile.png")
		FLAtile = LoadImage("tiles\FLAtile.png")
		changeMenu = LoadImage("changeMenu.png")
		gameMode1 = LoadImage("gameMode1.png")
		gameMode2 = LoadImage("gameMode2.png")
		gameMode3 = LoadImage("gameMode3.png")
		gameMode4 = LoadImage("gameMode4.png")
		gameMode5 = LoadImage("gameMode5.png")
		gameModeScreen = gameMode1
		'play music
		PlaySound(music,1,1)
		PlaySound(explosion1,3)
	End

	Method OnUpdate()
		If KeyHit(KEY_LMB) Then PlaySound(click)
		If KeyHit(KEY_RMB) Then PlaySound(rClick)
		If mute Then
			For Local i:Int = 0 To 31
				SetChannelVolume(i, 0)
			Next
		End
		If Not mute Then
			For Local i:Int = 0 To 31
				If i = 1 Or i = 2 Or i = 3
					SetChannelVolume(i, 0.2)
				Else
					SetChannelVolume(i, 1)
				End
			Next
		End
		If KeyHit(KEY_ESCAPE) Then
			Seed = Millisecs()
			Local selection = Rnd(0,2)
			If selection = 0 Then
				PlaySound(thechildren,6)
			Else
				PlaySound(work,6)
			End
			If ChannelState(1) <> 1
				StopChannel(2)
				StopChannel(3)
				PlaySound(music, 1)
			End
			GameState = "MENU"
		End
		Select GameState
			Case "MENU"
				If MouseX > 300 Then
					If MouseY < 190 Then option = "play.png"
					If MouseY >= 190 And MouseY < 230 Then option = "story.png"
					If MouseY >= 230 And MouseY < 275 Then option = "options.png"
					If MouseY >= 275 option = "leaderboard.png"
					menu = LoadImage(option)
				End
				If KeyHit(KEY_LMB) Then
					If option = "play.png" Then
						GameState = "PREPARE"
					Elseif option = "story.png" Then
						GameState = "STORY"
					Elseif option = "options.png" Then
						PlaySound(vn)
						displayDone = False
						GameState = "OPTIONS"
					Elseif option = "leaderboard.png" Then
						LoadLeader()
						GameState = "LEADERBOARD"
					End
				End
			Case "CUSTOM"
				If KeyHit(KEY_DOWN) Then
					Select currentSelect
						Case "rowsChange"
							currentSelect = "colsChange"
						Case "colsChange"
							currentSelect = "minesChange"
						Case "minesChange"
							currentSelect = "rowsChange"
					End
				End
				If KeyHit(KEY_UP) Then
					Select currentSelect
						Case "rowsChange"
							currentSelect = "minesChange"
						Case "colsChange"
							currentSelect = "rowsChange"
						Case "minesChange"
							currentSelect = "colsChange"
					End
				End
				If KeyHit(KEY_RIGHT) Then
					Select currentSelect
						Case "rowsChange"
							If rowsChange.getVal() < 22 rowsChange.Increment()
						Case "colsChange"
							If colsChange.getVal() < 26 colsChange.Increment()
						Case "minesChange"
							If minesChange.getVal() < (colsChange.getVal() * rowsChange.getVal())-1 Then minesChange.Increment()
					End
				End
				If KeyHit(KEY_LEFT) Then
					Select currentSelect
						Case "rowsChange"
							If rowsChange.getVal() > 3 Then rowsChange.Deincrement()
						Case "colsChange"
							If colsChange.getVal() > 3 Then colsChange.Deincrement()
						Case "minesChange"
							If colsChange.getVal() > 3 Then minesChange.Deincrement()
					End
				End
				
				If KeyHit(KEY_ENTER) Or gameMode = "Concentric" Then
					cols = colsChange.getVal()
					rows = rowsChange.getVal()
					mines = minesChange.getVal()
					Prepare2()
					GameState = "PLAY"
				End
			Case "PREPARE"
				If MouseY < 187 Then
					gameModeScreen = gameMode1
				Elseif MouseY >= 187 And MouseY < 230 Then
					gameModeScreen = gameMode2
				Elseif MouseY >= 230 And MouseY < 274 Then
					gameModeScreen = gameMode3
				Elseif MouseY >= 274 And MouseY < 316 Then
					gameModeScreen = gameMode4
				Elseif MouseY >= 316 Then
					gameModeScreen = gameMode5
				End
				
				If KeyHit(KEY_LMB) Then
					Select gameModeScreen
						Case gameMode1
							gameMode = "Easy"
							Prepare1(9,9,10)
						Case gameMode2
							gameMode = "Medium"
							Prepare1(16,16,40)
						Case gameMode3
							gameMode = "Hard"
							Prepare1(20,27,101)
						Case gameMode4
							gameMode = "Custom"
							Prepare1(9,9,10)
						Case gameMode5
							gameMode = "Concentric"
							Prepare1(3,3,2)
					End
				End
			Case "PLAY"
				If timer = True Then
					If Millisecs - start > 1000 Then
						start = Millisecs
						time.Increment()
					End
				End
				If timer Then won = True
				For Local i:Int = 0 To rows*cols
					If tiles[i].flagged And Not tiles[i].mine Then
						won = False
					Elseif tiles[i].mine And Not tiles[i].flagged Then
						won = False
					End
				Next
				If won Then
					timer = False
					For Local i:Int = 0 To rows*cols
						If Not tiles[i].mine Then tiles[i].covered = False
					Next
				End
				
				If ChannelState(2) = 1 And ChannelState(8) = 0 Then SetChannelVolume(2, 1)
				
				If won And ChannelState(2) = 0 Then
					Seed = Millisecs()
					Local selection = Rnd(0, 3)
					Select selection
						Case 0
							PlaySound(finesweeping, 8)
						Case 1
							PlaySound(goodjob, 8)
						Case 2
							PlaySound(youdidit, 8)
					End	
					SetChannelVolume(2, 0.2)
					StopChannel(1)
					PlaySound(winMusic, 2, 1)
				Elseif ChannelState(2) = 1 And Not won Then
					StopChannel(2)
					PlaySound(music, 1)
				End
				
				If lost And ChannelState(1) = 1 Then
					StopChannel(1)
					PlaySound(gameOver, 3)
				Elseif ChannelState(1) = 0 And Not lost And Not won Then
					StopChannel(3)
					PlaySound(music, 1)
				End
				
				If KeyHit(KEY_MMB) Then
					PlaySound(scream)
					If won And gameMode="Concentric" Then
						Prepare1(rows+2, cols+2, mines+Int((rows+cols)/3))
					Else
						Prepare1(rows,cols,mines)
					End
				End
				
				If KeyHit(KEY_LMB) And lost = False And won = False Then
					For Local i:Int = 0 To rows*cols-1
						If MouseX >= tiles[i].x And MouseX < tiles[i].x + tileSize And MouseY >= tiles[i].y And MouseY < tiles[i].y + tileSize And tiles[i].flagged = False Then
							If timer = False Then
								PlaceMines(i)
								timer = True
								start = Millisecs
							End
							If tiles[i].mine Then
								tiles[i].sprite = LoadImage("tiles\EXPtile.png")
								lost = True
								timer = False
								For Local j:Int = 0 To rows*cols
									tiles[j].covered = False
									If tiles[j].flagged And tiles[j].mine Then
										tiles[j].covered = True
									Elseif tiles[j].flagged And Not tiles[j].mine Then
										tiles[j].sprite = LoadImage("tiles\WROtile.png")
									End
								Next
								Print("boom")
								'explosions
								SetChannelVolume(4, 0.2)
								PlaySound(explosion1, 4)
								'SetChannelVolume(4, 1)
								PlaySound(scream, 5)
								Seed = Millisecs()
								Local selection = Rnd(0, 2)
								If selection = 0 Then
									PlaySound(grr, 6)
								Else
									PlaySound(merloc, 6)
								End
							Else
								tiles[i].covered = False
								tilesCleared = 0
								Clearing(i)
								If tilesCleared > 10 Then PlaySound(juicy, 10)
							End
						End
					Next
				End
				If KeyHit(KEY_RMB) And lost = False And won = False Then
					For Local i:Int = 0 To rows*cols-1
						If MouseX >= tiles[i].x And MouseX < tiles[i].x + tileSize And MouseY >= tiles[i].y And MouseY < tiles[i].y + tileSize And tiles[i].covered = True Then
							If tiles[i].flagged = False Then
								tiles[i].flagged = True
								mineCount.Deincrement()
							Else
								tiles[i].flagged = False
								mineCount.Increment()
							End
						End
					Next
				End
			Case "STORY"
				
			Case "OPTIONS"
				If displayDone Then
					If KeyHit(KEY_LMB) Then displayDone = False
				Else
					If KeyHit(KEY_LMB) Then displayDone = True
					If MouseY < 210 Then
						optionsImage = options1
					Elseif MouseY < 300 Then
						optionsImage = options2
						If KeyHit(KEY_LMB) And mute Then
							mute = False
						Elseif KeyHit(KEY_LMB) Then
							mute = True
						End
					Else
						optionsImage = options3
						If KeyHit(KEY_LMB) Then GameState = "MENU"
					End
				End
				
				
			Case "LEADERBOARD"
				
		End
	End

	Method OnRender()
		Select GameState
			Case "MENU"
				DrawImage(menu, 0, 0)
				DrawImage(overlay, 0, 0)
			Case "PREPARE"
				DrawImage(gameModeScreen, 0, 0)
			Case "CUSTOM"
				DrawImage(changeMenu, 0, 0)
				rowsChange.Draw()
				colsChange.Draw()
				minesChange.Draw()
			Case "PLAY"
				DrawImage(blankBack, 0, 0)
				For Local i:Int = 0 To rows*cols
					If tiles[i].show = True Then
						If tiles[i].flagged = True And tiles[i].covered = True Then
							DrawImage(FLAtile, tiles[i].x, tiles[i].y)
						Elseif tiles[i].covered = True Then
							DrawImage(COVtile, tiles[i].x, tiles[i].y)
						Else
							DrawImage(tiles[i].sprite, tiles[i].x, tiles[i].y)
						End
					End
				Next
				time.Draw()
				mineCount.Draw()
				DrawText(gameMode,0,0)
				If lost Then DrawImage(lostIMG, 0, 0)
				If won Then DrawImage(wonIMG, 0, 0)
			Case "STORY"
				DrawImage(story, 0, 0)
			Case "OPTIONS"
				DrawImage(optionsImage,0,0)
				If displayDone Then DrawImage(doneOver,0,0)
			Case "LEADERBOARD"
				DrawImage(blankBack, 0, 0)
				DrawText("Easy" + " " + leaderBoard[0][0] + " " + leaderBoard[0][1], 50, 70)
				DrawText("Medium" + " " + leaderBoard[1][0] + " " + leaderBoard[1][1], 50, 90)
				DrawText("Hard" + " " + leaderBoard[2][0] + " " + leaderBoard[2][1], 50, 110)
				DrawText("Concentric " + leaderBoard[3][0] + " Stage " + leaderBoard[3][1], 50, 130)
		End
	End
	
	Method LoadLeader()
		Local level_file:FileStream
		Local level_data:String
		Local data_item:String[]
		
		level_file = FileStream.Open("monkey://data/leader.txt", "r")
		level_data = level_file.ReadString()
		level_file.Close
		
		data_item = level_data.Split("~n")
		For Local i:Int = 0 To data_item.Length()-1
			leaderBoard[i] = data_item[i].Split(",")
		Next
	End
	
	Method Clearing(tile)
		Local adj:Int[] = New Int[8]
		'Top left tile
		If tile = 0 Then
			adj = [tile+1,tile+cols,tile+cols+1]
		'Top right tile
		Elseif tile = cols-1 Then
			adj = [tile-1,tile+cols-1,tile+cols]
		'Bottom left tile
		Elseif tile = cols*(rows-1) Then
			adj = [tile-cols,tile-cols+1,tile+1]
		'Bottom right tile
		Elseif tile = cols*rows-1 Then
			adj = [tile-cols-1,tile-cols,tile-1]
		'Top row
		Elseif tile > 0 And tile < cols - 1 Then
			adj = [tile-1,tile+1,tile+cols-1,tile+cols,tile+cols+1]
		'Bottom row
		Elseif tile < rows*cols And tile > cols*(rows-1)
			adj = [tile-cols-1,tile-cols,tile-cols+1,tile-1,tile+1]
		'Left col
		Elseif tile Mod cols = 0 Then
			adj = [tile-cols,tile-cols+1,tile+1,tile+cols,tile+cols+1]
		'Right col
		Elseif tile Mod cols = cols-1 Then
			adj = [tile-cols-1,tile-cols,tile-1,tile+cols-1,tile+cols]
		'OTHERWISE
		Else
			adj = [tile-cols-1,tile-cols,tile-cols+1,tile-1,tile+1,tile+cols-1,tile+cols,tile+cols+1]
		End
		 
		If tiles[tile].adj = 0 Then
			For Local i:Int = 0 To adj.Length - 1
				Local index = adj[i]
				If tiles[index].covered = True
					tilesCleared += 1
					tiles[index].covered = False
					Clearing(index)
				End
			Next
		End
	End
	
	Method PlaceMines(firstTile)
		Local minesLeft:Int = mines
		Seed = Millisecs()
		While minesLeft <> 0
			Local x = Rnd(0, (cols*rows))
			If x <> firstTile And Not tiles[x].mine Then
				tiles[x].mine = True
				tiles[x].sprite = LoadImage("tiles\MINtile.png")
				minesLeft -= 1
			End
		End
		'!!!!FIX THIS UGLY SHIZZLE
		For Local i = 0 To rows*cols-1
			Local mines:Int = 0
			If tiles[i].mine = False Then
				'Top left tile
				If i = 0 Then
					'Right
					If tiles[i+1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
					'Down-right
					If tiles[i+cols+1].mine = True Then mines += 1
				'Top right tile
				Elseif i = cols-1 Then
					'Left
					If tiles[i-1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
					'Down-left
					If tiles[i+cols-1].mine = True Then mines += 1
				'Bottom left tile
				Elseif i = cols*(rows-1) Then
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Right
					If tiles[i+1].mine = True Then mines += 1
					'Up-right
					If tiles[i-cols+1].mine = True Then mines += 1
				'Bottom right tile
				Elseif i = cols*rows-1 Then
					'Up-left
					If tiles[i-cols-1].mine = True Then mines += 1
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Left
					If tiles[i-1].mine = True Then mines += 1
				'Top col
				Elseif i > 0 And i < cols - 1 Then
					'Left
					If tiles[i-1].mine = True Then mines += 1
					'Right
					If tiles[i+1].mine = True Then mines += 1
					'Down-left
					If tiles[i+cols-1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
					'Down-right
					If tiles[i+cols+1].mine = True Then mines += 1
				'Bottom col
				Elseif i < rows*cols And i > cols*(rows-1)
					'Up-left
					If tiles[i-cols-1].mine = True Then mines += 1
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Up-right
					If tiles[i-cols+1].mine = True Then mines += 1
					'Left
					If tiles[i-1].mine = True Then mines += 1
					'Right
					If tiles[i+1].mine = True Then mines += 1
				'Left col
				Elseif i Mod cols = 0 Then
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Up-right
					If tiles[i-cols+1].mine = True Then mines += 1
					'Right
					If tiles[i+1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
					'Down-right
					If tiles[i+cols+1].mine = True Then mines += 1
				'Right col
				Elseif i Mod cols = cols-1 Then
					'Up-left
					If tiles[i-cols-1].mine = True Then mines += 1
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Left
					If tiles[i-1].mine = True Then mines += 1
					'Down-left
					If tiles[i+cols-1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
				'OTHERWISE
				Else
					'Up-left
					If tiles[i-cols-1].mine = True Then mines += 1
					'Up
					If tiles[i-cols].mine = True Then mines += 1
					'Up-right
					If tiles[i-cols+1].mine = True Then mines += 1
					'Left
					If tiles[i-1].mine = True Then mines += 1
					'Right
					If tiles[i+1].mine = True Then mines += 1
					'Down-left
					If tiles[i+cols-1].mine = True Then mines += 1
					'Down
					If tiles[i+cols].mine = True Then mines += 1
					'Down-right
					If tiles[i+cols+1].mine = True Then mines += 1
				End
				
				tiles[i].adj = mines
				If tiles[i].adj > 0 Then
					tiles[i].sprite = LoadImage("tiles\"+tiles[i].adj+".png")
				End
			End
		Next
	End
	
	Method CreateTiles()
		For Local i = 0 To cols*rows
			tiles[i] = New Tile
		Next
		Local tileNum:Int = 0
		For Local i:Int = 0 To rows-1
			For Local j:Int = 0 To cols-1
				tiles[tileNum].x = gridX + (j*tileSize)
				tiles[tileNum].y = gridY + (i*tileSize)
				tiles[tileNum].show = True
				tileNum += 1
			Next
		Next
	End
	
	Method Prepare1(nRows,nCols,nMines)
		lost = False
		won = False
		timer = False
		
		time = New Counter
		time.x = 30
		time.y = 15
		mineCount = New Counter
		mineCount.x = 30+(15*5)
		mineCount.y = 15
		
		If gameMode = "Custom"
			rowsChange = New Counter(50, 50, 0, 0, 0)
			rowsChange.setVal(nRows)
			colsChange = New Counter(50, 100, 0, 0, 0)
			colsChange.setVal(nCols)
			minesChange = New Counter(50, 150, 0, 0, 0)
			minesChange.setVal(nMines)
			currentSelect = "rowsChange"
			GameState = "CUSTOM"
		Else
			cols = nCols
			rows = nRows
			mines = nMines
			Prepare2()
			GameState = "PLAY"
		End
	End
	
	Method Prepare2()
		gridX = 300 - ((0.5*cols)*tileSize)
		gridY = 278 - ((0.5*rows)*tileSize)
		
		CreateTiles()
		
		For Local i = 1 To mines
			mineCount.Increment()
		Next
	End
End