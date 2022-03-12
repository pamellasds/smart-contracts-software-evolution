
pragma solidity ^0.4.20;

import ;

contract publicmath is safedecimalmath {
    
    function pubaddissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return addissafe(x, y);
    }

    function pubsafeadd(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safeadd(x, y);
    }

    function pubsubissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return subissafe(x, y);
    }

    function pubsafesub(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safesub(x, y);
    }

    function pubmulissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return mulissafe(x, y);
    }

    function pubsafemul(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safemul(x, y);
    }

    function pubsafemul_dec(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safemul_dec(x, y);
    }

    function pubdivissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return divissafe(x, y);
    }

    function pubsafediv(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safediv(x, y);
    }

    function pubsafediv_dec(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safediv_dec(x, y);
    }

    function pubinttodec(uint i)
        pure
        public
        returns (uint)
    {
        return inttodec(i);
    }
}
