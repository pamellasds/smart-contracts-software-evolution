pragma solidity 0.4.26;
import ;


contract testnonstandarderc20token is nonstandarderc20token {
    constructor(string _name, string _symbol, uint256 _supply)
        public
        nonstandarderc20token(_name, _symbol, 0)
    {
        totalsupply = _supply;
        balanceof[msg.sender] = _supply;
    }
}
