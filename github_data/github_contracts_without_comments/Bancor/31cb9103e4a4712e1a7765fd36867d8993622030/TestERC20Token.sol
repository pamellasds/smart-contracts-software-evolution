pragma solidity ^0.4.11;
import ;


contract testerc20token is erc20token {
    function testerc20token(string _name, string _symbol, uint256 _supply)
        public
        erc20token(_name, _symbol, 0)
    {
        totalsupply = _supply;
        balanceof[msg.sender] = _supply;
    }
}
