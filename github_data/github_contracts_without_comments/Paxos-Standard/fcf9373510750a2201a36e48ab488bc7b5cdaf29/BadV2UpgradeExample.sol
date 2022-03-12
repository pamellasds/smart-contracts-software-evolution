pragma solidity ^0.4.24;
pragma experimental ;


import ;



contract badv2upgradeexample {

    

    using safemath for uint256;

    

    

    
    mapping(address => uint256) internal nextseqs;
    
    string constant internal eip191_header = ;
    
    bytes32 constant internal eip712_domain_separator_schema_hash = keccak256(
        
    );
    bytes32 constant internal eip712_delegated_transfer_schema_hash = keccak256(
        
    );
    
    
    bytes32 public eip712_domain_hash;

    
    bool private initialized = false;

    
    mapping(address => uint256) internal balances;
    uint256 internal totalsupply_;
    string public constant name = ; 
    string public constant symbol = ; 
    uint8 public constant decimals = 18; 

    
    mapping(address => mapping(address => uint256)) internal allowed;

    
    address public owner;

    
    bool public paused = false;

    
    address public assetprotectionrole;
    mapping(address => bool) internal frozen;

    
    address public supplycontroller;

    

    
    event transfer(address indexed from, address indexed to, uint256 value);

    
    event approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    
    event ownershiptransferred(
        address indexed oldowner,
        address indexed newowner
    );

    
    event pause();
    event unpause();

    
    event addressfrozen(address indexed addr);
    event addressunfrozen(address indexed addr);
    event frozenaddresswiped(address indexed addr);
    event assetprotectionroleset (
        address indexed oldassetprotectionrole,
        address indexed newassetprotectionrole
    );

    
    event supplyincreased(address indexed to, uint256 value);
    event supplydecreased(address indexed from, uint256 value);
    event supplycontrollerset(
        address indexed oldsupplycontroller,
        address indexed newsupplycontroller
    );

    
    event delegatedtransfer(
        address indexed from, address indexed to, uint256 value, uint256 seq, uint256 fee
    );

    

    

    
    function initialize() public {
        require(!initialized, );
        owner = msg.sender;
        assetprotectionrole = address(0);
        totalsupply_ = 0;
        supplycontroller = msg.sender;
        initialized = true;
    }

    
    constructor() public {
        initialize();
        pause();
        
        initializedomainseparator();
    }

    
    function initializedomainseparator() public {
        
        eip712_domain_hash = keccak256(abi.encodepacked(
                eip712_domain_separator_schema_hash,
                keccak256(bytes(name)),
                bytes32(address(this))
            ));
    }

    

    
    function totalsupply() public view returns (uint256) {
        return totalsupply_;
    }

    
    function transfer(address _to, uint256 _value) public whennotpaused returns (bool) {
        require(_to != address(0), );
        require(!frozen[_to] && !frozen[msg.sender], );
        require(_value <= balances[msg.sender], );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
        return true;
    }

    
    function balanceof(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    

    
    function transferfrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    whennotpaused
    returns (bool)
    {
        require(_to != address(0), );
        require(!frozen[_to] && !frozen[_from] && !frozen[msg.sender], );
        require(_value <= balances[_from], );
        require(_value <= allowed[_from][msg.sender], );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public whennotpaused returns (bool) {
        require(!frozen[_spender] && !frozen[msg.sender], );
        allowed[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
        return true;
    }

    
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    

    
    modifier onlyowner() {
        require(msg.sender == owner, );
        _;
    }

    
    function transferownership(address _newowner) public onlyowner {
        require(_newowner != address(0), );
        emit ownershiptransferred(owner, _newowner);
        owner = _newowner;
    }

    
    function reclaimpax() external onlyowner {
        uint256 _balance = balances[this];
        balances[this] = 0;
        balances[owner] = balances[owner].add(_balance);
        emit transfer(this, owner, _balance);
    }

    

    
    modifier whennotpaused() {
        require(!paused, );
        _;
    }

    
    function pause() public onlyowner {
        require(!paused, );
        paused = true;
        emit pause();
    }

    
    function unpause() public onlyowner {
        require(paused, );
        paused = false;
        emit unpause();
    }

    

    
    function setassetprotectionrole(address _newassetprotectionrole) public {
        require(msg.sender == assetprotectionrole || msg.sender == owner, );
        emit assetprotectionroleset(assetprotectionrole, _newassetprotectionrole);
        assetprotectionrole = _newassetprotectionrole;
    }

    modifier onlyassetprotectionrole() {
        require(msg.sender == assetprotectionrole, );
        _;
    }

    
    function freeze(address _addr) public onlyassetprotectionrole {
        require(!frozen[_addr], );
        frozen[_addr] = true;
        emit addressfrozen(_addr);
    }

    
    function unfreeze(address _addr) public onlyassetprotectionrole {
        require(frozen[_addr], );
        frozen[_addr] = false;
        emit addressunfrozen(_addr);
    }

    
    function wipefrozenaddress(address _addr) public onlyassetprotectionrole {
        require(frozen[_addr], );
        uint256 _balance = balances[_addr];
        balances[_addr] = 0;
        totalsupply_ = totalsupply_.sub(_balance);
        emit frozenaddresswiped(_addr);
        emit supplydecreased(_addr, _balance);
        emit transfer(_addr, address(0), _balance);
    }

    
    function isfrozen(address _addr) public view returns (bool) {
        return frozen[_addr];
    }

    

    
    function setsupplycontroller(address _newsupplycontroller) public {
        require(msg.sender == supplycontroller || msg.sender == owner, );
        require(_newsupplycontroller != address(0), );
        emit supplycontrollerset(supplycontroller, _newsupplycontroller);
        supplycontroller = _newsupplycontroller;
    }

    modifier onlysupplycontroller() {
        require(msg.sender == supplycontroller, );
        _;
    }

    
    function increasesupply(uint256 _value) public onlysupplycontroller returns (bool success) {
        totalsupply_ = totalsupply_.add(_value);
        balances[supplycontroller] = balances[supplycontroller].add(_value);
        emit supplyincreased(supplycontroller, _value);
        emit transfer(address(0), supplycontroller, _value);
        return true;
    }

    
    function decreasesupply(uint256 _value) public onlysupplycontroller returns (bool success) {
        require(_value <= balances[supplycontroller], );
        balances[supplycontroller] = balances[supplycontroller].sub(_value);
        totalsupply_ = totalsupply_.sub(_value);
        emit supplydecreased(supplycontroller, _value);
        emit transfer(supplycontroller, address(0), _value);
        return true;
    }

    

    
    
        return nextseqs[target];
    }

    
    function delegatedtransfer(
        bytes sig, address to, uint256 value, uint256 fee, uint256 seq, uint256 deadline
    ) public whennotpaused returns (bool) {
        require(sig.length == 65, );
        require(value > 0, );
        require(block.number <= deadline, );

        
        bytes32 delegatedtransferhash = keccak256(abi.encodepacked(
                eip712_delegated_transfer_schema_hash, bytes32(to), value, fee, seq, deadline
            ));
        bytes32 hash = keccak256(abi.encodepacked(eip191_header, eip712_domain_hash, delegatedtransferhash));
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        address from = ecrecover(hash, v, r, s);

        require(from != address(0) && to != address(0), );
        require(!frozen[to] && !frozen[from] && !frozen[msg.sender], );
        require(value+fee <= balances[from], );
        require(nextseqs[from] == seq, );

        nextseqs[from] = nextseqs[from] + 1;
        balances[from] = balances[from].sub(value + fee);
        if (fee != 0) {
            balances[msg.sender] = balances[msg.sender].add(fee);
            emit transfer(from, msg.sender, fee);
        }
        balances[to] = balances[to].add(value);
        emit transfer(from, to, value);

        emit delegatedtransfer(from, to, value, seq, fee);
        return true;
    }
}
