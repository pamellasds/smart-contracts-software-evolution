pragma solidity ^0.4.21;


import ;


contract oneweeksetup is limitedsetup(1 weeks) {
	function testfunc() 
		public
		setupfunction
		returns (bool)
	{
		return true;
	}

	function publicsetupexpirytime()
		public
		returns (uint)
	{
		return setupexpirytime;
	}
}
