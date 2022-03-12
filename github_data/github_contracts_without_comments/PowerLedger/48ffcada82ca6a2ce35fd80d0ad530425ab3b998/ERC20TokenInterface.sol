pragma solidity 0.4.24;


 contract erc20tokeninterface {

    
    function totalsupply() constant public returns (uint256 supply);

    
    
    function balanceof(address _owner) constant public returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event transfer(address indexed from, address indexed to, uint256 value);
    event approval(address indexed owner, address indexed spender, uint256 value);
}