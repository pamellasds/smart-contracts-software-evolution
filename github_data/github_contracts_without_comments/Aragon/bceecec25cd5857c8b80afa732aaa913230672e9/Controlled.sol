pragma solidity ^0.4.8;

contract controlled {
    
    
    modifier onlycontroller { if (msg.sender != controller) throw; _; }

    address public controller;

    function controlled() { controller = msg.sender;}

    
    
    function changecontroller(address _newcontroller) onlycontroller {
        controller = _newcontroller;
    }
}
