pragma solidity ^0.4.24;











import ;

contract controlled {
    
    
    modifier onlycontroller {
        require(msg.sender == controller);
        _;
    }

    address public controller;

    function controlled()  public { controller = msg.sender;}

    
    
    function changecontroller(address _newcontroller) onlycontroller  public {
        controller = _newcontroller;
    }
}

contract approveandcallfallback {
    function receiveapproval(
        address from,
        uint256 _amount,
        address _token,
        bytes _data
    ) public;
}




contract minimetoken is controlled {

    string public name;                
    uint8 public decimals;             
    string public symbol;              
    string public version = ; 


    
    
    
    struct checkpoint {

        
        uint128 fromblock;

        
        uint128 value;
    }

    
    
    minimetoken public parenttoken;

    
    
    uint public parentsnapshotblock;

    
    uint public creationblock;

    
    
    
    mapping (address => checkpoint[]) balances;

    
    mapping (address => mapping (address => uint256)) allowed;

    
    checkpoint[] totalsupplyhistory;

    
    bool public transfersenabled;

    
    minimetokenfactory public tokenfactory;





    
    
    
    
    
    
    
    
    
    
    
    
    
    function minimetoken(
        minimetokenfactory _tokenfactory,
        minimetoken _parenttoken,
        uint _parentsnapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    )  public
    {
        tokenfactory = _tokenfactory;
        name = _tokenname;                                 
        decimals = _decimalunits;                          
        symbol = _tokensymbol;                             
        parenttoken = _parenttoken;
        parentsnapshotblock = _parentsnapshotblock;
        transfersenabled = _transfersenabled;
        creationblock = block.number;
    }






    
    
    
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersenabled);
        return dotransfer(msg.sender, _to, _amount);
    }

    
    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        
        
        
        
        if (msg.sender != controller) {
            require(transfersenabled);

            
            if (allowed[_from][msg.sender] < _amount)
                return false;
            allowed[_from][msg.sender] = _amount;
        }
        return dotransfer(_from, _to, _amount);
    }

    
    
    
    
    
    
    function dotransfer(address _from, address _to, uint _amount) internal returns(bool) {
        if (_amount == 0) {
            return true;
        }
        require(parentsnapshotblock < block.number);
        
        require((_to != 0) && (_to != address(this)));
        
        
        var previousbalancefrom = balanceofat(_from, block.number);
        if (previousbalancefrom < _amount) {
            return false;
        }
        
        if (iscontract(controller)) {
            
            require(itokencontroller(controller).ontransfer(_from, _to, _amount) == true);
        }
        
        
        updatevalueatnow(balances[_from], previousbalancefrom  _amount);
        
        
        var previousbalanceto = balanceofat(_to, block.number);
        require(previousbalanceto + _amount >= previousbalanceto); 
        updatevalueatnow(balances[_to], previousbalanceto + _amount);
        
        transfer(_from, _to, _amount);
        return true;
    }

    
    
    function balanceof(address _owner) public constant returns (uint256 balance) {
        return balanceofat(_owner, block.number);
    }

    
    
    
    
    
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersenabled);

        
        
        
        
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        
        if (iscontract(controller)) {
            
            require(itokencontroller(controller).onapprove(msg.sender, _spender, _amount) == true);
        }

        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    
    
    
    
    
    
    function approveandcall(approveandcallfallback _spender, uint256 _amount, bytes _extradata) public returns (bool success) {
        require(approve(_spender, _amount));

        _spender.receiveapproval(
            msg.sender,
            _amount,
            this,
            _extradata
        );

        return true;
    }

    
    
    function totalsupply() public constant returns (uint) {
        return totalsupplyat(block.number);
    }






    
    
    
    
    function balanceofat(address _owner, uint _blocknumber) public constant returns (uint) {

        
        
        
        
        
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.balanceofat(_owner, min(_blocknumber, parentsnapshotblock));
            } else {
                
                return 0;
            }

        
        } else {
            return getvalueat(balances[_owner], _blocknumber);
        }
    }

    
    
    
    function totalsupplyat(uint _blocknumber) public constant returns(uint) {

        
        
        
        
        
        if ((totalsupplyhistory.length == 0) || (totalsupplyhistory[0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.totalsupplyat(min(_blocknumber, parentsnapshotblock));
            } else {
                return 0;
            }

        
        } else {
            return getvalueat(totalsupplyhistory, _blocknumber);
        }
    }





    
    
    
    
    
    
    
    
    
    
    function createclonetoken(
        string _clonetokenname,
        uint8 _clonedecimalunits,
        string _clonetokensymbol,
        uint _snapshotblock,
        bool _transfersenabled
    ) public returns(minimetoken)
    {
        uint256 snapshot = _snapshotblock == 0 ? block.number  1 : _snapshotblock;

        minimetoken clonetoken = tokenfactory.createclonetoken(
            this,
            snapshot,
            _clonetokenname,
            _clonedecimalunits,
            _clonetokensymbol,
            _transfersenabled
        );

        clonetoken.changecontroller(msg.sender);

        
        newclonetoken(address(clonetoken), snapshot);
        return clonetoken;
    }





    
    
    
    
    function generatetokens(address _owner, uint _amount) onlycontroller public returns (bool) {
        uint curtotalsupply = totalsupply();
        require(curtotalsupply + _amount >= curtotalsupply); 
        uint previousbalanceto = balanceof(_owner);
        require(previousbalanceto + _amount >= previousbalanceto); 
        updatevalueatnow(totalsupplyhistory, curtotalsupply + _amount);
        updatevalueatnow(balances[_owner], previousbalanceto + _amount);
        transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroytokens(address _owner, uint _amount) onlycontroller public returns (bool) {
        uint curtotalsupply = totalsupply();
        require(curtotalsupply >= _amount);
        uint previousbalancefrom = balanceof(_owner);
        require(previousbalancefrom >= _amount);
        updatevalueatnow(totalsupplyhistory, curtotalsupply  _amount);
        updatevalueatnow(balances[_owner], previousbalancefrom  _amount);
        transfer(_owner, 0, _amount);
        return true;
    }






    
    
    function enabletransfers(bool _transfersenabled) onlycontroller public {
        transfersenabled = _transfersenabled;
    }





    
    
    
    
    function getvalueat(checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {
        if (checkpoints.length == 0)
            return 0;

        
        if (_block >= checkpoints[checkpoints.length1].fromblock)
            return checkpoints[checkpoints.length1].value;
        if (_block < checkpoints[0].fromblock)
            return 0;

        
        uint min = 0;
        uint max = checkpoints.length1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromblock<=_block) {
                min = mid;
            } else {
                max = mid1;
            }
        }
        return checkpoints[min].value;
    }

    
    
    
    
    function updatevalueatnow(checkpoint[] storage checkpoints, uint _value) internal {
        require(_value <= uint128(1));

        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length  1].fromblock < block.number)) {
            checkpoint storage newcheckpoint = checkpoints[checkpoints.length++];
            newcheckpoint.fromblock = uint128(block.number);
            newcheckpoint.value = uint128(_value);
        } else {
            checkpoint storage oldcheckpoint = checkpoints[checkpoints.length  1];
            oldcheckpoint.value = uint128(_value);
        }
    }

    
    
    
    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0)
            return false;

        assembly {
            size := extcodesize(_addr)
        }

        return size>0;
    }

    
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    
    
    
    function () external payable {
        require(iscontract(controller));
        
        require(itokencontroller(controller).proxypayment.value(msg.value)(msg.sender) == true);
    }





    
    
    
    
    function claimtokens(address _token) onlycontroller public {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        minimetoken token = minimetoken(_token);
        uint balance = token.balanceof(this);
        token.transfer(controller, balance);
        claimedtokens(_token, controller, balance);
    }




    event claimedtokens(address indexed _token, address indexed _controller, uint _amount);
    event transfer(address indexed _from, address indexed _to, uint256 _amount);
    event newclonetoken(address indexed _clonetoken, uint _snapshotblock);
    event approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}









contract minimetokenfactory {
    event newfactoryclonetoken(address indexed _clonetoken, address indexed _parenttoken, uint _snapshotblock);

    
    
    
    
    
    
    
    
    
    
    function createclonetoken(
        minimetoken _parenttoken,
        uint _snapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    ) public returns (minimetoken)
    {
        minimetoken newtoken = new minimetoken(
            this,
            _parenttoken,
            _snapshotblock,
            _tokenname,
            _decimalunits,
            _tokensymbol,
            _transfersenabled
        );

        newtoken.changecontroller(msg.sender);
        newfactoryclonetoken(address(newtoken), address(_parenttoken), _snapshotblock);
        return newtoken;
    }
}