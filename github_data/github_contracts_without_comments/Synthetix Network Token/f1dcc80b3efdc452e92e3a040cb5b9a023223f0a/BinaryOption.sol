pragma solidity ^0.5.16;


import ;
import ;


import ;


import ;


contract binaryoption is ierc20, ibinaryoption {
    

    using safemath for uint;
    using safedecimalmath for uint;

    

    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;

    binaryoptionmarket public market;

    mapping(address => uint) public bidof;
    uint public totalbids;

    mapping(address => uint) public balanceof;
    uint public totalsupply;

    
    mapping(address => mapping(address => uint)) public allowance;

    
    uint internal constant _minimum_bid = 1e16;

    

    constructor(address initialbidder, uint initialbid) public {
        market = binaryoptionmarket(msg.sender);
        bidof[initialbidder] = initialbid;
        totalbids = initialbid;
    }

    

    function _claimablebalanceof(
        uint _bid,
        uint price,
        uint exercisabledeposits
    ) internal view returns (uint) {
        uint owed = _bid.dividedecimal(price);
        uint supply = _totalclaimablesupply(exercisabledeposits);

        
        if (_bid == totalbids && _bid != 0) {
            return supply;
        }

        
        assert(owed <= supply);
        return owed;
    }

    function claimablebalanceof(address account) external view returns (uint) {
        (uint price, uint exercisabledeposits) = market.senderpriceandexercisabledeposits();
        return _claimablebalanceof(bidof[account], price, exercisabledeposits);
    }

    function _totalclaimablesupply(uint exercisabledeposits) internal view returns (uint) {
        uint _totalsupply = totalsupply;
        
        
        if (exercisabledeposits <= _totalsupply) {
            return 0;
        }
        return exercisabledeposits.sub(_totalsupply);
    }

    function totalclaimablesupply() external view returns (uint) {
        return _totalclaimablesupply(market.exercisabledeposits());
    }

    

    function _requireminimumbid(uint bid) internal pure returns (uint) {
        require(bid >= _minimum_bid || bid == 0, );
        return bid;
    }

    
    function bid(address bidder, uint newbid) external onlymarket {
        bidof[bidder] = _requireminimumbid(bidof[bidder].add(newbid));
        totalbids = totalbids.add(newbid);
    }

    
    function refund(address bidder, uint newrefund) external onlymarket {
        
        bidof[bidder] = _requireminimumbid(bidof[bidder].sub(newrefund));
        totalbids = totalbids.sub(newrefund);
    }

    
    function claim(
        address claimant,
        uint price,
        uint depositsremaining
    ) external onlymarket returns (uint optionsclaimed) {
        uint _bid = bidof[claimant];
        uint claimable = _claimablebalanceof(_bid, price, depositsremaining);
        
        if (claimable == 0) {
            return 0;
        }

        totalbids = totalbids.sub(_bid);
        bidof[claimant] = 0;

        totalsupply = totalsupply.add(claimable);
        balanceof[claimant] = balanceof[claimant].add(claimable); 

        emit transfer(address(0), claimant, claimable);
        emit issued(claimant, claimable);

        return claimable;
    }

    
    function exercise(address claimant) external onlymarket {
        uint balance = balanceof[claimant];

        if (balance == 0) {
            return;
        }

        balanceof[claimant] = 0;
        totalsupply = totalsupply.sub(balance);

        emit transfer(claimant, address(0), balance);
        emit burned(claimant, balance);
    }

    
    
    function expire(address payable beneficiary) external onlymarket {
        selfdestruct(beneficiary);
    }

    

    
    
    
    function _transfer(
        address _from,
        address _to,
        uint _value
    ) internal returns (bool success) {
        market.requireactiveandunpaused();
        require(_to != address(0) && _to != address(this), );

        uint frombalance = balanceof[_from];
        require(_value <= frombalance, );

        balanceof[_from] = frombalance.sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);

        emit transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferfrom(
        address _from,
        address _to,
        uint _value
    ) external returns (bool success) {
        uint fromallowance = allowance[_from][msg.sender];
        require(_value <= fromallowance, );

        allowance[_from][msg.sender] = fromallowance.sub(_value);
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
        return true;
    }

    

    modifier onlymarket() {
        require(msg.sender == address(market), );
        _;
    }

    

    event issued(address indexed account, uint value);
    event burned(address indexed account, uint value);
    event transfer(address indexed from, address indexed to, uint value);
    event approval(address indexed owner, address indexed spender, uint value);
}
