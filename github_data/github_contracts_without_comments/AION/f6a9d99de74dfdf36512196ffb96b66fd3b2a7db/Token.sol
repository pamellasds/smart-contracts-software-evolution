pragma solidity >=0.4.10;

import ;
import ;
import ;
import ;
import ;
import ;

contract token is finalizable, tokenreceivable, safemath, eventdefinitions, pausable {
    
    string constant public name = ;
    uint8 constant public decimals = 8;
    string constant public symbol = ;
    controller public controller;
    string public motd;
    event motd(string message);

    address public burnaddress; 
    bool public burnable = false;

    

    
    function setmotd(string _m) onlyowner {
        motd = _m;
        motd(_m);
    }

    function setcontroller(address _c) onlyowner notfinalized {
        controller = controller(_c);
    }

    

    function balanceof(address a) constant returns (uint) {
        return controller.balanceof(a);
    }

    function totalsupply() constant returns (uint) {
        return controller.totalsupply();
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return controller.allowance(_owner, _spender);
    }

    function transfer(address _to, uint _value) notpaused returns (bool success) {
        if (controller.transfer(msg.sender, _to, _value)) {
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferfrom(address _from, address _to, uint _value) notpaused returns (bool success) {
        if (controller.transferfrom(msg.sender, _from, _to, _value)) {
            transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) notpaused returns (bool success) {
        
        if (controller.approve(msg.sender, _spender, _value)) {
            approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    function increaseapproval (address _spender, uint _addedvalue) notpaused returns (bool success) {
        if (controller.increaseapproval(msg.sender, _spender, _addedvalue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    function decreaseapproval (address _spender, uint _subtractedvalue) notpaused returns (bool success) {
        if (controller.decreaseapproval(msg.sender, _spender, _subtractedvalue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    
    
    
    

    

    modifier onlycontroller() {
        assert(msg.sender == address(controller));
        _;
    }

    
    
    

    function controllertransfer(address _from, address _to, uint _value) onlycontroller {
        transfer(_from, _to, _value);
    }

    function controllerapprove(address _owner, address _spender, uint _value) onlycontroller {
        approval(_owner, _spender, _value);
    }

    
    function controllerburn(address _from, bytes32 _to, uint256 _value) onlycontroller {
        burn(_from, _to, _value);
    }

    function controllerclaim(address _claimer, uint256 _value) onlycontroller {
        claimed(_claimer, _value);
    }

    
    function setburnaddress(address _address) onlycontroller {
        burnaddress = _address;
    }

    
    function enableburning() onlycontroller {
        burnable = true;
    }

    
    function disableburning() onlycontroller {
        burnable = false;
    }

    
    modifier burnenabled() {
        require(burnable == true);
        _;
    }

    
    function burn(bytes32 _to, uint _amount) notpaused burnenabled returns (bool success) {
        return controller.burn(msg.sender, _to, _amount);
    }

    
    function claimbyproof(bytes32[] data, bytes32[] proofs, uint256 number) notpaused burnenabled returns (bool success) {
        return controller.claimbyproof(msg.sender, data, proofs, number);
    }

    
    function claim() notpaused burnenabled returns (bool success) {
        return controller.claim(msg.sender);
    }
}