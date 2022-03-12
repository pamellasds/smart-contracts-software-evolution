pragma solidity ^0.4.23;


import ;


contract oneweeksetup is limitedsetup(1 weeks) {
	function testfunc() 
		public
		onlyduringsetup
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
