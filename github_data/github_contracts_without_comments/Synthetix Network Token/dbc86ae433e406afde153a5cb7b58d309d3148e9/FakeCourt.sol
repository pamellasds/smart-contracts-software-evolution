pragma solidity ^0.4.19;

import ;

contract fakecourt {
		ethernomin public nomin;

		mapping(address => bool) public confirming;
		mapping(address => bool) public votepasses;

		function setnomin(ethernomin newnomin)
			public
		{
			nomin = newnomin;
		}

		function setconfirming(address target, bool status)
			public
		{
			confirming[target] = status;
		}

		function setvotepasses(address target, bool status)
			public
		{
			votepasses[target] = status;
		}

		function confiscatebalance(address target)
			public
		{
			nomin.confiscatebalance(target);
		}
}
