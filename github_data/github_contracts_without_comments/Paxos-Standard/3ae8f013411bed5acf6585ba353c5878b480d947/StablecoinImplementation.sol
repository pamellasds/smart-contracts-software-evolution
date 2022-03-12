pragma solidity ^0.4.24;


import ;
import ;
import ;



contract stablecoinimplementation is upgradeabilitystorage, stablecoineventinterface {

    

    using safemath for uint256;

    

    
    bool private initialized = false;

    
    mapping(address => uint256) balances;
    uint256 totalsupply_;
    string public constant name = ; 
    string public constant symbol = ; 
    uint8 public constant decimals = 18; 

    
    address public owner;

    
    bool public paused = false;

    
    address public supplycontroller;

    

    

    
    function initialize() public returns (bool) {
        require(!initialized, );
        initialized = true;
        owner = msg.sender;
        totalsupply_ = 0;
        supplycontroller = msg.sender;
        return true;
    }

    
    constructor() public {
        initialize();
        pause();
    }

    

    
    function totalsupply() public view returns (uint256) {
        return totalsupply_;
    }

    
    function transfer(address _to, uint256 _value) public whennotpaused returns (bool) {
        require(_to != address(0), );
        require(_value <= balances[msg.sender], );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
        return true;
    }

    
    function balanceof(address _addr) public view returns (uint256) {
        return balances[_addr];
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

    

    
    function setsupplycontroller(address _newsupplycontroller) public onlyowner {
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

    

    
    function upgradeto(address newimplementation) public onlyowner {
        _setimplementation(newimplementation);
        emit upgraded(newimplementation);
    }

    
    function implementation() public view returns (address) {
        return _implementation();
    }
}
