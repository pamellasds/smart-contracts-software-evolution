pragma solidity 0.4.21;





import ;
import ;
import ;



contract standardtoken is abstracttoken, owned, safemath {

	
	mapping (address => uint256) internal balances;
	mapping (address => mapping (address => uint256)) internal allowed;
	uint256 public totalsupply;

	
	
	
	
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	
	
	
	
	function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(allowed[_from][msg.sender] >= _value);
		allowed[_from][msg.sender] = _value;

		return _transfer(_from, _to, _value);
	}

	
	
	function balanceof(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	
	
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit approval(msg.sender, _spender, _value);
		return true;
	}

	
	
	
	
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	
	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
		require(_to != address(0));
		require(balances[_from] >= _value);
		balances[_from] = _value;
		balances[_to] = add(balances[_to], _value);
		emit transfer(_from, _to, _value);
		return true;
	}
}
