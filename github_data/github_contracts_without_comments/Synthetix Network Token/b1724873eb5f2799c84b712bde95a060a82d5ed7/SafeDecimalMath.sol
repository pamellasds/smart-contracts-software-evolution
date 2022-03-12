

pragma solidity 0.4.21;



contract safedecimalmath {

    
    uint8 public constant decimals = 18;

    
    uint public constant unit = 10 ** uint(decimals);

    
    function addissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return x + y >= y;
    }

    
    function safeadd(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(x + y >= y);
        return x + y;
    }

    
    function subissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y <= x;
    }

    
    function safesub(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(y <= x);
        return x  y;
    }

    
    function mulissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        if (x == 0) {
            return true;
        }
        return (x * y) / x == y;
    }

    
    function safemul(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        if (x == 0) {
            return 0;
        }
        uint p = x * y;
        require(p / x == y);
        return p;
    }

    
    function safemul_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        
        return safemul(x, y) / unit;

    }

    
    function divissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y != 0;
    }

    
    function safediv(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        
        require(y != 0);
        return x / y;
    }

    
    function safediv_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        
        return safediv(safemul(x, unit), y);
    }

    
    function inttodec(uint i)
        pure
        internal
        returns (uint)
    {
        return safemul(i, unit);
    }
}
