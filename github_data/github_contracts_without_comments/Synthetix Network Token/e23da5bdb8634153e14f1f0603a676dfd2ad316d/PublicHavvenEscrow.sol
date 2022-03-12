
pragma solidity ^0.4.20;


import ;
import ;


contract publichavvenescrow is havvenescrow {

	function publichavvenescrow(address _owner,
                                havven _havven)
		havvenescrow(_owner, _havven)
		public 
	{
		
		setupduration = 50000 weeks;
	}
}
