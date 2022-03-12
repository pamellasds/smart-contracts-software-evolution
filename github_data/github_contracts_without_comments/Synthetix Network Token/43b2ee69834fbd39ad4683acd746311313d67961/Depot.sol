pragma solidity ^0.5.16;


import ;
import ;
import ;
import ;
import ;
import ;


import ;


import ;
import ;



contract depot is owned, selfdestructible, pausable, reentrancyguard, mixinresolver, idepot {
    using safemath for uint;
    using safedecimalmath for uint;

    bytes32 internal constant snx = ;
    bytes32 internal constant eth = ;

    

    
    
    
    address payable public fundswallet;

    
    struct synthdepositentry {
        
        address payable user;
        
        uint amount;
    }

    
    mapping(uint => synthdepositentry) public deposits;
    
    uint public depositstartindex;
    
    uint public depositendindex;

    
    uint public totalsellabledeposits;

    
    uint public minimumdepositamount = 50 * safedecimalmath.unit();

    
    uint public maxethpurchase = 500 * safedecimalmath.unit();

    
    
    
    mapping(address => uint) public smalldeposits;

    

    bytes32 private constant contract_synthsusd = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_synthetix = ;

    bytes32[24] private addressestocache = [contract_synthsusd, contract_exrates, contract_synthetix];

    

    constructor(
        address _owner,
        address payable _fundswallet,
        address _resolver
    ) public owned(_owner) selfdestructible() pausable() mixinresolver(_resolver, addressestocache) {
        fundswallet = _fundswallet;
    }

    

    function setmaxethpurchase(uint _maxethpurchase) external onlyowner {
        maxethpurchase = _maxethpurchase;
        emit maxethpurchaseupdated(maxethpurchase);
    }

    
    function setfundswallet(address payable _fundswallet) external onlyowner {
        fundswallet = _fundswallet;
        emit fundswalletupdated(fundswallet);
    }

    
    function setminimumdepositamount(uint _amount) external onlyowner {
        
        require(_amount > safedecimalmath.unit(), );
        minimumdepositamount = _amount;
        emit minimumdepositamountupdated(minimumdepositamount);
    }

    

    
    function() external payable nonreentrant ratenotinvalid(eth) notpaused {
        _exchangeetherforsynths();
    }

    
    
    function exchangeetherforsynths()
        external
        payable
        nonreentrant
        ratenotinvalid(eth)
        notpaused
        returns (
            uint 
        )
    {
        return _exchangeetherforsynths();
    }

    function _exchangeetherforsynths() internal returns (uint) {
        require(msg.value <= maxethpurchase, );
        uint ethtosend;

        
        
        uint requestedtopurchase = msg.value.multiplydecimal(exchangerates().rateforcurrency(eth));
        uint remainingtofulfill = requestedtopurchase;

        
        for (uint i = depositstartindex; remainingtofulfill > 0 && i < depositendindex; i++) {
            synthdepositentry memory deposit = deposits[i];

            
            
            if (deposit.user == address(0)) {
                depositstartindex = depositstartindex.add(1);
            } else {
                
                
                if (deposit.amount > remainingtofulfill) {
                    
                    
                    
                    uint newamount = deposit.amount.sub(remainingtofulfill);
                    deposits[i] = synthdepositentry({user: deposit.user, amount: newamount});

                    totalsellabledeposits = totalsellabledeposits.sub(remainingtofulfill);

                    
                    
                    
                    
                    
                    ethtosend = remainingtofulfill.dividedecimal(exchangerates().rateforcurrency(eth));

                    
                    
                    
                    if (!deposit.user.send(ethtosend)) {
                        fundswallet.transfer(ethtosend);
                        emit nonpayablecontract(deposit.user, ethtosend);
                    } else {
                        emit cleareddeposit(msg.sender, deposit.user, ethtosend, remainingtofulfill, i);
                    }

                    
                    
                    
                    
                    synthsusd().transfer(msg.sender, remainingtofulfill);

                    
                    remainingtofulfill = 0;
                } else if (deposit.amount <= remainingtofulfill) {
                    
                    
                    
                    delete deposits[i];
                    
                    depositstartindex = depositstartindex.add(1);
                    
                    totalsellabledeposits = totalsellabledeposits.sub(deposit.amount);

                    
                    
                    
                    
                    
                    ethtosend = deposit.amount.dividedecimal(exchangerates().rateforcurrency(eth));

                    
                    
                    
                    if (!deposit.user.send(ethtosend)) {
                        fundswallet.transfer(ethtosend);
                        emit nonpayablecontract(deposit.user, ethtosend);
                    } else {
                        emit cleareddeposit(msg.sender, deposit.user, ethtosend, deposit.amount, i);
                    }

                    
                    
                    
                    
                    synthsusd().transfer(msg.sender, deposit.amount);

                    
                    
                    remainingtofulfill = remainingtofulfill.sub(deposit.amount);
                }
            }
        }

        
        
        if (remainingtofulfill > 0) {
            msg.sender.transfer(remainingtofulfill.dividedecimal(exchangerates().rateforcurrency(eth)));
        }

        
        uint fulfilled = requestedtopurchase.sub(remainingtofulfill);

        if (fulfilled > 0) {
            
            emit exchange(, msg.value, , fulfilled);
        }

        return fulfilled;
    }

    

    
    function exchangeetherforsynthsatrate(uint guaranteedrate)
        external
        payable
        ratenotinvalid(eth)
        notpaused
        returns (
            uint 
        )
    {
        require(guaranteedrate == exchangerates().rateforcurrency(eth), );

        return _exchangeetherforsynths();
    }

    function _exchangeetherforsnx() internal returns (uint) {
        
        uint synthetixtosend = synthetixreceivedforether(msg.value);

        
        fundswallet.transfer(msg.value);

        
        synthetix().transfer(msg.sender, synthetixtosend);

        emit exchange(, msg.value, , synthetixtosend);

        return synthetixtosend;
    }

    
    function exchangeetherforsnx()
        external
        payable
        ratenotinvalid(snx)
        ratenotinvalid(eth)
        notpaused
        returns (
            uint 
        )
    {
        return _exchangeetherforsnx();
    }

    
    function exchangeetherforsnxatrate(uint guaranteedetherrate, uint guaranteedsynthetixrate)
        external
        payable
        ratenotinvalid(snx)
        ratenotinvalid(eth)
        notpaused
        returns (
            uint 
        )
    {
        require(guaranteedetherrate == exchangerates().rateforcurrency(eth), );
        require(
            guaranteedsynthetixrate == exchangerates().rateforcurrency(snx),
            
        );

        return _exchangeetherforsnx();
    }

    function _exchangesynthsforsnx(uint synthamount) internal returns (uint) {
        
        uint synthetixtosend = synthetixreceivedforsynths(synthamount);

        
        
        
        synthsusd().transferfrom(msg.sender, fundswallet, synthamount);

        
        synthetix().transfer(msg.sender, synthetixtosend);

        emit exchange(, synthamount, , synthetixtosend);

        return synthetixtosend;
    }

    
    function exchangesynthsforsnx(uint synthamount)
        external
        ratenotinvalid(snx)
        notpaused
        returns (
            uint 
        )
    {
        return _exchangesynthsforsnx(synthamount);
    }

    
    function exchangesynthsforsnxatrate(uint synthamount, uint guaranteedrate)
        external
        ratenotinvalid(snx)
        notpaused
        returns (
            uint 
        )
    {
        require(guaranteedrate == exchangerates().rateforcurrency(snx), );

        return _exchangesynthsforsnx(synthamount);
    }

    
    function withdrawsynthetix(uint amount) external onlyowner {
        synthetix().transfer(owner, amount);

        
        
        
        
    }

    
    function withdrawmydepositedsynths() external {
        uint synthstosend = 0;

        for (uint i = depositstartindex; i < depositendindex; i++) {
            synthdepositentry memory deposit = deposits[i];

            if (deposit.user == msg.sender) {
                
                
                synthstosend = synthstosend.add(deposit.amount);
                delete deposits[i];
                
                emit synthdepositremoved(deposit.user, deposit.amount, i);
            }
        }

        
        totalsellabledeposits = totalsellabledeposits.sub(synthstosend);

        
        
        synthstosend = synthstosend.add(smalldeposits[msg.sender]);
        smalldeposits[msg.sender] = 0;

        
        require(synthstosend > 0, );

        
        synthsusd().transfer(msg.sender, synthstosend);

        emit synthwithdrawal(msg.sender, synthstosend);
    }

    
    function depositsynths(uint amount) external {
        
        synthsusd().transferfrom(msg.sender, address(this), amount);

        
        
        if (amount < minimumdepositamount) {
            
            
            smalldeposits[msg.sender] = smalldeposits[msg.sender].add(amount);

            emit synthdepositnotaccepted(msg.sender, amount, minimumdepositamount);
        } else {
            
            deposits[depositendindex] = synthdepositentry({user: msg.sender, amount: amount});
            emit synthdeposit(msg.sender, amount, depositendindex);

            
            depositendindex = depositendindex.add(1);

            
            totalsellabledeposits = totalsellabledeposits.add(amount);
        }
    }

    

    
    function synthetixreceivedforsynths(uint amount) public view returns (uint) {
        
        return amount.dividedecimal(exchangerates().rateforcurrency(snx));
    }

    
    function synthetixreceivedforether(uint amount) public view returns (uint) {
        
        uint valuesentinsynths = amount.multiplydecimal(exchangerates().rateforcurrency(eth));

        
        return synthetixreceivedforsynths(valuesentinsynths);
    }

    
    function synthsreceivedforether(uint amount) public view returns (uint) {
        
        return amount.multiplydecimal(exchangerates().rateforcurrency(eth));
    }

    

    function synthsusd() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthsusd, ));
    }

    function synthetix() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthetix, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    

    modifier ratenotinvalid(bytes32 currencykey) {
        require(!exchangerates().rateisinvalid(currencykey), );
        _;
    }

    

    event maxethpurchaseupdated(uint amount);
    event fundswalletupdated(address newfundswallet);
    event exchange(string fromcurrency, uint fromamount, string tocurrency, uint toamount);
    event synthwithdrawal(address user, uint amount);
    event synthdeposit(address indexed user, uint amount, uint indexed depositindex);
    event synthdepositremoved(address indexed user, uint amount, uint indexed depositindex);
    event synthdepositnotaccepted(address user, uint amount, uint minimum);
    event minimumdepositamountupdated(uint amount);
    event nonpayablecontract(address indexed receiver, uint amount);
    event cleareddeposit(
        address indexed fromaddress,
        address indexed toaddress,
        uint fromethamount,
        uint toamount,
        uint indexed depositindex
    );
}
