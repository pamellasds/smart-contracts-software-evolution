pragma solidity 0.4.24;


interface erc20 {
    function totalsupply() public view returns (uint supply);
    function balanceof(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event approval(address indexed _owner, address indexed _spender, uint _value);
}
