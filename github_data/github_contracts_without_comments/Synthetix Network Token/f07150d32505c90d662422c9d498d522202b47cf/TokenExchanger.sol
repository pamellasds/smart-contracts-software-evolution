
pragma solidity 0.4.25;

import ;
import ;
import ;
import ;

contract tokenexchanger is owned {

    address public integrationproxy;
    address public synthetix;

    constructor(address _owner, address _integrationproxy)
        owned(_owner)
        public
    {
        integrationproxy = _integrationproxy;
    }

    function setsynthetixproxy(address _integrationproxy)
        external
        onlyowner
    {
        integrationproxy = _integrationproxy;
    }

    function setsynthetix(address _synthetix)
        external
        onlyowner
    {
        synthetix = _synthetix;
    }

    function checkbalance(address account)
        public
        view
        synthetixproxyisset
        returns (uint)
    {
        return ierc20(integrationproxy).balanceof(account);
    }

    function checkallowance(address tokenowner, address spender)
        public
        view
        synthetixproxyisset
        returns (uint)
    {
        return ierc20(integrationproxy).allowance(tokenowner, spender);
    }

    function checkbalancesnxdirect(address account)
        public
        view
        synthetixproxyisset
        returns (uint)
    {
        return ierc20(synthetix).balanceof(account);
    }

    function getdecimals(address tokenaddress)
        public
        view
        returns (uint)
    {
        return ierc20(tokenaddress).decimals();
    }

    function dotokenspend(address fromaccount, address toaccount, uint amount)
        public
        synthetixproxyisset
        returns (bool)
    {
        
        require(checkbalance(fromaccount) >= amount, );

        
        require(checkallowance(fromaccount, address(this)) >= amount, );

        
        return ierc20(integrationproxy).transferfrom(fromaccount, toaccount, amount);
    }

    modifier synthetixproxyisset {
        require(integrationproxy != address(0), );
        _;
    }

    event logstring(string name, string value);
    event logint(string name, uint value);
    event logaddress(string name, address value);
    event logbytes(string name, bytes4 value);
}
