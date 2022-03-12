pragma solidity ^0.5.16;

import ;


contract publicest is externstatetoken {
    uint8 constant decimals = 18;

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        string memory _name,
        string memory _symbol,
        uint _totalsupply,
        address _owner
    ) public externstatetoken(_proxy, _tokenstate, _name, _symbol, _totalsupply, decimals, _owner) {}

    function transfer(address to, uint value) external optionalproxy returns (bool) {
        return _transfer_byproxy(messagesender, to, value);
    }

    function transferfrom(
        address from,
        address to,
        uint value
    ) external optionalproxy returns (bool) {
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    
    event received(address indexed sender, uint256 indexed inputa, bytes32 indexed inputb);

    function somethingtobeproxied(uint256 inputa, bytes32 inputb) external {
        emit received(messagesender, inputa, inputb);
    }
}
