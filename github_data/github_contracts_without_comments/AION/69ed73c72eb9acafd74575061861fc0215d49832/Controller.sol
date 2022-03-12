

pragma solidity >=0.4.10;

import ;
import ;
import ;
import ;
import ;


contract controller is owned, finalizable, controllereventdefinitions {
    ledger public ledger;
    token public token;
    address public burnaddress;

    function controller() {
    }

    


    function settoken(address _token) onlyowner {
        token = token(_token);
    }

    function setledger(address _ledger) onlyowner {
        ledger = ledger(_ledger);
    }

    
    function setburnaddress(address _address) onlyowner {
        burnaddress = _address;
        ledger.setburnaddress(_address);
        token.setburnaddress(_address);
    }

    modifier onlytoken() {
        require(msg.sender == address(token));
        _;
    }

    modifier onlyledger() {
        require(msg.sender == address(ledger));
        _;
    }

    function totalsupply() constant returns (uint) {
        return ledger.totalsupply();
    }

    function balanceof(address _a) constant returns (uint) {
        return ledger.balanceof(_a);
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return ledger.allowance(_owner, _spender);
    }

    

    
    
    
    function ledgertransfer(address from, address to, uint val) onlyledger {
        token.controllertransfer(from, to, val);
    }

    

    function transfer(address _from, address _to, uint _value) onlytoken returns (bool success) {
        return ledger.transfer(_from, _to, _value);
    }

    function transferfrom(address _spender, address _from, address _to, uint _value) onlytoken returns (bool success) {
        return ledger.transferfrom(_spender, _from, _to, _value);
    }

    function approve(address _owner, address _spender, uint _value) onlytoken returns (bool success) {
        return ledger.approve(_owner, _spender, _value);
    }

    function increaseapproval (address _owner, address _spender, uint _addedvalue) onlytoken returns (bool success) {
        return ledger.increaseapproval(_owner, _spender, _addedvalue);
    }

    function decreaseapproval (address _owner, address _spender, uint _subtractedvalue) onlytoken returns (bool success) {
        return ledger.decreaseapproval(_owner, _spender, _subtractedvalue);
    }

    

    
    function enableburning() onlyowner {
        token.enableburning();
    }

    
    function disableburning() onlyowner {
        token.disableburning();
    }

    

     
    function burn(address _from, bytes32 _to, uint _amount) onlytoken returns (bool success) {
        if (ledger.transfer(_from, burnaddress, _amount)) {
            controllerburn(_from, _to, _amount);
            token.controllerburn(_from, _to, _amount);
            return true;
        }
        return false;
    }

    
    function claimbyproof(address _claimer, bytes32[] data, bytes32[] proofs, uint256 number)
        onlytoken
        returns (bool success) {
        return false;
    }

    
    function claim(address _claimer) onlytoken returns (bool success) {
        return false;
    }
}