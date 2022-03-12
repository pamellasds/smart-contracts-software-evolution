pragma solidity ^0.4.19;


import ;


contract oneweeksetup is limitedsetup(1 weeks) {
	function testfunc() 
		public
		setupfunction
		returns (bool)
	{
		return true;
	}

	function publicconstructiontime()
		public
		returns (uint)
	{
		return constructiontime;
	}

	function publicsetupduration()
		public
		returns (uint)
	{
		return setupduration;
	}
}
