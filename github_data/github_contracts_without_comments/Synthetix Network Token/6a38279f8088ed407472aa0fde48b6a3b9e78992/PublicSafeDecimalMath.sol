
pragma solidity 0.4.25;

import ;

contract publicsafedecimalmath {
    using safedecimalmath for uint;
    
    function unit()
        public
        pure
        returns (uint)
    {
        return safedecimalmath.unit();
    }

    function preciseunit()
        public
        pure
        returns (uint)
    {
        return safedecimalmath.preciseunit();
    }

    function multiplydecimal(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.multiplydecimal(y);
    }

    function multiplydecimalround(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.multiplydecimalround(y);
    }

    function multiplydecimalroundprecise(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.multiplydecimalroundprecise(y);
    }

    function dividedecimal(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.dividedecimal(y);
    }

    function dividedecimalround(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.dividedecimalround(y);
    }

    function dividedecimalroundprecise(uint x, uint y)
        public
        pure
        returns (uint)
    {
        return x.dividedecimalroundprecise(y);
    }

    function decimaltoprecisedecimal(uint i)
        public
        pure
        returns (uint)
    {
        return i.decimaltoprecisedecimal();
    }

    function precisedecimaltodecimal(uint i)
        public
        pure
        returns (uint)
    {
        return i.precisedecimaltodecimal();
    }
}
