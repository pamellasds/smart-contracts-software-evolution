pragma solidity ^0.4.18;

import ;
import ;



contract controlled {

    address public controller;

    function controlled() public {
        controller = msg.sender;
    }

    function changecontroller(address _newcontroller) public only_controller {
        controller = _newcontroller;
    }
    
    function getcontroller() constant public returns (address) {
        return controller;
    }

    modifier only_controller { 
        require(msg.sender == controller);
        _; 
    }

}


contract thetatoken is standardtoken, controlled {
    
    using safemath for uint;

    string public constant name = ;

    string public constant symbol = ;

    uint8 public constant decimals = 18;

    
    uint unlocktime;
    
    
    mapping (address => bool) internal precirculated;

    function thetatoken(uint _unlocktime) public {
        unlocktime = _unlocktime;
    }

    function transfer(address _to, uint _amount) can_transfer(msg.sender, _to) public returns (bool success) {
        return super.transfer(_to, _amount);
    }

    function transferfrom(address _from, address _to, uint _amount) can_transfer(_from, _to) public returns (bool success) {
        return super.transferfrom(_from, _to, _amount);
    }

    function mint(address _owner, uint _amount) external only_controller returns (bool) {
        require(totalsupply + _amount >= totalsupply);
        
        uint previousbalance = balances[_owner];
        require(previousbalance + _amount >= previousbalance);

        totalsupply = totalsupply.add(_amount);
        balances[_owner] = balances[_owner].add(_amount);

        transfer(0, _owner, _amount);
        return true;
    }

    function allowprecirculation(address _addr) only_controller public {
        precirculated[_addr] = true;
    }

    function disallowprecirculation(address _addr) only_controller public {
        precirculated[_addr] = false;
    }

    function isprecirculationallowed(address _addr) constant public returns(bool) {
        return precirculated[_addr];
    }
    
    function changeunlocktime(uint _unlocktime) only_controller public {
        unlocktime = _unlocktime;
    }

    function getunlocktime() constant public returns (uint) {
        return unlocktime;
    }

    modifier can_transfer(address _from, address _to) {
        require((block.number >= unlocktime) || (isprecirculationallowed(_from) && isprecirculationallowed(_to)));
        _;
    }

}
