pragma solidity 0.4.21;






contract owned {

	address public owner = msg.sender;
	address public potentialowner;

	modifier onlyowner {
		require(msg.sender == owner);
		_;
	}

	modifier onlypotentialowner {
		require(msg.sender == potentialowner);
		_;
	}

	event newowner(address old, address current);
	event newpotentialowner(address old, address potential);

	function setowner(address _new)
		public
		onlyowner
	{
		emit newpotentialowner(owner, _new);
		potentialowner = _new;
	}

	function confirmownership()
		public
		onlypotentialowner
	{
		emit newowner(owner, potentialowner);
		owner = potentialowner;
		potentialowner = address(0);
	}
}
