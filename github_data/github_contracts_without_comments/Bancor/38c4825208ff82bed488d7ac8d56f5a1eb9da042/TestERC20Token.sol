pragma solidity ^0.4.23;
import ;


contract testerc20token is erc20token {
    constructor(string _name, string _symbol, uint256 _supply)
        public
        erc20token(_name, _symbol, 0)
    {
        totalsupply = _supply;
        balanceof[msg.sender] = _supply;
    }
}
