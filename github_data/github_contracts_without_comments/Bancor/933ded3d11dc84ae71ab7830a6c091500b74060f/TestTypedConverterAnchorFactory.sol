pragma solidity 0.4.26;
import ;
import ;
import ;

contract testtypedconverteranchorfactory is itypedconverteranchorfactory {
    string public name;

    constructor(string _name) public {
        name = _name;
    }

    function convertertype() public pure returns (uint16) {
        return 8;
    }

    function createanchor(string , string _symbol, uint8 _decimals) public returns (iconverteranchor) {
        iconverteranchor anchor = new smarttoken(name, _symbol, _decimals);

        anchor.transferownership(msg.sender);

        return anchor;
    }
}
