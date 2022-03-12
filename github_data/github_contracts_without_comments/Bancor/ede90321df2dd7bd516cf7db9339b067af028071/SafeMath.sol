pragma solidity 0.4.26;


library safemath {
    
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y);
        return _x  _y;
    }

    
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

      
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
}
