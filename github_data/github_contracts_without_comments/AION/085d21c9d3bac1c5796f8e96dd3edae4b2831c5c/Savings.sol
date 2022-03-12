
pragma solidity >=0.4.10;

contract token {
	function transferfrom(address from, address to, uint amount) returns(bool);
	function transfer(address to, uint amount) returns(bool);
	function balanceof(address addr) constant returns(uint);
}

import {owned} from ;


contract savings is owned {
	
	uint public periods;

	
	uint public t0special;

	uint constant public intervalsecs = 30 days;
	uint constant public precision = 10 ** 18;


	
	event withdraws(address indexed who, uint amount);
	event deposit(address indexed who, uint amount);

	bool public inited;
	bool public locked;
	uint public startblocktimestamp = 0;

	token public token;

	
	mapping (address => uint) public deposited;

	
	uint public totalfv;

	
	uint public remainder;

	
	uint public total;

	
	mapping (address => uint256) public withdrawn;

	bool public nullified;

	modifier notnullified() { require(!nullified); _; }

	modifier prelock() { require(!locked && startblocktimestamp == 0); _; }

	
	modifier postlock() { require(locked); _; }

	
	modifier prestart() { require(locked && startblocktimestamp == 0); _; }

	
	modifier poststart() { require(locked && startblocktimestamp != 0); _; }

	
	modifier notinitialized() { require(!inited); _; }

	
	modifier initialized() { require(inited); _; }

	
	function() {
		revert();
	}

	
	function nullify() onlyowner {
		nullified = true;
	}

	
	function init(uint _periods, uint _t0special) onlyowner notinitialized {
		require(_periods != 0);
		periods = _periods;
		t0special = _t0special;
	}

	function finalizeinit() onlyowner notinitialized {
		inited = true;
	}

	function settoken(address tok) onlyowner {
		token = token(tok);
	}

	
	function lock() onlyowner {
		locked = true;
	}

	
	function start(uint _startblocktimestamp) onlyowner initialized prestart {
		startblocktimestamp = _startblocktimestamp;
		uint256 tokenbalance = token.balanceof(this);
		total = tokenbalance;
		remainder = tokenbalance;
	}

	
	function isstarted() constant returns(bool) {
		return locked && startblocktimestamp != 0;
	}

	
	

	
	function refundtokens(address addr, uint amount) onlyowner prelock {
		token.transfer(addr, amount);
	}


	
	function updatetotal() onlyowner postlock {
		uint current = token.balanceof(this);
		require(current >= remainder); 

		uint difference = (current  remainder);
		total += difference;
		remainder = current;
	}

	
	function periodat(uint _blocktimestamp) constant returns(uint) {
		
		if (startblocktimestamp > _blocktimestamp)
			return 0;

		
		uint p = ((_blocktimestamp  startblocktimestamp) / intervalsecs) + 1;
		if (p > periods)
			p = periods;
		return p;
	}

	
	
	function period() constant returns(uint) {
		return periodat(block.timestamp);
	}

	
	
	
	function deposit(uint tokens) onlyowner notnullified {
		depositto(msg.sender, tokens);
	}


	function depositto(address beneficiary, uint tokens) onlyowner prelock notnullified {
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

	
	
	function withdraw() notnullified returns(bool) {
		return withdrawto(msg.sender);
	}

	
	function availableforwithdrawalat(uint256 blocktimestamp) constant returns (uint256) {
		
		return ((t0special + periodat(blocktimestamp)) * precision) / (t0special + periods);
	}

	
	function _withdrawto(uint _deposit, uint _withdrawn, uint _blocktimestamp, uint _total) constant returns (uint) {
		uint256 fraction = availableforwithdrawalat(_blocktimestamp);

		
		uint256 withdrawable = ((_deposit * fraction * _total) / totalfv) / precision;

		
		if (withdrawable > _withdrawn) {
			return withdrawable  _withdrawn;
		}
		return 0;
	}

	
	function withdrawto(address addr) poststart notnullified returns (bool) {
		uint _d = deposited[addr];
		uint _w = withdrawn[addr];

		uint diff = _withdrawto(_d, _w, block.timestamp, total);

		
		if (diff == 0) {
			return false;
		}

		
		require((diff + _w) <= ((_d * total) / totalfv));

		
		require(token.transfer(addr, diff));

		withdrawn[addr] += diff;
		remainder = diff;
		withdraws(addr, diff);
		return true;
	}

	
	function bulkwithdraw(address[] addrs) notnullified {
		for (uint i=0; i<addrs.length; i++)
			withdrawto(addrs[i]);
	}

	
	
	
	
	uint public mintingnonce;
	function multimint(uint nonce, uint256[] bits) onlyowner prelock {

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
