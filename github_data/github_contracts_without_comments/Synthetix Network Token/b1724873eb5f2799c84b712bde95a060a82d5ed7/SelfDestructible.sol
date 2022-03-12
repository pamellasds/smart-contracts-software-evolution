

pragma solidity 0.4.21;


import ;


contract selfdestructible is owned {
	
	uint public initiationtime = ~uint(0);
	uint constant sd_duration = 3 days;
	address public beneficiary;

	
	function selfdestructible(address _owner, address _beneficiary)
		public
		owned(_owner)
	{
		beneficiary = _beneficiary;
	}

	
	function setbeneficiary(address _beneficiary)
		external
		onlyowner
	{
		beneficiary = _beneficiary;
		emit selfdestructbeneficiaryupdated(_beneficiary);
	}

	
	function initiateselfdestruct()
		external
		onlyowner
	{
		initiationtime = now;
		emit selfdestructinitiated(sd_duration);
	}

	
	function terminateselfdestruct()
		external
		onlyowner
	{
		initiationtime = ~uint(0);
		emit selfdestructterminated();
	}

	
	function selfdestruct()
		external
		onlyowner
	{
		require(initiationtime + sd_duration < now);
		emit selfdestructed(beneficiary);
		selfdestruct(beneficiary);
	}

	event selfdestructbeneficiaryupdated(address newbeneficiary);

	event selfdestructinitiated(uint duration);

	event selfdestructterminated();

	event selfdestructed(address beneficiary);
}

