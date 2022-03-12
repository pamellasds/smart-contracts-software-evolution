
pragma solidity 0.6.12;
import ;
import ;
import ;

contract testtypedconverteranchorfactory is itypedconverteranchorfactory {
    string public name;

    constructor(string memory _name) public {
        name = _name;
    }

    function convertertype() external override pure returns (uint16) {
        return 8;
    }

    function createanchor(string memory , string memory _symbol, uint8 _decimals) external override returns (iconverteranchor) {
        iconverteranchor anchor = new smarttoken(name, _symbol, _decimals);
        anchor.transferownership(msg.sender);
        return anchor;
    }
}
