Import mojo

Class Tile
	Field x:Int
	Field y:Int
	Field covered:Bool
	Field mine:Bool
	Field flagged:Bool
	Field sprite:Image
	Field adj:Int
	Field show:Bool
	
	Method New()
		x = 0
		y = 0
		adj = 0
		covered = True
		flagged = False
		mine = False
		show = False
		sprite = LoadImage("tiles\UNCtile.png")
	End
End
