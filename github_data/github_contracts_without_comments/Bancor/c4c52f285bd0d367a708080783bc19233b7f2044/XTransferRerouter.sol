pragma solidity ^0.4.24;

import ;

contract xtransferrerouter is owned {
    bool public reroutingenabled;

    
    event txreroute(
        uint256 indexed _txid,
        bytes32 _toblockchain,
        bytes32 _to
    );

    
    constructor(bool _reroutingenabled) public {
        reroutingenabled = _reroutingenabled;
    }
    
    function enablererouting(bool _enable) public owneronly {
        reroutingenabled = _enable;
    }

    
    modifier whenreroutingenabled {
        require(reroutingenabled);
        _;
    }

    
    function reroutetx(
        uint256 _txid,
        bytes32 _blockchain,
        bytes32 _to
    )
        public
        whenreroutingenabled 
    {
        emit txreroute(_txid, _blockchain, _to);
    }

}