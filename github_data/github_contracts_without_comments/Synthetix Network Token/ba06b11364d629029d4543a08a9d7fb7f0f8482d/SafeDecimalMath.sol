

pragma solidity ^0.4.19;



contract safedecimalmath {

    
    uint public constant decimals = 18;

    
    uint public constant unit = 10 ** decimals;

    
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
        require(addissafe(x, y));
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
        require(subissafe(x, y));
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
        uint r = x * y;
        return r / x == y;
    }

    
    function safedecmul(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(mulissafe(x, y));
        
        return (x * y) / unit;
    }

    
    function divissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y != 0;
    }

    
    function safedecdiv(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(mulissafe(x, unit)); 
        
        return (x * unit) / y;
    }

    
    function inttodec(uint i)
        pure
        internal
        returns (uint)
    {
        return safedecmul(i, unit);
    }
}
