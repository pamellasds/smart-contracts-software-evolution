
pragma solidity 0.6.12;
import ;


interface itypedconverteranchorfactory {
    function convertertype() external pure returns (uint16);
    function createanchor(string memory _name, string memory _symbol, uint8 _decimals) external returns (iconverteranchor);
}
