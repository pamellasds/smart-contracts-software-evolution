
pragma solidity 0.6.12;
import ;


library math {
    using safemath for uint256;

    
    function floorsqrt(uint256 _num) internal pure returns (uint256) {
        uint256 x = _num / 2 + 1;
        uint256 y = (x + _num / x) / 2;
        while (x > y) {
            x = y;
            y = (x + _num / x) / 2;
        }
        return x;
    }

    
    function reducedratio(uint256 _n, uint256 _d, uint256 _max) internal pure returns (uint256, uint256) {
        if (_n > _max || _d > _max)
            return normalizedratio(_n, _d, _max);
        return (_n, _d);
    }

    
    function normalizedratio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {
        if (_a == _b)
            return (_scale / 2, _scale / 2);
        if (_a < _b)
            return accurateratio(_a, _b, _scale);
        (uint256 y, uint256 x) = accurateratio(_b, _a, _scale);
        return (x, y);
    }

    
    function accurateratio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {
        uint256 maxval = uint256(1) / _scale;
        if (_a > maxval) {
            uint256 c = _a / (maxval + 1) + 1;
            _a /= c;
            _b /= c;
        }
        uint256 x = rounddiv(_a * _scale, _a.add(_b));
        uint256 y = _scale  x;
        return (x, y);
    }

    
    function rounddiv(uint256 _n, uint256 _d) internal pure returns (uint256) {
        return _n / _d + _n % _d / (_d  _d / 2);
    }
}
