

pragma solidity ^0.4.21;


import ;
import ;
import ;
import ;



contract externstateproxytoken is safedecimalmath, proxyable {

    

    
    tokenstate public state;

    
    string public name;
    string public symbol;
    uint public totalsupply;


    

    
    function externstateproxytoken(string _name, string _symbol,
                                   uint _initialsupply, address _initialbeneficiary,
                                   tokenstate _state, address _owner)
        proxyable(_owner)
        public
    {
        name = _name;
        symbol = _symbol;
        totalsupply = _initialsupply;

        
        if (_state == tokenstate(0)) {
            state = new tokenstate(_owner, address(this));
            state.setbalanceof(_initialbeneficiary, totalsupply);
            emit transfer(address(0), _initialbeneficiary, _initialsupply);
        } else {
            state = _state;
        }
   }

    

    
    function allowance(address tokenowner, address spender)
        public
        view
        returns (uint)
    {
        return state.allowance(tokenowner, spender);
    }

    
    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return state.balanceof(account);
    }

    

    
    function setstate(tokenstate _state)
        external
        optionalproxy_onlyowner
    {
        state = _state;
        emit stateupdated(_state);
    } 

    
    function _transfer_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        state.setbalanceof(sender, safesub(state.balanceof(sender), value));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));

        emit transfer(sender, to, value);

        return true;
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        state.setbalanceof(from, safesub(state.balanceof(from), value));
        state.setallowance(from, sender, safesub(state.allowance(from, sender), value));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));

        emit transfer(from, to, value);

        return true;
    }

    
    function approve(address spender, uint value)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        state.setallowance(sender, spender, value);
        emit approval(sender, spender, value);
        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);

    event approval(address indexed owner, address indexed spender, uint value);

    event stateupdated(address newstate);
}
