pragma solidity ^0.4.4;

contract safemath {
     function safemul(uint a, uint b) internal returns (uint) {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safesub(uint a, uint b) internal returns (uint) {
          assert(b <= a);
          return a  b;
     }

     function safeadd(uint a, uint b) internal returns (uint) {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }

     function assert(bool assertion) internal {
          if (!assertion) throw;
     }
}

contract erc20token {
     function balanceof(address _address) constant returns (uint balance);
     function transfer(address _to, uint _value) returns (bool success);
}

contract ledger is safemath {
     
     address public mainaddress;
     address public wheretosendfee;

     mapping (address => mapping(uint => address)) lrsperuser;
     mapping (address => uint) lrscountperuser;

     uint public totallrcount = 0;
     mapping (uint => address) lrs;

     modifier byanyone(){
          _;
     }

     function ledger(address wheretosendfee_){
          mainaddress = msg.sender;
          wheretosendfee = wheretosendfee_;
     }

     
     function createnewlendingrequest()payable byanyone returns(address out){
          
          
          uint feeamount = 100000000000000000;
          if(msg.value<feeamount){
               throw;
          }

          if(!wheretosendfee.call.gas(200000).value(feeamount)()){
               throw;
          }

          
          
          out = new lendingrequest(mainaddress,msg.sender);

          
          uint currentcount = lrscountperuser[msg.sender];
          lrsperuser[msg.sender][currentcount] = out;
          lrscountperuser[msg.sender]++;

          lrs[totallrcount] = out;
          totallrcount++;
     }

     function getlrcount()constant returns(uint out){
          out = totallrcount;
          return;
     }

     function getlr(uint index) constant returns (address out){
          out = lrs[index];
          return;
     }

     function getlrcountforuser(address a)constant returns(uint out){
          out = lrscountperuser[a];
          return;
     }

     function getlrforuser(address a,uint index) constant returns (address out){
          out = lrsperuser[a][index];
          return;
     }

     function() payable{
          createnewlendingrequest();
     }
}

contract lendingrequest is safemath {
     string public name = ;

     address public ledger = 0x0;
     
     address public mainaddress = 0x0;

     enum state {
          waitingfordata,

          
          waitingfortokens,
          cancelled,

          
          waitingforlender,

          
          waitingforloan,

          
          funded,

          
          waitingforpayback,

          
          paybackreceived,

          default,

          
          finished
     }


     state public currentstate = state.waitingfordata;

     
     address public borrower = 0x0;
     uint public wanted_wei = 0;
     uint public token_amount = 0;
     uint public premium_wei = 0;
     string public token_name = ;
     string public token_infolink = ;
     address public token_smartcontract_address = 0x0;
     uint public days_to_lend = 0;

     
     address public lender = 0x0;

     modifier byanyone(){
          _;
     }

     modifier onlybyledger(){
          if(msg.sender!=ledger)
               throw;
          _;
     }

     modifier onlybymain(){
          if(msg.sender!=mainaddress)
               throw;
          _;
     }

     modifier byledgerormain(){
          if((msg.sender!=mainaddress) && (msg.sender!=ledger))
               throw;
          _;
     }

     modifier byledgermainorborrower(){
          if((msg.sender!=mainaddress) && (msg.sender!=ledger) && (msg.sender!=borrower))
               throw;
          _;
     }

     modifier onlybylender(){
          if(msg.sender!=lender)
               throw;
          _;
     }

     modifier onlyinstate(state state){
          if(currentstate!=state)
               throw;
          _;
     }

     function lendingrequest(address mainaddress_,address borrower_){
          ledger = msg.sender;

          mainaddress = mainaddress_;

          borrower = borrower_;
     }

     function changeledgeraddress(address new_)onlybyledger{
          ledger = new_;
     }

     function changemainaddress(address new_)onlybymain{
          mainaddress = new_;
     }

     function getstate()constant returns(state out){
          out = currentstate;
          return;
     }

     function getlender()constant returns(address out){
          out = lender;
     }


          string token_name_, string token_infolink_, address token_smartcontract_address_, uint days_to_lend_)
               byledgermainorborrower onlyinstate(state.waitingfordata)
     {
          wanted_wei = wanted_wei_;
          premium_wei = premium_wei_;
          token_amount = token_amount_;
          token_name = token_name_;
          token_infolink = token_infolink_;
          token_smartcontract_address = token_smartcontract_address_;
          days_to_lend = days_to_lend_;

          currentstate = state.waitingfortokens;
     }

     function cancell() byledgermainorborrower {
          
          if((currentstate!=state.waitingfordata) && (currentstate!=state.waitingforlender))
               throw;

          if(currentstate==state.waitingforlender){
               
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(borrower,tokenbalance);
          }
          currentstate = state.cancelled;
     }

     
     function checktokens()byledgermainorborrower onlyinstate(state.waitingfortokens){
          erc20token token = erc20token(token_smartcontract_address);

          uint tokenbalance = token.balanceof(this);
          if(tokenbalance >= token_amount){
               
               
               currentstate = state.waitingforlender;
          }
     }

     
     
     
     
     
     function() payable {
          if(currentstate==state.waitingforlender){
               waitingforlender();
          }else if(currentstate==state.waitingforpayback){
               waitingforpayback();
          }
     }

     function waitingforlender()payable onlyinstate(state.waitingforlender){
          if(msg.value<wanted_wei){
               throw;
          }

          
          lender = msg.sender;

          
          
          if(!borrower.call.gas(200000).value(wanted_wei)()){
               throw;
          }
          currentstate = state.waitingforpayback;
     }

     
     function waitingforpayback()payable onlyinstate(state.waitingforpayback){
          if(msg.value<safeadd(wanted_wei,premium_wei)){
               throw;
          }

          
          
          if(!lender.call.gas(200000).value(msg.value)()){
               throw;
          }

          
          erc20token token = erc20token(token_smartcontract_address);
          uint tokenbalance = token.balanceof(this);
          token.transfer(borrower,tokenbalance);

          
          currentstate = state.finished;
     }

     
     
     function requestdefault()onlybylender onlyinstate(state.waitingforpayback){
          

          currentstate = state.default;
     }
}