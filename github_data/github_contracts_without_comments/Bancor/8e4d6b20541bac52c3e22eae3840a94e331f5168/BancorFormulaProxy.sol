pragma solidity ^0.4.11;
import ;
import ;


contract bancorformulaproxy is ibancorformula, owned {
    ibancorformula public formula;  

    
    function bancorformulaproxy(ibancorformula _formula)
        validaddress(_formula)
    {
        formula = _formula;
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
    }

    
    function setformula(ibancorformula _formula)
        public
        owneronly
        validaddress(_formula)
        notthis(_formula)
    {
        require(_formula != formula); 
        formula = _formula;
    }

    
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint8 _reserveratio, uint256 _depositamount) public constant returns (uint256) {
        return formula.calculatepurchasereturn(_supply, _reservebalance, _reserveratio, _depositamount);
     }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint8 _reserveratio, uint256 _sellamount) public constant returns (uint256) {
        return formula.calculatesalereturn(_supply, _reservebalance, _reserveratio, _sellamount);
    }
}
