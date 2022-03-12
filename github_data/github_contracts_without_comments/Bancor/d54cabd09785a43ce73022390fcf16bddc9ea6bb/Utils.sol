
pragma solidity 0.6.12;


contract utils {
    
    modifier greaterthanzero(uint256 _value) {
        _greaterthanzero(_value);
        _;
    }

    
    function _greaterthanzero(uint256 _value) internal pure {
        require(_value > 0, );
    }

    
    modifier validaddress(address _address) {
        _validaddress(_address);
        _;
    }

    
    function _validaddress(address _address) internal pure {
        require(_address != address(0), );
    }

    
    modifier notthis(address _address) {
        _notthis(_address);
        _;
    }

    
    function _notthis(address _address) internal view {
        require(_address != address(this), );
    }
}
