pragma solidity ^0.4.4;

library convertlib{
	function convert(uint amount,uint conversionrate) returns (uint convertedamount)
	{
		return amount * conversionrate;
	}
}
