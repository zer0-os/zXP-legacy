pragma solidity ^0.8.0;

import "../../Owned.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BattleRoyale is Owned{
    uint256 land_wei_price = 1000000000000;
    uint256 unit_wei_price = 10000000000;
    uint256 unit_gold_price = 100000;
	uint256 blocks_per_round = 4000;
	uint256 deployed_at_block;
	uint256 public ending_balance;
	uint256 public pool_nom = 9;
	uint256 public pool_div = 10;

    uint8 max_upgrades = 3;
	uint8 public passable_threshold = 121;
	uint8 victory_threshold = 169;
	uint8 threshold_increment = 6;
	uint8 max_units = 99;
	uint32 total_victory_tiles_owned;
    uint32 treatyID;
	bool firstWithdraw = true;
	ERC20 wild;
    
    mapping(uint8 => mapping(uint8 => uint8)) public tile_development_level;
    mapping(uint8 => mapping(uint8 => address payable)) public tile_owner;
    mapping(uint8 => mapping(uint8 => uint8)) public units_on_tile;
    mapping(address => uint256) gold_balances;
    mapping(address => uint256) public gold_per_second;
	mapping(address => uint256) last_GPH_update_time;
	mapping(address => uint32) public victory_tiles_owned;
	mapping(address => bool) public withdrew;
	mapping(uint8 => mapping(uint8 => uint256)) market_price;

	constructor (ERC20 wildToken) public {
		deployed_at_block = block.number;
		wild = wildToken;
	}

    function set_land_wei_price(uint256 new_price) public ownerOnly {
        land_wei_price = new_price;
    }
    function set_unit_wei_price(uint256 new_price) public ownerOnly {
        unit_wei_price = new_price;
    }
    function set_unit_gold_price(uint256 new_price) public ownerOnly {
        unit_gold_price = new_price;
    }

	function dep() public view returns (uint256){
		return deployed_at_block;
	}

	function get_passable_threshold() public view returns(uint8){
		if((block.number - deployed_at_block)/blocks_per_round > 8){return victory_threshold;}
		return (passable_threshold + uint8((block.number - deployed_at_block)/blocks_per_round * threshold_increment));
	}

	function get_season_ended() public view returns(bool){
		return get_passable_threshold() >= victory_threshold;
	}
    
	function withdraw_winnings() public payable{
		require(get_season_ended(), 'Season hasnt ended');
		require(!withdrew[msg.sender], 'Already withdrew');
		if(firstWithdraw){
			firstWithdraw = false;
			ending_balance = address(this).balance;
		}
		withdrew[msg.sender] = true;
		msg.sender.transfer(get_winnings());
	}

	function get_winnings() public view returns(uint256){
		if(total_victory_tiles_owned == 0){ return 0; }
		if(ending_balance == 0){ return address(this).balance*pool_nom/pool_div * victory_tiles_owned[msg.sender] / total_victory_tiles_owned; }
		return ending_balance*pool_nom/pool_div * victory_tiles_owned[msg.sender] / total_victory_tiles_owned;
	}
	
	function RRaward(address payable a, uint256 amt) external {
	    //require(msg.sender == rraddress, 'sender wasnt ruined reign token address');
	    a.transfer(amt);
	}

	function get_pool_total() public view returns(uint256){
		if(get_season_ended()){ return ending_balance*pool_nom/pool_div; }
		return address(this).balance*pool_nom/pool_div;
	}

    function get_gold_value_of_tile(uint8 x, uint8 y) public view returns(uint8){
		if(tile_development_level[x][y] == 0){return uint8(10000/get_tile(x,y));}
        else{return uint8(60000/get_tile(x,y)) * tile_development_level[x][y];} //cityfactor = 6
    }
	function get_gold(address a) public view returns(uint){
		return gold_balances[a] + gold_per_second[a]*(block.timestamp - last_GPH_update_time[a]);
	}
	function get_land_price(uint8 x, uint8 y) public view returns(uint256){
		return land_wei_price * uint256(get_tile(x, y)) * uint256(get_tile(x,y));
	}
	function get_unit_price(uint8 x, uint8 y) public view returns(uint256){
		return unit_wei_price * uint256(get_tile(x, y)) * uint256(get_tile(x,y));
	}
	function get_height(uint8 x, uint8 y) public view returns(uint8){
		return 1 + (uint8(get_tile(x, y)) - passable_threshold)/threshold_increment;
	}

	function market_sell(uint8 x, uint8 y, uint256 price) public {
		require(!get_season_ended(), 'Season has ended');
		require(tile_owner[x][y] == msg.sender, 'Sender isnt owner');
		require(get_tile(x, y) > get_passable_threshold(), 'Tile impassable');
		require(price > 0, 'Invalid price');
		market_price[x][y] = price;
		emit Market_Posted(x, y, msg.sender, price);
	}

	function market_buy(uint8 x, uint8 y) public payable{
		require(!get_season_ended(), 'Season has ended');
		require(market_price[x][y] != 0, 'Land not for sale');
		require(msg.value == market_price[x][y], 'Invalid purchase price');
		address payable seller = tile_owner[x][y];
		market_price[x][y] = 0;
		if(get_tile(x, y) > victory_threshold){
			victory_tiles_owned[msg.sender]++; //overflow not possible
			victory_tiles_owned[seller]--; //underflow not possible
		}
		tile_owner[x][y] = msg.sender;
		seller.transfer(msg.value);
		emit Market_Bought(x, y, msg.sender);
	}

    function buy_land_with_wei(uint8 tile_x, uint8 tile_y, uint8 unit_count, uint8 dev_lev) public payable {
		require(!get_season_ended(), 'Season has ended');
        require(msg.value == get_land_price(tile_x, tile_y)*dev_lev + unit_count*get_unit_price(tile_x, tile_y), 'Invalid payment');
        require(tile_owner[tile_x][tile_y] == address(0) || tile_owner[tile_x][tile_y] == msg.sender, 'Tile already owned');
		require(get_tile(tile_x, tile_y) > get_passable_threshold(), 'Tile impassable');
		require(get_tile(tile_x, tile_y) <= get_passable_threshold() + threshold_increment, 'Tile inland'); 
		require(units_on_tile[tile_x][tile_y] + unit_count <= max_units, 'Buying too many units');
		require(unit_count >= 1, 'Buying too few units');
		require(dev_lev <= max_upgrades, 'Development level over max');
		
		tile_development_level[tile_x][tile_y] = dev_lev;
		gold_balances[msg.sender] = get_gold(msg.sender);
        gold_per_second[msg.sender] += get_gold_value_of_tile(tile_x, tile_y);
		last_GPH_update_time[msg.sender] = block.timestamp;
        tile_owner[tile_x][tile_y] = msg.sender;
        units_on_tile[tile_x][tile_y] = unit_count;

        emit Land_Bought(tile_x, tile_y, msg.sender, units_on_tile[tile_x][tile_y], dev_lev);
    }
    function buy_units_with_wei(uint8 tile_x, uint8 tile_y, uint8 unit_count) public payable {
		require(!get_season_ended(), 'Season has ended');
        require(msg.value >= get_unit_price(tile_x, tile_y) * unit_count, 'Insufficient payment');
        require(tile_owner[tile_x][tile_y] == address(msg.sender), 'Sender isnt owner');
		require(tile_development_level[tile_x][tile_y] > 0, 'Tile isnt colonized');
		require(units_on_tile[tile_x][tile_y] + unit_count <= max_units, 'Sum over max units');
		require(units_on_tile[tile_x][tile_y] + unit_count > units_on_tile[tile_x][tile_y], 'Units zero or overflow');

        units_on_tile[tile_x][tile_y] += unit_count;
		emit New_Population(tile_x, tile_y, units_on_tile[tile_x][tile_y]);
    }
    function buy_units_with_gold(uint8 tile_x, uint8 tile_y, uint8 unit_count) public {
		require(!get_season_ended(), 'Season has ended');
        require(tile_owner[tile_x][tile_y] == address(msg.sender), 'Sender isnt owner');
        require(get_gold(msg.sender) >= (unit_gold_price*unit_count), 'Insufficient gold');
		require(tile_development_level[tile_x][tile_y] > 0, 'Tile isnt colonized');
		require(unit_count <= max_units, 'Buying too many units');
		require(units_on_tile[tile_x][tile_y] + unit_count <= max_units, 'Sum over max units');
		require(units_on_tile[tile_x][tile_y] + unit_count > units_on_tile[tile_x][tile_y], 'Units zero or overflow');

		last_GPH_update_time[msg.sender] = block.timestamp;
        gold_balances[msg.sender] = get_gold(msg.sender) - unit_gold_price*unit_count;
        units_on_tile[tile_x][tile_y] += unit_count;
		emit New_Population(tile_x, tile_y, units_on_tile[tile_x][tile_y]);
    }

    function transfer_gold(address to, uint256 gold) public {
        //TODO: overflow check here
        require(gold_balances[msg.sender] >= gold, 'Insufficient gold');
        gold_balances[msg.sender] -= gold;
        gold_balances[to] += gold;
		emit Gold_Transferred(msg.sender, to, gold);
    }

    function transfer_land(uint8 tile_x, uint8 tile_y, address payable new_address) public {
        require(tile_owner[tile_x][tile_y] == msg.sender);
		require(!get_season_ended(), 'Season has ended');
		if(get_tile(tile_x, tile_y) > victory_threshold){
			victory_tiles_owned[msg.sender]--; //overflow not possible
			victory_tiles_owned[new_address]++; //underflow not possible
		}
		market_price[tile_x][tile_y] = 0;
        tile_owner[tile_x][tile_y] = new_address;
        emit Land_Transferred(tile_x, tile_y, msg.sender);
    }

    function move(uint8 x_from, uint8 y_from, uint8 x_to, uint8 y_to, uint8 units) public {
		require(units > 0, 'Moving zero units');
		require(!get_season_ended(), 'Season has ended');
        require(tile_owner[x_from][y_from] == msg.sender, 'Sender doesnt own from tile');
        require(units_on_tile[x_from][y_from] - 1 >= units, 'Moving too many units'); //attacker must leave one unit in from tile
        require(get_tile(x_to, y_to) > get_passable_threshold(), 'Tile impassable');
		if(y_from % 2 == 0)
		{
			require((y_to == y_from + 1 && x_to == x_from) || 
					(y_to == y_from - 1 && x_to == x_from) ||
					(y_to == y_from && x_to == x_from + 1) ||
					(y_to == y_from && x_to == x_from - 1) ||
					(y_to == y_from + 1 && x_to == x_from - 1) ||
					(y_to == y_from - 1 && x_to == x_from - 1), 'Tile not adjacent');
		}
		else
		{
			require((y_to == y_from + 1 && x_to == x_from) || 
						(y_to == y_from - 1 && x_to == x_from) ||
						(y_to == y_from && x_to == x_from + 1) ||
						(y_to == y_from && x_to == x_from - 1) ||
						(y_to == y_from + 1 && x_to == x_from + 1) ||
						(y_to == y_from - 1 && x_to == x_from + 1), 'Tile not adjacent');
		}

		if(tile_owner[x_to][y_to] == address (0x00)){
				units_on_tile[x_from][y_from] -= units;
				units_on_tile[x_to][y_to] = units;
				tile_owner[x_to][y_to] = msg.sender;

				if(get_tile(x_to, y_to) > victory_threshold){
					total_victory_tiles_owned++;
					victory_tiles_owned[msg.sender]++;
				}
				gold_balances[msg.sender] = get_gold(msg.sender);
				gold_per_second[msg.sender] += get_gold_value_of_tile(x_to,y_to);
				last_GPH_update_time[msg.sender] = block.timestamp;

				emit Land_Transferred(x_to, y_to, msg.sender);
			}
        else if(tile_owner[x_to][y_to] == msg.sender){
			require(units_on_tile[x_to][y_to] + units <= max_units, 'Moving too many units');
            require(units_on_tile[x_to][y_to] + units > units_on_tile[x_to][y_to], 'Units overflow, or sent zero');
			units_on_tile[x_from][y_from] -= units;
            units_on_tile[x_to][y_to] += units;
        }
        else {			 
            //battle
			if(tile_development_level[x_to][y_to] > 0){
				if(units/tile_development_level[x_to][y_to] == units_on_tile[x_to][y_to]) { 
					//defender advantage
					units_on_tile[x_to][y_to] = 1;
					units_on_tile[x_from][y_from] -= units;
				}
				else if(units/tile_development_level[x_to][y_to] > units_on_tile[x_to][y_to]){
					units_on_tile[x_to][y_to] = units - units_on_tile[x_to][y_to]*tile_development_level[x_to][y_to];
					units_on_tile[x_from][y_from] -= units;

					if(get_tile(x_to, y_to) > victory_threshold){
						victory_tiles_owned[msg.sender]++; //overflow not possible
						victory_tiles_owned[tile_owner[x_to][y_to]]--; //underflow not possible
					}

					gold_balances[tile_owner[x_to][y_to]] = get_gold(msg.sender);
					gold_per_second[tile_owner[x_to][y_to]] -= get_gold_value_of_tile(x_to,y_to);
					last_GPH_update_time[tile_owner[x_to][y_to]] = block.timestamp;
				
					tile_development_level[x_to][y_to] = 0;
					market_price[x_to][y_to] = 0;

					gold_balances[msg.sender] = get_gold(msg.sender);
					gold_per_second[msg.sender] += get_gold_value_of_tile(x_to,y_to);
					last_GPH_update_time[msg.sender] = block.timestamp;

					tile_owner[x_to][y_to] = msg.sender;
					emit Land_Transferred(x_to, y_to, msg.sender);
				}else{
					units_on_tile[x_to][y_to] -= units/tile_development_level[x_to][y_to];
					units_on_tile[x_from][y_from] -= units;
				}
			}else{
				if(units == units_on_tile[x_to][y_to]) { 
					//defender advantage
					units_on_tile[x_to][y_to] = 1;
					units_on_tile[x_from][y_from] -= units;
				}
				else if(units > units_on_tile[x_to][y_to]){
					units_on_tile[x_to][y_to] = units - units_on_tile[x_to][y_to];
					units_on_tile[x_from][y_from] -= units;

					if(get_tile(x_to, y_to) > victory_threshold){
						victory_tiles_owned[msg.sender]++; //overflow not possible
						victory_tiles_owned[tile_owner[x_to][y_to]]--; //underflow not possible
					}

					gold_balances[tile_owner[x_to][y_to]] = get_gold(msg.sender);
					gold_per_second[tile_owner[x_to][y_to]] -= get_gold_value_of_tile(x_to,y_to);
					last_GPH_update_time[tile_owner[x_to][y_to]] = block.timestamp;
				
					tile_development_level[x_to][y_to] = 0;
					market_price[x_to][y_to] = 0;

					gold_balances[msg.sender] = get_gold(msg.sender);
					gold_per_second[msg.sender] += get_gold_value_of_tile(x_to,y_to);
					last_GPH_update_time[msg.sender] = block.timestamp;

					tile_owner[x_to][y_to] = msg.sender;
					emit Land_Transferred(x_to, y_to, msg.sender);
				}else{
					units_on_tile[x_to][y_to] -= units;
					units_on_tile[x_from][y_from] -= units;
				}
			}
		}
        emit New_Population(x_from, y_from, units_on_tile[x_from][y_from]);
        emit New_Population(x_to, y_to, units_on_tile[x_to][y_to]);
    }

	//noise
	int64 constant max = 256;
    function integer_noise(int64 n) public pure returns(int64) {
        n = (n >> 13) ^ n;
        int64 nn = (n * (n * n * 60493 + 19990303) + 1376312589) & 0x7fffffff;
        return ((((nn * 100000)) / (1073741824)))%max;
    }

    function local_average_noise(uint8 x, uint8 y) public pure returns(int64) {
        int64 xq = x + ((y-x)/3);
        int64 yq = y - ((x+y)/3);

        int64 result =
        ((integer_noise(xq) + integer_noise(yq-1))) //uc
        +   ((integer_noise(xq-1) + integer_noise(yq))) //cl
        +   ((integer_noise(xq+1) + integer_noise(yq))) //cr
        +   ((integer_noise(xq) + integer_noise(yq+1))); //lc

        return result*1000/8;
    }

    int64 constant iterations = 5;

    function stacked_squares(uint8 x, uint8 y) public pure returns(int64) {

        int64 accumulator;
        for(int64 iteration_idx = 0; iteration_idx < iterations; iteration_idx++){
            accumulator +=  integer_noise((x * iteration_idx) + accumulator + y) +
            integer_noise((y * iteration_idx) + accumulator - x);
        }

        return accumulator*1000/(iterations*2);

    }

    function get_tile(uint8 x, uint8 y) public pure returns (int64) {
        return (local_average_noise(x/4,y/7) + stacked_squares(x/25,y/42))/2000;
    }

	event Land_Bought(uint8 indexed x, uint8 indexed y, address indexed new_owner, uint16 new_population, uint8 development_level);
    event Land_Transferred(uint8 indexed x, uint8 indexed y, address indexed new_owner);
	event Gold_Transferred(address from, address to, uint gold);
    event New_Population(uint8 indexed x, uint8 indexed y, uint16 new_population);	
	event Market_Posted(uint8 indexed x, uint8 indexed y, address indexed poster, uint256 price);
	event Market_Bought(uint8 indexed x, uint8 indexed y, address indexed buyer);
}