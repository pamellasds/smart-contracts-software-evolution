pragma solidity ^0.4.6;










import ;




contract owned {
    
    
    modifier onlyowner { if (msg.sender != owner) throw; _; }

    address public owner;

    
    function owned() { owner = msg.sender;}

    
    
    
    function changeowner(address _newowner) onlyowner {
        owner = _newowner;
    }
}






contract campaign is tokencontroller, owned {

    uint public startfundingtime;       
    uint public endfundingtime;         
    uint public maximumfunding;         
    uint public totalcollected;         
    minimetoken public tokencontract;   
    address public vaultaddress;        













    function campaign(
        uint _startfundingtime,
        uint _endfundingtime,
        uint _maximumfunding,
        address _vaultaddress,
        address _tokenaddress
    ) {
        if ((_endfundingtime < now) ||                
            (_endfundingtime <= _startfundingtime) ||
            (_maximumfunding > 10000 ether) ||        
            (_vaultaddress == 0))                     
            {
            throw;
            }
        startfundingtime = _startfundingtime;
        endfundingtime = _endfundingtime;
        maximumfunding = _maximumfunding;
        tokencontract = minimetoken(_tokenaddress);
        vaultaddress = _vaultaddress;
    }






    function ()  payable {
        dopayment(msg.sender);
    }









    function proxypayment(address _owner) payable returns(bool) {
        dopayment(_owner);
        return true;
    }







    function ontransfer(address _from, address _to, uint _amount) returns(bool) {
        return true;
    }







    function onapprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }







    function dopayment(address _owner) internal {


        if ((now<startfundingtime) ||
            (now>endfundingtime) ||
            (tokencontract.controller() == 0) ||           
            (msg.value == 0) ||
            (totalcollected + msg.value > maximumfunding))
        {
            throw;
        }


        totalcollected += msg.value;


        if (!vaultaddress.send(msg.value)) {
            throw;
        }



        if (!tokencontract.generatetokens(_owner, msg.value)) {
            throw;
        }

        return;
    }






    function finalizefunding() {
        if (now < endfundingtime) throw;
        tokencontract.changecontroller(0);
    }





    function setvault(address _newvaultaddress) onlyowner {
        vaultaddress = _newvaultaddress;
    }

}
