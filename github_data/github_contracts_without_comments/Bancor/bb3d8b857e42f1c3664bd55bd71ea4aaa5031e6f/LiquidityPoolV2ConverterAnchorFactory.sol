
pragma solidity 0.6.12;
import ;
import ;


contract liquiditypoolv2converteranchorfactory is itypedconverteranchorfactory {
    
    function convertertype() external pure override returns (uint16) {
        return 2;
    }

    
    function createanchor(string memory _name, string memory _symbol, uint8 _decimals) external override returns (iconverteranchor) {
        ipooltokenscontainer container = new pooltokenscontainer(_name, _symbol, _decimals);
        container.transferownership(msg.sender);
        return container;
    }
}
