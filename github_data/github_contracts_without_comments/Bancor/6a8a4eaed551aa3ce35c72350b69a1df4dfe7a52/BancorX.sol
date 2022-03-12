pragma solidity 0.4.26;

import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancorx is ibancorx, owned, tokenholder, contractids {
    using safemath for uint256;

    
    struct transaction {
        uint256 amount;
        bytes32 fromblockchain;
        address to;
        uint8 numofreports;
        bool completed;
    }

    uint16 public version = 3;

    uint256 public maxlocklimit;            
    uint256 public maxreleaselimit;         
    uint256 public minlimit;                
    uint256 public prevlocklimit;           
    uint256 public prevreleaselimit;        
    uint256 public limitincperblock;        
    uint256 public prevlockblocknumber;     
    uint256 public prevreleaseblocknumber;  
    uint256 public minrequiredreports;      
    
    icontractregistry public registry;      
    icontractregistry public prevregistry;  

    ierc20token public token;               
    bool public issmarttoken;               

    bool public xtransfersenabled = true;   
    bool public reportingenabled = true;    
    bool public allowregistryupdate = true; 

    
    mapping (uint256 => transaction) public transactions;

    
    mapping (uint256 => uint256) public transactionids;

    
    mapping (uint256 => mapping (address => bool)) public reportedtxs;

    
    mapping (address => bool) public reporters;

    
    event tokenslock(
        address indexed _from,
        uint256 _amount
    );

    
    event tokensrelease(
        address indexed _to,
        uint256 _amount
    );

    
    event xtransfer(
        address indexed _from,
        bytes32 _toblockchain,
        bytes32 indexed _to,
        uint256 _amount,
        uint256 _id
    );

    
    event txreport(
        address indexed _reporter,
        bytes32 _fromblockchain,
        uint256 _txid,
        address _to,
        uint256 _amount,
        uint256 _xtransferid
    );

    
    event xtransfercomplete(
        address _to,
        uint256 _id
    );

    
    constructor(
        uint256 _maxlocklimit,
        uint256 _maxreleaselimit,
        uint256 _minlimit,
        uint256 _limitincperblock,
        uint256 _minrequiredreports,
        address _registry,
        ierc20token _token,
        bool _issmarttoken
    )
        public
    {
        
        maxlocklimit = _maxlocklimit;
        maxreleaselimit = _maxreleaselimit;
        minlimit = _minlimit;
        limitincperblock = _limitincperblock;
        minrequiredreports = _minrequiredreports;

        
        prevlocklimit = _maxlocklimit;
        prevreleaselimit = _maxreleaselimit;
        prevlockblocknumber = block.number;
        prevreleaseblocknumber = block.number;

        registry = icontractregistry(_registry);
        prevregistry = icontractregistry(_registry);

        token = _token;
        issmarttoken = _issmarttoken;
    }

    
    modifier isreporter {
        require(reporters[msg.sender]);
        _;
    }

    
    modifier whenxtransfersenabled {
        require(xtransfersenabled);
        _;
    }

    
    modifier whenreportingenabled {
        require(reportingenabled);
        _;
    }

    
    function setmaxlocklimit(uint256 _maxlocklimit) public owneronly {
        maxlocklimit = _maxlocklimit;
    }
    
    
    function setmaxreleaselimit(uint256 _maxreleaselimit) public owneronly {
        maxreleaselimit = _maxreleaselimit;
    }
    
    
    function setminlimit(uint256 _minlimit) public owneronly {
        minlimit = _minlimit;
    }

    
    function setlimitincperblock(uint256 _limitincperblock) public owneronly {
        limitincperblock = _limitincperblock;
    }

    
    function setminrequiredreports(uint256 _minrequiredreports) public owneronly {
        minrequiredreports = _minrequiredreports;
    }

    
    function setreporter(address _reporter, bool _active) public owneronly {
        reporters[_reporter] = _active;
    }

    
    function enablextransfers(bool _enable) public owneronly {
        xtransfersenabled = _enable;
    }

    
    function enablereporting(bool _enable) public owneronly {
        reportingenabled = _enable;
    }

    
    function disableregistryupdate(bool _disable) public owneronly {
        allowregistryupdate = !_disable;
    }

    
    function updateregistry() public {
        
        require(allowregistryupdate || msg.sender == owner);

        
        address newregistry = registry.addressof(contractids.contract_registry);

        
        require(newregistry != address(registry) && newregistry != address(0));

        
        prevregistry = registry;
        registry = icontractregistry(newregistry);
    }

    
    function restoreregistry() public owneronly {
        
        registry = prevregistry;

        
        allowregistryupdate = false;
    }

    
    function upgrade(address[] _reporters) public owneronly {
        ibancorxupgrader bancorxupgrader = ibancorxupgrader(registry.addressof(contractids.bancor_x_upgrader));

        transferownership(bancorxupgrader);
        bancorxupgrader.upgrade(version, _reporters);
        acceptownership();
    }

    
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount) public whenxtransfersenabled {
        
        uint256 currentlocklimit = getcurrentlocklimit();

        
        require(_amount >= minlimit && _amount <= currentlocklimit);
        
        locktokens(_amount);

        
        prevlocklimit = currentlocklimit.sub(_amount);
        prevlockblocknumber = block.number;

        
        emit xtransfer(msg.sender, _toblockchain, _to, _amount, 0);
    }

    
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount, uint256 _id) public whenxtransfersenabled {
        
        uint256 currentlocklimit = getcurrentlocklimit();

        
        require(_amount >= minlimit && _amount <= currentlocklimit);
        
        locktokens(_amount);

        
        prevlocklimit = currentlocklimit.sub(_amount);
        prevlockblocknumber = block.number;

        
        emit xtransfer(msg.sender, _toblockchain, _to, _amount, _id);
    }

    
    function reporttx(
        bytes32 _fromblockchain,
        uint256 _txid,
        address _to,
        uint256 _amount,
        uint256 _xtransferid 
    )
        public
        isreporter
        whenreportingenabled
    {
        
        require(!reportedtxs[_txid][msg.sender]);

        
        reportedtxs[_txid][msg.sender] = true;

        transaction storage txn = transactions[_txid];

        
        if (txn.numofreports == 0) {
            txn.to = _to;
            txn.amount = _amount;
            txn.fromblockchain = _fromblockchain;

            if (_xtransferid != 0) {
                
                require(transactionids[_xtransferid] == 0);
                transactionids[_xtransferid] = _txid;
            }
        } else {
            
            require(txn.to == _to && txn.amount == _amount && txn.fromblockchain == _fromblockchain);
            
            if (_xtransferid != 0) {
                require(transactionids[_xtransferid] == _txid);
            }
        }
        
        
        txn.numofreports++;

        emit txreport(msg.sender, _fromblockchain, _txid, _to, _amount, _xtransferid);

        
        if (txn.numofreports >= minrequiredreports) {
            require(!transactions[_txid].completed);

            
            transactions[_txid].completed = true;

            emit xtransfercomplete(_to, _xtransferid);

            releasetokens(_to, _amount);
        }
    }

    
    function getxtransferamount(uint256 _xtransferid, address _for) public view returns (uint256) {
        
        transaction storage transaction = transactions[transactionids[_xtransferid]];

        
        require(transaction.to == _for);

        return transaction.amount;
    }

    
    function getcurrentlocklimit() public view returns (uint256) {
        
        uint256 currentlocklimit = prevlocklimit.add(((block.number).sub(prevlockblocknumber)).mul(limitincperblock));
        if (currentlocklimit > maxlocklimit)
            return maxlocklimit;
        return currentlocklimit;
    }
 
    
    function getcurrentreleaselimit() public view returns (uint256) {
        
        uint256 currentreleaselimit = prevreleaselimit.add(((block.number).sub(prevreleaseblocknumber)).mul(limitincperblock));
        if (currentreleaselimit > maxreleaselimit)
            return maxreleaselimit;
        return currentreleaselimit;
    }

    
    function locktokens(uint256 _amount) private {
        if (issmarttoken)
            ismarttokencontroller(ismarttoken(token).owner()).claimtokens(msg.sender, _amount);
        else
            token.transferfrom(msg.sender, address(this), _amount);
        emit tokenslock(msg.sender, _amount);
    }

    
    function releasetokens(address _to, uint256 _amount) private {
        
        uint256 currentreleaselimit = getcurrentreleaselimit();

        require(_amount >= minlimit && _amount <= currentreleaselimit);
        
        
        prevreleaselimit = currentreleaselimit.sub(_amount);
        prevreleaseblocknumber = block.number;

        
        token.transfer(_to, _amount);

        emit tokensrelease(_to, _amount);
    }
}