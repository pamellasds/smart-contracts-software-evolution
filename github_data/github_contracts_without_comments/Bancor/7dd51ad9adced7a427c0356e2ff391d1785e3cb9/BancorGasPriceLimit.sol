pragma solidity 0.4.26;
import ;
import ;


contract bancorgaspricelimit is owned, utils {
    uint256 public gasprice = 0 wei;    
    
    
    constructor(uint256 _gasprice)
        public
        greaterthanzero(_gasprice)
    {
        gasprice = _gasprice;
    }

    
    function setgasprice(uint256 _gasprice)
        public
        owneronly
        greaterthanzero(_gasprice)
    {
        gasprice = _gasprice;
    }

    
    function validategasprice(uint256 _gasprice)
        public
        view
        greaterthanzero(_gasprice)
    {
        require(_gasprice <= gasprice);
    }
}
