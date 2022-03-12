

pragma solidity >=0.4.10;

import ;
import ;
import ;
import ;

contract ledger is owned, safemath, finalizable {
    controller public controller;
    mapping(address => uint) public balanceof;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalsupply;
    uint public mintingnonce;
    bool public mintingstopped;

    
    mapping(uint256 => bytes32) public proofs;

    
    mapping(address => uint256) public locked;

    
    mapping(bytes32 => bytes32) public metadata;

    
    address public burnaddress;

    
    mapping(address => bool) public bridgenodes;

    

    function ledger() {
    }

    function setcontroller(address _controller) onlyowner notfinalized {
        controller = controller(_controller);
    }

    
    function stopminting() onlyowner {
        mintingstopped = true;
    }

    
    function multimint(uint nonce, uint256[] bits) onlyowner {
        require(!mintingstopped);
        if (nonce != mintingnonce) return;
        mintingnonce += 1;
        uint256 lomask = (1 << 96)  1;
        uint created = 0;
        for (uint i=0; i<bits.length; i++) {
            address a = address(bits[i]>>96);
            uint value = bits[i]&lomask;
            balanceof[a] = balanceof[a] + value;
            controller.ledgertransfer(0, a, value);
            created += value;
        }
        totalsupply += created;
    }

    

    modifier onlycontroller() {
        require(msg.sender == address(controller));
        _;
    }

    function transfer(address _from, address _to, uint _value) onlycontroller returns (bool success) {
        if (balanceof[_from] < _value) return false;

        balanceof[_from] = safesub(balanceof[_from], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        return true;
    }

    function transferfrom(address _spender, address _from, address _to, uint _value) onlycontroller returns (bool success) {
        if (balanceof[_from] < _value) return false;

        var allowed = allowance[_from][_spender];
        if (allowed < _value) return false;

        balanceof[_to] = safeadd(balanceof[_to], _value);
        balanceof[_from] = safesub(balanceof[_from], _value);
        allowance[_from][_spender] = safesub(allowed, _value);
        return true;
    }

    function approve(address _owner, address _spender, uint _value) onlycontroller returns (bool success) {
        
        if ((_value != 0) && (allowance[_owner][_spender] != 0)) {
            return false;
        }

        allowance[_owner][_spender] = _value;
        return true;
    }

    function increaseapproval (address _owner, address _spender, uint _addedvalue) onlycontroller returns (bool success) {
        uint oldvalue = allowance[_owner][_spender];
        allowance[_owner][_spender] = safeadd(oldvalue, _addedvalue);
        return true;
    }

    function decreaseapproval (address _owner, address _spender, uint _subtractedvalue) onlycontroller returns (bool success) {
        uint oldvalue = allowance[_owner][_spender];
        if (_subtractedvalue > oldvalue) {
            allowance[_owner][_spender] = 0;
        } else {
            allowance[_owner][_spender] = safesub(oldvalue, _subtractedvalue);
        }
        return true;
    }


    function setproof(uint256 _key, bytes32 _proof) onlycontroller {
        proofs[_key] = _proof;
    }

    function setlocked(address _key, uint256 _value) onlycontroller {
        locked[_key] = _value;
    }

    function setmetadata(bytes32 _key, bytes32 _value) onlycontroller {
        metadata[_key] = _value;
    }

    

    
    function setburnaddress(address _address) onlycontroller {
        burnaddress = _address;
    }

    function setbridgenode(address _address, bool enabled) onlycontroller {
        bridgenodes[_address] = enabled;
    }
}
