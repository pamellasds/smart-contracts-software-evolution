






pragma solidity 0.4.25;


contract owned {
    address public owner;
    address public nominatedowner;

    
    constructor(address _owner)
        public
    {
        require(_owner != address(0), );
        owner = _owner;
        emit ownerchanged(address(0), _owner);
    }

    
    function nominatenewowner(address _owner)
        external
        onlyowner
    {
        nominatedowner = _owner;
        emit ownernominated(_owner);
    }

    
    function acceptownership()
        external
    {
        require(msg.sender == nominatedowner, );
        emit ownerchanged(owner, nominatedowner);
        owner = nominatedowner;
        nominatedowner = address(0);
    }

    modifier onlyowner
    {
        require(msg.sender == owner, );
        _;
    }

    event ownernominated(address newowner);
    event ownerchanged(address oldowner, address newowner);
}





contract proxy is owned {

    proxyable public target;
    bool public usedelegatecall;

    constructor(address _owner)
        owned(_owner)
        public
    {}

    function settarget(proxyable _target)
        external
        onlyowner
    {
        target = _target;
        emit targetupdated(_target);
    }

    function setusedelegatecall(bool value) 
        external
        onlyowner
    {
        usedelegatecall = value;
    }

    function _emit(bytes calldata, uint numtopics, bytes32 topic1, bytes32 topic2, bytes32 topic3, bytes32 topic4)
        external
        onlytarget
    {
        uint size = calldata.length;
        bytes memory _calldata = calldata;

        assembly {
            
            switch numtopics
            case 0 {
                log0(add(_calldata, 32), size)
            } 
            case 1 {
                log1(add(_calldata, 32), size, topic1)
            }
            case 2 {
                log2(add(_calldata, 32), size, topic1, topic2)
            }
            case 3 {
                log3(add(_calldata, 32), size, topic1, topic2, topic3)
            }
            case 4 {
                log4(add(_calldata, 32), size, topic1, topic2, topic3, topic4)
            }
        }
    }

    function()
        external
        payable
    {
        if (usedelegatecall) {
            assembly {
                
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                
                let result := delegatecall(gas, sload(target_slot), free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                
                if iszero(result) { revert(free_ptr, returndatasize) }
                return(free_ptr, returndatasize)
            }
        } else {
            
            target.setmessagesender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                
                let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                if iszero(result) { revert(free_ptr, returndatasize) }
                return(free_ptr, returndatasize)
            }
        }
    }

    modifier onlytarget {
        require(proxyable(msg.sender) == target, );
        _;
    }

    event targetupdated(proxyable newtarget);
}






contract proxyable is owned {
    
    proxy public proxy;
    proxy public integrationproxy;

    
    address messagesender;

    constructor(address _proxy, address _owner)
        owned(_owner)
        public
    {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setproxy(address _proxy)
        external
        onlyowner
    {
        proxy = proxy(_proxy);
        emit proxyupdated(_proxy);
    }

    function setintegrationproxy(address _integrationproxy)
        external
        onlyowner
    {
        integrationproxy = proxy(_integrationproxy);
    }

    function setmessagesender(address sender)
        external
        onlyproxy
    {
        messagesender = sender;
    }

    modifier onlyproxy {
        require(proxy(msg.sender) == proxy || proxy(msg.sender) == integrationproxy, );
        _;
    }

    modifier optionalproxy
    {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy) {
            messagesender = msg.sender;
        }
        _;
    }

    modifier optionalproxy_onlyowner
    {
        if (proxy(msg.sender) != proxy && proxy(msg.sender) != integrationproxy) {
            messagesender = msg.sender;
        }
        require(messagesender == owner, );
        _;
    }

    event proxyupdated(address proxyaddress);
}



contract ierc20 {
    function totalsupply() public view returns (uint);

    function balanceof(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function transferfrom(address from, address to, uint value) public returns (bool);

    
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);

    event transfer(
      address indexed from,
      address indexed to,
      uint value
    );

    event approval(
      address indexed owner,
      address indexed spender,
      uint value
    );
}





contract proxyerc20 is proxy, ierc20 {

    constructor(address _owner)
        proxy(_owner)
        public
    {}

    

    function name() public view returns (string){
        
        return ierc20(target).name();
    }

    function symbol() public view returns (string){
         
        return ierc20(target).symbol();
    }

    function decimals() public view returns (uint8){
         
        return ierc20(target).decimals();
    }

    

    
    function totalsupply() public view returns (uint256) {
        
        return ierc20(target).totalsupply();
    }

    
    function balanceof(address owner) public view returns (uint256) {
        
        return ierc20(target).balanceof(owner);
    }

    
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {
        
        return ierc20(target).allowance(owner, spender);
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).transfer(to, value);

        
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).approve(spender, value);

        
        return true;
    }

    
    function transferfrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        
        target.setmessagesender(msg.sender);

        
        ierc20(target).transferfrom(from, to, value);

        
        return true;
    }
}