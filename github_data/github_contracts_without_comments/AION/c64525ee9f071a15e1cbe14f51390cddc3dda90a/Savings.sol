

pragma solidity >=0.4.10;

contract token {
	function transferfrom(address from, address to, uint amount) returns(bool);
	function transfer(address to, uint amount) returns(bool);
	function balanceof(address addr) constant returns(uint);
}








contract savings {
	
	uint constant public periods = 36;
	
	
	
	uint constant public t0special = 12;
	uint constant public interval = 10;  

	event deposit(address indexed who, uint amount);

	address public owner;
	address public newowner;

	bool public locked;
	uint public startblock;

	token public token;

	
	mapping (address => uint) public deposited;

	
	uint public totalfv;

	
	uint public total;

	
	mapping (address => uint8) public withdrawals;

	function savings() {
		assert(t0special > 0);
		assert(periods > 0);
		owner = msg.sender;
	}

	modifier onlyowner() {
		require(msg.sender == owner);
		_;
	}

	function changeowner(address addr) onlyowner {
		newowner = addr;
	}

	function acceptownership() {
		require(msg.sender == newowner);
		owner = newowner;
	}

	function settoken(address tok) onlyowner {
		token = token(tok);
	}

	
	
	function lock() onlyowner {
		locked = true;
	}

	
	
	
	
	function start(uint blockdelta) onlyowner {
		assert(locked && startblock == 0);
		startblock = block.number + blockdelta;
		total = token.balanceof(this);
	}

	
	
	function sendtokens(address addr, uint amount) onlyowner {
		require(startblock == 0);
		token.transfer(addr, amount);
	}

	function () {
		revert();
	}

	
	
	function period() constant returns(uint) {
		require(startblock != 0);

		
		if (startblock > block.number)
			return 0;

		uint p = (block.number  startblock) / interval;
		if (p >= periods)
			p = periods1;
		return p;
	}

	
	
	
	function deposit(uint tokens) {
		depositto(msg.sender, tokens);
	}


	
	function depositto(address beneficiary, uint tokens) {
		require(!locked);
		require(token.transferfrom(msg.sender, this, tokens));
	    deposited[beneficiary] += tokens;
		totalfv += tokens;
		deposit(beneficiary, tokens);
	}

	
	function bulkdepositto(uint256[] bits) onlyowner {
		uint256 lomask = (1 << 96)  1;
		for (uint i=0; i<bits.length; i++) {
			address a = address(bits[i]>>96);
			uint val = bits[i]&lomask;
			depositto(a, val);
		}
	}

	
	
	function withdraw() returns(bool) {
		return withdrawto(msg.sender);
	}

	function withdrawto(address addr) returns(bool) {
		if (!locked || startblock == 0)
			return false; 

		uint b = total;
		uint d = totalfv;
		uint p = period();
		uint8 w = withdrawals[addr];

		
		
		if (w > (p + 1) || w >= (periods + 1))
			return false;

		
		
		if (w == 1 && (block.number < startblock))
			return false;

		
		
		
		
		
		
		
		
		
		assert(b >= d);
		uint owed = (deposited[addr] * b) / d;

		uint special = 0;
		if (w == 0) {
			special = t0special;
			w = 1;
		}

		
		
		uint ps = 2 + p  w;
		
		if (block.number < startblock) {
			ps = 0;
		}

		
		
		
		uint amount = ((ps + special) * owed) / (t0special + periods);

		withdrawals[addr] = w + uint8(ps);
		require(token.transfer(addr, amount));
		return true;
	}

	
	function bulkwithdraw(address[] addrs) {
		for (uint i=0; i<addrs.length; i++)
			withdrawto(addrs[i]);
	}

	
	
	
	
	uint public mintingnonce;
	function multimint(uint nonce, uint256[] bits) onlyowner {
		require(startblock == 0); 
		if (nonce != mintingnonce) return;
		mintingnonce += 1;
		uint256 lomask = (1 << 96)  1;
		uint sum = 0;
		for (uint i=0; i<bits.length; i++) {
			address a = address(bits[i]>>96);
			uint value = bits[i]&lomask;
			deposited[a] += value;
			sum += value;
			deposit(a, value);
		}
		totalfv += sum;
	}

}
