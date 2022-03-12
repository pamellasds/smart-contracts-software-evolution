pragma solidity ^0.4.18;


contract utils {
    
    function utils() public {
    }

    
    modifier greaterthanzero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    
    modifier validaddress(address _address) {
        require(_address != address(0));
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
    }

    

    
    function safeadd(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    
    function safesub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_x >= _y);
        return _x  _y;
    }

    
    function safemul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}
