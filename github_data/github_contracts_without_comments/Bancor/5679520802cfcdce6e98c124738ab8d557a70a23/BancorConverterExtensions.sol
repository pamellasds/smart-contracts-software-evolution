pragma solidity ^0.4.21;
import ;
import ;


contract bancorconverterextensions is ibancorconverterextensions, tokenholder {
    ibancorformula public formula;  
    ibancorgaspricelimit public gaspricelimit; 
    ibancorquickconverter public quickconverter; 

    
    function bancorconverterextensions(ibancorformula _formula, ibancorgaspricelimit _gaspricelimit, ibancorquickconverter _quickconverter)
        public
        validaddress(_formula)
        validaddress(_gaspricelimit)
        validaddress(_quickconverter)
    {
        formula = _formula;
        gaspricelimit = _gaspricelimit;
        quickconverter = _quickconverter;
    }

    
    function setformula(ibancorformula _formula)
        public
        owneronly
        validaddress(_formula)
        notthis(_formula)
    {
        formula = _formula;
    }

    
    function setgaspricelimit(ibancorgaspricelimit _gaspricelimit)
        public
        owneronly
        validaddress(_gaspricelimit)
        notthis(_gaspricelimit)
    {
        gaspricelimit = _gaspricelimit;
    }

    
    function setquickconverter(ibancorquickconverter _quickconverter)
        public
        owneronly
        validaddress(_quickconverter)
        notthis(_quickconverter)
    {
        quickconverter = _quickconverter;
    }
}
