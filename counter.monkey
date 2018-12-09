Import mojo

Class Counter
	Field x:Int
	Field y:Int
	Field num1:Int
	Field num2:Int
	Field num3:Int
	Field width:Int = 15
	
	Method New(nx, ny, n1, n2, n3)
		x = nx
		y = ny
		num1 = n1
		num2 = n2
		num3 = n3
	End
	
	Method Increment()
		If num3 < 9 Then
			num3 += 1
		Elseif num2 < 9
			num2 += 1
			num3 = 0
		Elseif num1 < 9
			num1 += 1
			num2 = 0
			num3 = 0
		End
	End
	
	Method Deincrement()
		If num3 > 0 Then
			num3 -= 1
		Elseif num2 > 0 Then
			num2 -= 1
			num3 = 9
		Elseif num1 > 0 Then
			num1 -= 1
			num2 = 9
			num3 = 9
		End
	End
	
	Method getVal()
		Local totalValue:Int = 0
		totalValue += num1*100
		totalValue += num2*10
		totalValue += num3
		Return totalValue
	End
	
	Method setVal(aim)
		If aim > getVal() Then
			While aim > getVal()
				Increment()
			End
		Else
			While aim < getVal()
				Deincrement()
			End
		End
	End
	
	Method Draw()
		Local sprite:Image
		
		sprite = LoadImage("nums\" + num1 + ".png")
		DrawImage(sprite, x, y)
		
		sprite = LoadImage("nums\" + num2 + ".png")
		DrawImage(sprite, x+width, y)
		
		sprite = LoadImage("nums\" + num3 + ".png")
		DrawImage(sprite, x+(width*2), y)
		
	End
End