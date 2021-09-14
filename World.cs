using Godot;
using static Godot.GD;
using System;

public class World : TileMap
{
	private Vector2 Begin = Vector2(5, 10);
	private Vector2 End = Vector2(5, 0);

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		private Vector2 current = begin;
		while (current != end) {
			private Vector2 past_current = current;
			if (GD.Randi()%2 == 0) {
				if (End.y < Current.y) {
					Current.y--;
				} else {
					Current.y++;
				}
			} else if (End.x < Current.x) {
				Current.x--;
			} else {
				Current.x++;
			}
		}
		GD.Print(Current)
		
	}

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
