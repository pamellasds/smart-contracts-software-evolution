pragma solidity ^0.4.22;

contract erc20 {
    function balanceof(address tokenowner) public constant returns (uint balance);
    function allowance(address tokenowner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferfrom(address from, address to, uint tokens) public returns (bool success);

    event transfer(address indexed from, address indexed to, uint tokens);
    event approval(address indexed tokenowner, address indexed spender, uint tokens);
}
