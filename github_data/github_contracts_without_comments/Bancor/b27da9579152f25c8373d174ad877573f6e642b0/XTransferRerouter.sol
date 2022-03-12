
pragma solidity 0.6.12;
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

    
    modifier reroutingallowed {
        _reroutingallowed();
        _;
    }

    
    function _reroutingallowed() internal view {
        require(reroutingenabled, );
    }

    
    function reroutetx(uint256 _txid, bytes32 _blockchain, bytes32 _to) public reroutingallowed {
        emit txreroute(_txid, _blockchain, _to);
    }
}
