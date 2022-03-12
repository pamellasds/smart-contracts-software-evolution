
pragma solidity 0.6.12;
import ;
import ;
import ;


contract ethertoken is iethertoken, erc20token {
    using safemath for uint256;

    
    event issuance(uint256 _amount);

    
    event destruction(uint256 _amount);

    
    constructor(string memory _name, string memory _symbol)
        public
        erc20token(_name, _symbol, 18, 0) {
    }

    
    function deposit() public override payable {
        depositto(msg.sender);
    }

    
    function withdraw(uint256 _amount) public override {
        withdrawto(msg.sender, _amount);
    }

    
    function depositto(address _to)
        public
        override
        payable
        notthis(_to)
    {
        balanceof[_to] = balanceof[_to].add(msg.value); 
        totalsupply = totalsupply.add(msg.value); 

        emit issuance(msg.value);
        emit transfer(address(this), _to, msg.value);
    }

    
    function withdrawto(address payable _to, uint256 _amount)
        public
        override
        notthis(_to)
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_amount); 
        totalsupply = totalsupply.sub(_amount); 
        _to.transfer(_amount); 

        emit transfer(msg.sender, address(this), _amount);
        emit destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value)
        public
        override(ierc20token, erc20token)
        notthis(_to)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        override(ierc20token, erc20token)
        notthis(_to)
        returns (bool)
    {
        return super.transferfrom(_from, _to, _value);
    }

    
    receive() external payable {
        deposit();
    }
}
