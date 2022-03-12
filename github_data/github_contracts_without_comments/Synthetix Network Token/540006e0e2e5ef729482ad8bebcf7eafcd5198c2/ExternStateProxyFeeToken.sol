

pragma solidity ^0.4.20;


import ;
import ;
import ;
import ;


contract externstateproxyfeetoken is proxyable, safedecimalmath {

    

    
    tokenstate public state;

    
    string public name;
    string public symbol;
    uint public totalsupply;

    
    uint public feepool;
    
    uint public transferfeerate;
    
    uint constant max_transfer_fee_rate = unit / 10;
    
    address public feeauthority;


    

    function externstateproxyfeetoken(string _name, string _symbol,
                                      uint _transferfeerate, address _feeauthority,
                                      tokenstate _state, address _owner)
        proxyable(_owner)
        public
    {
        if (_state == tokenstate(0)) {
            state = new tokenstate(_owner, address(this));
        } else {
            state = _state;
        }

        name = _name;
        symbol = _symbol;
        transferfeerate = _transferfeerate;
        feeauthority = _feeauthority;
    }

    

    function settransferfeerate(uint _transferfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_transferfeerate <= max_transfer_fee_rate);
        transferfeerate = _transferfeerate;
        transferfeerateupdated(_transferfeerate);
    }

    function setfeeauthority(address _feeauthority)
        external
        optionalproxy_onlyowner
    {
        feeauthority = _feeauthority;
        feeauthorityupdated(_feeauthority);
    }

    function setstate(tokenstate _state)
        external
        optionalproxy_onlyowner
    {
        state = _state;
    }

    

    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return state.balanceof(account);
    }

    function allowance(address from, address to)
        public
        view
        returns (uint)
    {
        return state.allowance(from, to);
    }

    
    function transferfeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return safemul_dec(value, transferfeerate);
        
        
        
        
        
        
        
    }

    
    
    function transferplusfee(uint value)
        external
        view
        returns (uint)
    {
        return safeadd(value, transferfeeincurred(value));
    }

    
    function pricetospend(uint value)
        external
        view
        returns (uint)
    {
        return safediv_dec(value, safeadd(unit, transferfeerate));
    }

    

    
    function _transfer_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        
        uint fee = transferfeeincurred(value);
        uint totalcharge = safeadd(value, fee);

        
        state.setbalanceof(sender, safesub(balanceof(sender), totalcharge));
        state.setbalanceof(to, safeadd(balanceof(to), value));
        feepool = safeadd(feepool, fee);

        transfer(sender, to, value);
        transferfeepaid(sender, fee);

        return true;
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        
        uint fee = transferfeeincurred(value);
        uint totalcharge = safeadd(value, fee);

        
        state.setbalanceof(from, safesub(state.balanceof(from), totalcharge));
        state.setallowance(from, sender, safesub(state.allowance(from, sender), totalcharge));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));
        feepool = safeadd(feepool, fee);

        transfer(from, to, value);
        transferfeepaid(sender, fee);

        return true;
    }

    function approve(address spender, uint value)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        state.setallowance(sender, spender, value);

        approval(sender, spender, value);

        return true;
    }

    
    function withdrawfee(address account, uint value)
        external
        returns (bool)
    {
        require(msg.sender == feeauthority && account != address(0));
        
        
        if (value == 0) {
            return false;
        }

        
        feepool = safesub(feepool, value);
        state.setbalanceof(account, safeadd(state.balanceof(account), value));

        feeswithdrawn(account, value);

        return true;
    }

    
    function donatetofeepool(uint n)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;

        
        uint balance = state.balanceof(sender);
        require(balance != 0);

        
        state.setbalanceof(sender, safesub(balance, n));
        feepool = safeadd(feepool, n);

        feesdonated(sender, sender, n);

        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);

    event transferfeepaid(address indexed account, uint value);

    event approval(address indexed owner, address indexed spender, uint value);

    event transferfeerateupdated(uint newfeerate);

    event feeauthorityupdated(address feeauthority);

    event feeswithdrawn(address indexed account, uint value);

    event feesdonated(address donor, address indexed donorindex, uint value);
}
