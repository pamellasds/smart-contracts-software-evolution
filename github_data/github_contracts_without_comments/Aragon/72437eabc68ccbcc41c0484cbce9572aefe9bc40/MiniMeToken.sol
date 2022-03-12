pragma solidity ^0.4.6;













contract tokencontroller {
    
    
    
    function proxypayment(address _owner) payable returns(bool);

    
    
    
    
    
    
    function ontransfer(address _from, address _to, uint _amount) returns(bool);

    
    
    
    
    
    
    function onapprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract controlled {
    
    
    modifier onlycontroller { if (msg.sender != controller) throw; _; }

    address public controller;

    function controlled() { controller = msg.sender;}

    
    
    function changecontroller(address _newcontroller) onlycontroller {
        controller = _newcontroller;
    }
}




contract minimetoken is controlled {

    string public name;                
    uint8 public decimals;             
    string public symbol;              
    string public version = ; 


    
    
    
    struct  checkpoint {

        
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
        address _tokenfactory,
        address _parenttoken,
        uint _parentsnapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    ) {
        tokenfactory = minimetokenfactory(_tokenfactory);
        name = _tokenname;                                 
        decimals = _decimalunits;                          
        symbol = _tokensymbol;                             
        parenttoken = minimetoken(_parenttoken);
        transfersenabled = _transfersenabled;
        creationblock = block.number;
    }






    
    
    
    
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (!transfersenabled) throw;
        return dotransfer(msg.sender, _to, _amount);
    }

    
    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        
        
        
        
        if (msg.sender != controller) {
            if (!transfersenabled) throw;

            
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] = _amount;
        }
        return dotransfer(_from, _to, _amount);
    }

    
    
    
    
    
    
    function dotransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           
           if ((_to == 0) || (_to == address(this))) throw;

           
           
           var previousbalancefrom = balanceofat(_from, block.number);
           if (previousbalancefrom < _amount) {
               return false;
           }

           
           if (iscontract(controller)) {
               if (!tokencontroller(controller).ontransfer(_from, _to, _amount))
               throw;
           }

           
           
           updatevalueatnow(balances[_from], previousbalancefrom  _amount);

           
           
           var previousbalanceto = balanceofat(_to, block.number);
           updatevalueatnow(balances[_to], previousbalanceto + _amount);

           
           transfer(_from, _to, _amount);

           return true;
    }

    
    
    function balanceof(address _owner) constant returns (uint256 balance) {
        return balanceofat(_owner, block.number);
    }

    
    
    
    
    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        if (!transfersenabled) throw;

        
        
        
        
        if ((_amount!=0) && (allowed[msg.sender][_spender] !=0)) throw;

        
        if (iscontract(controller)) {
            if (!tokencontroller(controller).onapprove(msg.sender, _spender, _amount))
                throw;
        }

        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    
    
    
    
    
    
    function approveandcall(address _spender, uint256 _amount, bytes _extradata
    ) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);

        
        
        
        
        
        
        if(!_spender.call(
            bytes4(bytes32(sha3())),
            msg.sender,
            _amount,
            this,
            _extradata
            )) { throw;
        }
        return true;
    }

    
    
    function totalsupply() constant returns (uint) {
        return totalsupplyat(block.number);
    }






    
    
    
    
    function balanceofat(address _owner, uint _blocknumber) constant
        returns (uint) {

        
        
        if (_blocknumber < creationblock) {
            return 0;

        
        
        
        
        
        } else if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.balanceofat(_owner, parentsnapshotblock);
            } else {
                
                return 0;
            }

        
        } else {
            return getvalueat(balances[_owner], _blocknumber);
        }

    }

    
    
    
    function totalsupplyat(uint _blocknumber) constant returns(uint) {

        
        
        if (_blocknumber < creationblock) {
            return 0;

        
        
        
        
        
        } else if ((totalsupplyhistory.length == 0)
            || (totalsupplyhistory[0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.totalsupplyat(parentsnapshotblock);
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
        ) returns(address) {
        if (_snapshotblock > block.number) _snapshotblock = block.number;
        minimetoken clonetoken = tokenfactory.createclonetoken(
            this,
            _snapshotblock,
            _clonetokenname,
            _clonedecimalunits,
            _clonetokensymbol,
            _transfersenabled
            );

        clonetoken.changecontroller(msg.sender);

        
        newclonetoken(address(clonetoken), _snapshotblock);
        return address(clonetoken);
    }





    
    
    
    
    function generatetokens(address _owner, uint _amount
    ) onlycontroller returns (bool) {
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        updatevalueatnow(totalsupplyhistory, curtotalsupply + _amount);
        var previousbalanceto = balanceof(_owner);
        updatevalueatnow(balances[_owner], previousbalanceto + _amount);
        transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroytokens(address _owner, uint _amount
    ) onlycontroller returns (bool) {
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        if (curtotalsupply < _amount) throw;
        updatevalueatnow(totalsupplyhistory, curtotalsupply  _amount);
        var previousbalancefrom = balanceof(_owner);
        if (previousbalancefrom < _amount) throw;
        updatevalueatnow(balances[_owner], previousbalancefrom  _amount);
        transfer(_owner, 0, _amount);
        return true;
    }






    
    
    function enabletransfers(bool _transfersenabled) onlycontroller {
        transfersenabled = _transfersenabled;
    }





    
    
    
    
    function getvalueat(checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        
        if (_block >= checkpoints[checkpoints.length1].fromblock)
            return checkpoints[checkpoints.length1].value;
        if (_block < checkpoints[0].fromblock) return 0;

        
        uint min = 0;
        uint max = checkpoints.length1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromblock<=_block) {
                min = mid;
            } else {
                max = mid1;
            }
        }
        return checkpoints[min].value;
    }

    
    
    
    
    function updatevalueatnow(checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length 1].fromblock < block.number)) {
               checkpoint newcheckpoint = checkpoints[ checkpoints.length++ ];
               newcheckpoint.fromblock =  uint128(block.number);
               newcheckpoint.value = uint128(_value);
           } else {
               checkpoint oldcheckpoint = checkpoints[checkpoints.length1];
               oldcheckpoint.value = uint128(_value);
           }
    }

    
    
    
    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    
    
    function ()  payable {
        if (iscontract(controller)) {
            if (! tokencontroller(controller).proxypayment.value(msg.value)(msg.sender))
                throw;
        } else {
            throw;
        }
    }





    event transfer(address indexed _from, address indexed _to, uint256 _amount);
    event newclonetoken(address indexed _clonetoken, uint _snapshotblock);
    event approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}









contract minimetokenfactory {

    
    
    
    
    
    
    
    
    
    
    function createclonetoken(
        address _parenttoken,
        uint _snapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _transfersenabled
    ) returns (minimetoken) {
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
        return newtoken;
    }
}
