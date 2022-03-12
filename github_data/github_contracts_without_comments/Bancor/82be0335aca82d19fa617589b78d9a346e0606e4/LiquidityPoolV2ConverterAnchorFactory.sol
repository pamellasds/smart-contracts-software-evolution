pragma solidity 0.4.26;
import ;
import ;


contract liquiditypoolv2converteranchorfactory is itypedconverteranchorfactory {
    
    function convertertype() public pure returns (uint16) {
        return 2;
    }

    
    function createanchor(string _name, string _symbol, uint8 _decimals) public returns (iconverteranchor) {
        ipooltokenscontainer container = new pooltokenscontainer(_name, _symbol, _decimals);
        container.transferownership(msg.sender);
        return container;
    }
}
