


class Tile
{
	constructor(){}
}

//////////////////////////
//// Functions for random tiles.
function Tile::RandWater()  // Water tile
{
	local tile = 0;
	do{ tile = this.Rand()}
	while(!GSTile.IsWaterTile(tile));
	return tile;
}

function Tile::RandLand() // Land tile
{
	local tile = 0;
	do{ tile = this.Rand()}
	while(GSTile.IsWaterTile(tile));
	return tile;
}

function Tile::Rand() // Any random tile
{
	local mapsize = GSMap.GetMapSize();
	local tile = GSBase.RandRange(mapsize) -1;
	return tile;
}

function Tile::Neighbour(current, dx, dy) // find tile idx for tile dx, dy distance from current tile
{
	local x = GSMap.GetTileX(current);
	local y = GSMap.GetTileY(current);
	local new_tile = GSMap.GetTileIndex(x+dx, y+dy);
	return new_tile;
}

function Tile::LevelArea(tilelist)
{

	local slope = GSTile.Slope("SLOPE_SEN");
	Log(slope);
	local tile_list_copy = tilelist;
	local height_count = 0;
	foreach(idx, val in tilelist)
	{
		Log(idx + ", " + GSTile.GetMinHeight(idx) + ", " + GSTile.GetMaxHeight(idx));
		height_count += (GSTile.GetMinHeight(idx) + GSTile.GetMaxHeight(idx));
	}
	Log(height_count);
	local avg_height = height_count/2/tilelist.Count();
	Log("avg height " + avg_height);
	local corners = [GSTile.CORNER_W, GSTile.CORNER_S, GSTile.CORNER_E, GSTile.CORNER_N];
	foreach(tidx, tval in tilelist)
	{
		local slope = GSTile.GetSlope(tidx);
		Log(slope);
		Log(GSTile.GetComplementSlope(slope));
		Log("--");

/*
		foreach(cidx,cval in corners)
		{
			local corner_height = GSTile.GetCornerHeight(tidx, cval);
			Log(GSTile.GetSlope(tidx));
			Log(corner_height);
			if(corner_height == avg_height){ Log("Corner height OK!")}
			else if(corner_height < avg_height){Log("Corner needs raise"); GSTile.RaiseTile(tidx, GSTile.GetComplementSlope(tidx))}
			else if(corner_height > avg_height){Log("Corner needs lowering")}


			else (Log("Corner needs adjustments)"));
		}
		*/
	}
}







////////////////////////////////////////////////////////
//// Standby
function Tile::Area(tile1, tile2)  // create a list of tiles belonging to a rectangular area
{
	local area = GSTileList();
	local x1 = GSMap.GetTileX(tile1);
	local y1 = GSMap.GetTileX(tile1);
	local x2 = GSMap.GetTileX(tile2);
	local y2 = GSMap.GetTileX(tile2);
	for(local x=x1; x<=x2; x++)
	{
		for(local y=y1; y<=y2; y++)
		{
			local tileidx = GSMap.GetTileIndex(x,y);
			//area.append
		}
	}
	return area;
}