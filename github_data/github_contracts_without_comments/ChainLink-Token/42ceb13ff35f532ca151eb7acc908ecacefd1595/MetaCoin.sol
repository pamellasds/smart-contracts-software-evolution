pragma solidity ^0.4.4;

import ;






contract metacoin {
	mapping (address => uint) balances;

	event transfer(address indexed _from, address indexed _to, uint256 _value);

	function metacoin() {
		balances[tx.origin] = 10000;
	}

	function sendcoin(address receiver, uint amount) returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] = amount;
		balances[receiver] += amount;
		transfer(msg.sender, receiver, amount);
		return true;
	}

	function getbalanceineth(address addr) returns(uint){
		return convertlib.convert(getbalance(addr),2);
	}

	function getbalance(address addr) returns(uint) {
		return balances[addr];
	}
}
