pragma solidity ^0.5.16;



contract ierc20 {
    function totalsupply() public view returns (uint);

    function balanceof(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function transferfrom(
        address from,
        address to,
        uint value
    ) public returns (bool);

    
    function name() public view returns (string memory);

    function symbol() public view returns (string memory);

    function decimals() public view returns (uint8);

    event transfer(address indexed from, address indexed to, uint value);

    event approval(address indexed owner, address indexed spender, uint value);
}
