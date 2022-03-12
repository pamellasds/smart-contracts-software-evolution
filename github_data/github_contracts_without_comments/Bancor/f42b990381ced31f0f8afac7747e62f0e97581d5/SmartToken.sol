
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


contract smarttoken is ismarttoken, owned, erc20token, tokenholder {
    using safemath for uint256;

    uint16 public constant version = 4;

    bool public transfersenabled = true;    

    
    event issuance(uint256 _amount);

    
    event destruction(uint256 _amount);

    
    constructor(string memory _name, string memory _symbol, uint8 _decimals)
        public
        erc20token(_name, _symbol, _decimals, 0)
    {
    }

    
    modifier transfersallowed {
        _transfersallowed();
        _;
    }

    
    function _transfersallowed() internal view {
        require(transfersenabled, );
    }

    
    function disabletransfers(bool _disable) public override owneronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        override
        owneronly
        validaddress(_to)
        notthis(_to)
    {
        totalsupply = totalsupply.add(_amount);
        balanceof[_to] = balanceof[_to].add(_amount);

        emit issuance(_amount);
        emit transfer(address(0), _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount) public override owneronly {
        balanceof[_from] = balanceof[_from].sub(_amount);
        totalsupply = totalsupply.sub(_amount);

        emit transfer(_from, address(0), _amount);
        emit destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value)
        public
        override(ierc20token, erc20token)
        transfersallowed
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        override(ierc20token, erc20token)
        transfersallowed
        returns (bool) 
    {
        return super.transferfrom(_from, _to, _value);
    }
}
