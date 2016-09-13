
//// Easy Handles
Log <- GSLog.Info;
E <- GSLog.Error;

//// Load version
require("version.nut");
//// Load industry table
require("industry_list.nut");
//// Load town names
require("town_list.nut");
//// Load Tiles library, for rand tile selection
require("tile.nut");
//// Load player class for keeping track of players cities and other player related stuff
require("player.nut");


class Builder extends GSController 
{	
	isComplete = null;
	gPlayers = null;
	gTowns = null;
	gTownIndustries = null;
	gTownNames = null;
	players = null;
	constructor() {
		this.isComplete = false;
		this.gPlayers = GSController.GetSetting("number_of_players");
		this.gTowns = GSController.GetSetting("number_of_towns");
		this.gTownIndustries = GSController.GetSetting("max_town_industries");
		this.gTownNames = TownNames;
		players = []; for(local p=1; p<=this.gPlayers; p++) players.append(Player());
	}
}
function Builder::Start()
{
	Log("Builder has begun!");
	if (this.isComplete == false) {	
		GSGame.Pause();			//Pause game while GS is building the map.
		this.Init();		// running some basic settings and other necessary stuff.. dont change this.
		this.RunOnce();		// Building the towns and industries, assigning evenly between players. (the actual things we want to make with this script)
		GSGame.Unpause();
	}
	else if (this.isComplete == true) Log("Script has already been run!");
	Log("Builder has finished!");
	while (true)
	{
		this.Sleep(6000);
	}
}

function Builder::Init()
{	
	this.ChangeSetting("construction.command_pause_level", 3); // Make it possible to build while game is pause.
	this.ResetRandom();
	this.gTownNames = this.Randomize(this.gTownNames);
}


/// SAVE and LOAD
function Builder::Save()
{
	local save_table = {};
	save_table.scriptComplete <- this.isComplete;
	Log("Saving game state");
	return save_table;
}
function Builder::Load(version, data)
{
	Log("Loading game state");
	if (data.rawin("scriptComplete")) {
		this.isComplete = data.rawget("scriptComplete");
	}
}

//// RunOnce() makes sure that the script won't be run everytime the game loads.
function Builder::RunOnce(){
	while(!this.isComplete){
		// Make all towns for all players
			//this.MakeTowns();
		this.Test();
		
			//local indu = Industries();
		
		// Builing industries
		local testbuilding = {no = 1, dx = 5, dy = 10, ltype = 0, id = 9}; // (aluminumplant)
		//this.BuildIndustry(testbuilding);
		
		// Setting industry signs
			//foreach(i,v in indu.norm) this.SetSigns(GSIndustryType.GetName(v["id"]), v["no"]); // Signing all normal industries
			//foreach(i,v in indu.water) this.SetSigns(GSIndustryType.GetName(v["id"]), v["no"], false); // Signing all sea industries
			//this.SetTownSigns();

		this.isComplete = true;
	}
}

function Builder::Test()
{
	local area = GSTileList();
	area.AddRectangle(6460,6847);
	Log(area.Count());
	Log(GSTile.LevelTiles(6460,6847));
	Tile.LevelArea(area);
}




//// MakeTown2 creates a town at random location.
function Builder::MakeTowns()
{
	for(local i=0;i<this.gTowns;i++){	// cycle through a number of cities. This order, with cities over playes, gives a more even dstribution, compared to players over cities
		for(local p=1; p<=this.gPlayers; p++){	// cycle through players
			local isTownFounded = false;
			while (!isTownFounded) {
				local tile = Tile().RandLand();
				if (GSTown.FoundTown(tile, 0, false, 1, 0))
				{
					// Assigning player number to town name
					local town_id = GSTown.GetTownCount()-1;
					local town_name = this.gTownNames.pop(); //Rename from custom town names list
					local new_name = p + " - " + town_name;
					GSTown.SetName(town_id,new_name);
					// Add the city to the town index reference on the players city
					Log(town_id);
					this.players[p-1].AddTown(town_id);

					Log("Town " + new_name + " founded at location " + tile);
					break;
				}
				else {E("Town not founded at location " + tile + ", trying new location...");}
			}
		}
	}
}


function Builder::BuildIndustry(industry)
{


	/// Get random landtile
	//local tile = Tile().RandLand();
	local tile = GSMap.GetTileIndex(62,55);
	Log(tile);
	//// find end tile
	local endtile = Tile.Neighbour(tile,2,2);


	//Log(leveling);

	/// Switch to company 0

	//local cm = GSCompanyMode(0);
	//cm.GSCompanyMode(0);

	Log("Switched to company " + GSCompany.GetName(0));
	this.MoneySetBalance(1000000000);
	/// Level tiles so land is buildable.
	Log("Leveling tiles at " + GSMap.GetTileX(tile) + ", " + GSMap.GetTileY(tile));
	this.Sleep(10);
	local level = GSTile.LevelTiles(tile, endtile);
	Log(level)
	if(level){Log("Tiles leveled")}
	else{ E("Failed leveling tiles!")}
	/// Build Industry
	GSIndustryType.BuildIndustry(industry["id"],tile);
	Log("Building " + GSIndustryType.GetName(industry["id"]));
}




//// Functions for making signs.
function Builder::SetTownSigns()
{
	for(local p=1; p<=this.gPlayers; p++){
		local ilist_temp = Industries().town;
		// Remove Recycle depot from list (idx 0) and set Recycle depot sign in all towns
		Log(ilist_temp[0]["id"]);
		ilist_temp.remove(0);
		local ptown_tables = this.players[p-1].towns;
		foreach(i,town in ptown_tables){
			local tile = GSTown.GetLocation(town["town_id"]);
			local text = "Town - Recycling Depot";
			this.SetSign(text, tile);
		}
		// For each industry, pull random town belonging to player and sign that industry to the city.
		// Subtract 1 from the  count in ilist_temp for that industry.
		// Do this as long as the count > 0;			//cycle industries
		while(ilist_temp.len()>0){
			local current_industry = ilist_temp.pop();
			while(current_industry["no"] > 0){
				local rand_idx = GSBase.RandRange(ptown_tables.len()); // find random town

				if(ptown_tables[rand_idx].industries.len() < this.gTownIndustries){ // check if town has max number of industries already
					local its_a_dupe = false;
					foreach(i,indu_id in ptown_tables[rand_idx].industries){ // cylces industries already in town
						if(current_industry["id"] == indu_id) its_a_dupe = true;	// check if industry already exists in town.
					}
					if (its_a_dupe==false){		// if industry not already in town, add industry to town
						ptown_tables[rand_idx].industries.append(current_industry["id"]);	// adds industry to town to keep track of industries in every town
						this.players[p-1].towns = ptown_tables;				// update the town industry list for this current player
						local tile = GSTown.GetLocation(ptown_tables[rand_idx].town_id);	// plant sign
						tile = Tile().Neighbour(tile,ptown_tables[rand_idx].industries.len(), ptown_tables[rand_idx].industries.len());
						local text = "Town - " + GSIndustryType.GetName(current_industry["id"]);	// plant sign
						this.SetSign(text, tile);	// plant sign
						current_industry["no"]--;	// subtract from counter, so we only put desired amount of this industry on the map
					}
				}
			}
		}
		Log("Player"+p+" has towns: "+ ptown_tables.len());
		foreach(i,table in ptown_tables) Log(GSTown.GetName(table["town_id"]) + " has " + (table.industries.len()+1)  + " industries");
	}
	return;
}



//// SetSigns() can put a select amount of signs at different random locations. landtile defines if
//// the tile is land or water; set to true for land, false for water
function Builder::SetSigns(text, amount, landtile = true)
{
	local tile = 512;
	for(local i=0; i<amount; i++)
	{
		for(local n=1; n<=this.gPlayers; n++)
		{
			local text = n + " - " + text;
			do{
				if (landtile == true){ tile = Tile().RandLand()}
				else { tile = Tile().RandWater()}
			}
			while(!(this.SetSign(text, tile)));
		}
	}
}
//// SetSign() puts a single sign with text [text] and tile [tile]. Fucntion is used by SetSigns() to put
//// several signs at random location at once.
function Builder::SetSign(text, tile)
{
	//local text = GSIndustryType.GetName(type.id)
	if (GSSign.IsValidSign(GSSign.BuildSign(tile, text)))
		{ Log("Sign planted: '" + text + "', " + GSMap.GetTileX(tile) + ", " + GSMap.GetTileY(tile)) + ", " + tile;
		  return true;}
	else 
		{ E("Couldn't plant sign '" + text + "', "  + GSMap.GetTileX(tile) + ", " + GSMap.GetTileY(tile)) + ", " + tile;
		  return false}	
}

///////////////////////////////////
//// Make sure the random generator won't start at same point every time you load at same save point.
function Builder::ResetRandom()
{
	local systime0 = GSDate.GetSystemTime();
	local skip = systime0 % 997;
	//Log("Skipping " + skip + " random calls!");
	for(local i=0; i<skip; i++){GSBase.RandRangeItem(0,1024);}
	local timecount = GSDate.GetSystemTime() - systime0;
	Log("Skipped " + skip + " random calls in " + timecount + " seconds!");
}

//////////////////////////////
// Randomize a list
function Builder::Randomize(old_list)
{
	local new_list = [];
	while(old_list.len()>0)
	{
		local i = GSBase.RandRange(old_list.len());
		new_list.append(old_list[i]);
		old_list.remove(i);
	}
	return new_list;
}


//////////////////////////////
// Shorten the process of handling settings.
function Builder::ChangeSetting(setting, value)
{
	if (GSGameSettings.IsValid(setting))
	{
		GSGameSettings.SetValue(setting, value);
		return true;
	}
	else{ E("Somthing went wrong.. please contact developer!");return false;}
}

// Change current balance to desired absolute value, compared to built-in relative change.
function Builder::MoneySetBalance(new_balance)
{
	local balance = GSCompany.GetBankBalance(GSCompany.COMPANY_FIRST);
	//local loan = GSCompany.GetLoanAmount();
	local money_diff = new_balance - balance;
	GSCompany.ChangeBankBalance(GSCompany.COMPANY_FIRST, money_diff, GSCompany.EXPENSES_TRAIN_INC);
}