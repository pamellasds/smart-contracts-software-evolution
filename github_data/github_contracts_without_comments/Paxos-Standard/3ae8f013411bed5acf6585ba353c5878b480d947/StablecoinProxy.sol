pragma solidity ^0.4.24;


import ;
import ;



contract stablecoinproxy is upgradeabilitystorage, stablecoineventinterface {

    

    
    constructor(address _impl) public {
        _setimplementation(_impl);
    }


    
    function () external payable {
        _delegate();
    }

    
    function _delegate() internal {
        address impl = _implementation();

        assembly {
            
            
            
            calldatacopy(0, 0, calldatasize)

            
            
            let result := delegatecall(gas, impl, 0, calldatasize, 0, 0)

            
            returndatacopy(0, 0, returndatasize)

            switch result
            
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    

    

    function name() public view returns (string) {
        _delegate();
    }

    function symbol() public view returns (string) {
        _delegate();
    }

    function decimals() public view returns (uint8) {
        _delegate();
    }

    function totalsupply() public view returns (uint256) {
        _delegate();
    }

    function balanceof(address who) public view returns (uint256) {
        _delegate();
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _delegate();
    }

    

    function owner() public view returns (address) {
        _delegate();
    }

    function transferownership(address _newowner) public {
        _delegate();
    }

    

    function paused() public view returns (address) {
        _delegate();
    }

    function pause() public {
        _delegate();
    }

    function unpause() public {
        _delegate();
    }

    

    function supplycontroller() public view returns (address) {
        _delegate();
    }

    function setsupplycontroller(address _newsupplycontroller) public {
        _delegate();
    }

    function increasesupply(uint256 _value) public returns (bool success) {
        _delegate();
    }

    function decreasesupply(uint256 _value) public returns (bool success) {
        _delegate();
    }

    

    function upgradeto(address newimplementation) public {
        _delegate();
    }

    function implementation() public view returns (address) {
        _delegate();
    }
}
