

pragma solidity 0.4.24;


import ;



contract feetoken is externstatetoken {

    

    

    
    uint public transferfeerate;
    
    uint constant max_transfer_fee_rate = unit / 10;
    
    address public feeauthority;
    
    address public constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;


    

    
    constructor(address _proxy, tokenstate _tokenstate, string _name, string _symbol, uint _totalsupply,
                uint _transferfeerate, address _feeauthority, address _owner)
        externstatetoken(_proxy, _tokenstate,
                         _name, _symbol, _totalsupply,
                         _owner)
        public
    {
        feeauthority = _feeauthority;

        
        require(_transferfeerate <= max_transfer_fee_rate);
        transferfeerate = _transferfeerate;
    }

    

    
    function settransferfeerate(uint _transferfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_transferfeerate <= max_transfer_fee_rate);
        transferfeerate = _transferfeerate;
        emittransferfeerateupdated(_transferfeerate);
    }

    
    function setfeeauthority(address _feeauthority)
        public
        optionalproxy_onlyowner
    {
        feeauthority = _feeauthority;
        emitfeeauthorityupdated(_feeauthority);
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

    
    function amountreceived(uint value)
        public
        view
        returns (uint)
    {
        return safediv_dec(value, safeadd(unit, transferfeerate));
    }

    
    function feepool()
        external
        view
        returns (uint)
    {
        return tokenstate.balanceof(fee_address);
    }

    

    
    function _internaltransfer(address from, address to, uint amount, uint fee)
        internal
        returns (bool)
    {
        
        require(to != address(0));
        require(to != address(this));
        require(to != address(proxy));

        
        tokenstate.setbalanceof(from, safesub(tokenstate.balanceof(from), safeadd(amount, fee)));
        tokenstate.setbalanceof(to, safeadd(tokenstate.balanceof(to), amount));
        tokenstate.setbalanceof(fee_address, safeadd(tokenstate.balanceof(fee_address), fee));

        
        emittransfer(from, to, amount);
        emittransfer(from, fee_address, fee);

        return true;
    }

    
    function _transfer_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        uint received = amountreceived(value);
        uint fee = safesub(value, received);

        return _internaltransfer(sender, to, received, fee);
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        
        uint received = amountreceived(value);
        uint fee = safesub(value, received);

        
        tokenstate.setallowance(from, sender, safesub(tokenstate.allowance(from, sender), value));

        return _internaltransfer(from, to, received, fee);
    }

    
    function _transfersenderpaysfee_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        
        uint fee = transferfeeincurred(value);
        return _internaltransfer(sender, to, value, fee);
    }

    
    function _transferfromsenderpaysfee_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        
        uint fee = transferfeeincurred(value);
        uint total = safeadd(value, fee);

        
        tokenstate.setallowance(from, sender, safesub(tokenstate.allowance(from, sender), total));

        return _internaltransfer(from, to, value, fee);
    }

    
    function withdrawfees(address account, uint value)
        external
        onlyfeeauthority
        returns (bool)
    {
        require(account != address(0));

        
        if (value == 0) {
            return false;
        }

        
        tokenstate.setbalanceof(fee_address, safesub(tokenstate.balanceof(fee_address), value));
        tokenstate.setbalanceof(account, safeadd(tokenstate.balanceof(account), value));

        emitfeeswithdrawn(account, value);
        emittransfer(fee_address, account, value);

        return true;
    }

    
    function donatetofeepool(uint n)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        
        uint balance = tokenstate.balanceof(sender);
        require(balance != 0);

        
        tokenstate.setbalanceof(sender, safesub(balance, n));
        tokenstate.setbalanceof(fee_address, safeadd(tokenstate.balanceof(fee_address), n));

        emitfeesdonated(sender, n);
        emittransfer(sender, fee_address, n);

        return true;
    }


    

    modifier onlyfeeauthority
    {
        require(msg.sender == feeauthority);
        _;
    }


    

    event transferfeerateupdated(uint newfeerate);
    bytes32 constant transferfeerateupdated_sig = keccak256();
    function emittransferfeerateupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, transferfeerateupdated_sig, 0, 0, 0);
    }

    event feeauthorityupdated(address newfeeauthority);
    bytes32 constant feeauthorityupdated_sig = keccak256();
    function emitfeeauthorityupdated(address newfeeauthority) internal {
        proxy._emit(abi.encode(newfeeauthority), 1, feeauthorityupdated_sig, 0, 0, 0);
    } 

    event feeswithdrawn(address indexed account, uint value);
    bytes32 constant feeswithdrawn_sig = keccak256();
    function emitfeeswithdrawn(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, feeswithdrawn_sig, bytes32(account), 0, 0);
    }

    event feesdonated(address indexed donor, uint value);
    bytes32 constant feesdonated_sig = keccak256();
    function emitfeesdonated(address donor, uint value) internal {
        proxy._emit(abi.encode(value), 2, feesdonated_sig, bytes32(donor), 0, 0);
    }
}
