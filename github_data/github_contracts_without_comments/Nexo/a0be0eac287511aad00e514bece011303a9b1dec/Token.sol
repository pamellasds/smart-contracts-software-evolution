pragma solidity 0.4.21;





import ;




contract token is standardtoken {

	
	uint256 public creationtime;

	function token() public {
		
		creationtime = now;
	}

	
	function transfererc20token(abstracttoken _token, address _to, uint256 _value)
		public
		onlyowner
		returns (bool success)
	{
		require(_token.balanceof(address(this)) >= _value);
		uint256 receiverbalance = _token.balanceof(_to);
		require(_token.transfer(_to, _value));

		uint256 receivernewbalance = _token.balanceof(_to);
		assert(receivernewbalance == add(receiverbalance, _value));

		return true;
	}

	
	function increaseapproval(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _value);
		emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	
	function decreaseapproval(address _spender, uint256 _value) public returns (bool success) {
		uint256 oldvalue = allowed[msg.sender][_spender];
		if (_value > oldvalue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = sub(oldvalue, _value);
		}
		emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}
