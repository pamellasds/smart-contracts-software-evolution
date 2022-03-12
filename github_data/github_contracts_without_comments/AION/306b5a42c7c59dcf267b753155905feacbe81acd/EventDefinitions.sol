

pragma solidity >=0.4.10;

contract eventdefinitions {
    event transfer(address indexed from, address indexed to, uint value);
    event approval(address indexed owner, address indexed spender, uint value);
    event burn(address indexed from, bytes32 indexed to, uint value);
    event claimed(address indexed claimer, uint value);
}