pragma solidity 0.4.26;


contract inonstandarderc20 {
    
    function name() public view returns (string) {}
    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}
    function totalsupply() public view returns (uint256) {}
    function balanceof(address _owner) public view returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public;
    function transferfrom(address _from, address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
}
