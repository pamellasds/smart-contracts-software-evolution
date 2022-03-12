pragma solidity ^0.4.16;


library safemath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract erc20token {
     function balanceof(address who) public constant returns (uint256);
     function transfer(address to, uint256 value) public returns (bool);
     function allowance(address owner, address spender) public constant returns (uint256);
     function transferfrom(address from, address to, uint256 value) public returns (bool);
     function approve(address spender, uint256 value) public returns (bool);
}

contract reputationtokeninterface {
     function issuetokens(address foraddress, uint tokencount) returns (bool success);
     function burntokens(address foraddress) returns (bool success);
     function locktokens(address foraddress, uint tokencount) returns (bool success);
     function unlocktokens(address foraddress, uint tokencount) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function nonlockedtokenscount(address foraddress) constant returns (uint tokencount);
}

contract abstractens {
     function owner(bytes32 node) constant returns(address);
     function resolver(bytes32 node) constant returns(address);
     function ttl(bytes32 node) constant returns(uint64);
     function setowner(bytes32 node, address owner);
     function setsubnodeowner(bytes32 node, bytes32 label, address owner);
     function setresolver(bytes32 node, address resolver);
     function setttl(bytes32 node, uint64 ttl);
}

contract registrar {
     function transfer(bytes32, address);
}


contract ledger {     
     address public mainaddress;             
     address public wheretosendfee;          
     address public reptokenaddress;         
     address public ensregistryaddress;      
     address public registraraddress;        

     uint public totallrcount = 0;           
     uint public borrowerfeeamount = 0.01 ether; 

     mapping (address => mapping(uint => address)) lrsperuser; 
     mapping (address => uint) lrscountperuser;                
     mapping (uint => address) lrs;                            

     
     function ledger(address _wheretosendfee,     address _reptokenaddress, 
                     address _ensregistryaddress, address _registraraddress){
          mainaddress = msg.sender;
          wheretosendfee = _wheretosendfee;
          reptokenaddress = _reptokenaddress;
          ensregistryaddress = _ensregistryaddress;
          registraraddress = _registraraddress;
     }

     function getfeesum() constant returns(uint){ return borrowerfeeamount; }
     function getreptokenaddress() constant returns(address){ return reptokenaddress; }
     function getlrcount() constant returns(uint){ return totallrcount; }
     function getlr(uint _index) constant returns (address){ return lrs[_index]; }
     function getlrcountforuser(address _addr) constant returns(uint){ return lrscountperuser[_addr]; }
     function getlrforuser(address _addr, uint _index) constant returns (address){ return lrsperuser[_addr][_index]; }

     
     
     
     function createnewlendingrequest() payable returns(address){
          return newlr(0);
     }

     
     function createnewlendingrequestens() payable returns(address){
          return newlr(1);
     }
     
     function createnewlendingrequestrep() payable returns(address){
          return newlr(2);
     }

     function newlr(int _collateraltype) payable returns(address out){
          
          if(msg.value < borrowerfeeamount){
               revert();
          }

          wheretosendfee.transfer(borrowerfeeamount);

          
          
          out = new lendingrequest(msg.sender, _collateraltype);

          
          uint currentcount = lrscountperuser[msg.sender];
          lrsperuser[msg.sender][currentcount] = out;
          lrscountperuser[msg.sender]++;

          lrs[totallrcount] = out;
          totallrcount++;
     }


     function getlrfundedcount() constant returns(uint out){
          out = 0;

          for(uint i=0; i<totallrcount; ++i){
               lendingrequest lr = lendingrequest(lrs[i]);
               if(lr.getstate() == lendingrequest.state.waitingforpayback){
                    out++;
               }
          }

          return;
     }

     function getlrfunded(uint index) constant returns (address){          
          lendingrequest lr = lendingrequest(lrs[index]);
          if(lr.getstate() == lendingrequest.state.waitingforpayback){
               return lrs[index];
          } else {
               return 0;
          }
     }

     function addreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower() == _potentialborrower && address(this) == lr.creator()){
               uint reptokens = _weisum / 10;
               reptoken.issuetokens(_potentialborrower,reptokens);               
          }
     }

     function lockreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower() == _potentialborrower && address(this)==lr.creator()){
               uint reptokens = _weisum;
               reptoken.locktokens(_potentialborrower, reptokens);               
          }
     }

     function unlockreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);
          
          if(lr.borrower() == _potentialborrower && address(this)==lr.creator()){
               uint reptokens = _weisum;
               reptoken.unlocktokens(_potentialborrower, reptokens);               
          }
     }

     function burnreptokens(address _potentialborrower){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower() == _potentialborrower && address(this) == lr.creator()){
               reptoken.burntokens(_potentialborrower);               
          }
     }     

     function approvereptokens(address _potentialborrower,uint _weisum) returns (bool success){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          success = reptoken.nonlockedtokenscount(_potentialborrower) >= _weisum;
          return;             
     } 

     function() payable{
          createnewlendingrequest();
     }
}


contract lendingrequest {
     
     enum state {
          waitingfordata,     
          waitingfortokens,   
          cancelled,          
          waitingforlender,   
          waitingforpayback,  
          default,            
          finished            
     }

     
     enum type {
          tokenscollateral,   
          enscollateral,      
          repcollateral       
     }

     using safemath for uint256;               
     ledger ledger;                            
     address public creator            = 0x0;  
     address public registraraddress   = 0x0;  
     address public ensregistryaddress = 0x0;  
     address public mainaddress        = 0x0;  
     address public wheretosendfee     = 0x0;  

     uint public lenderfeeamount = 0.01 ether;            
     state public currentstate   = state.waitingfordata;  
     type public currenttype     = type.tokenscollateral; 

     

     
     address public borrower  = 0x0;                     
     uint public wanted_wei   = 0;                       
     uint public premium_wei  = 0;                       
     uint public token_amount = 0;                       
     uint public days_to_lend = 0;                       
     string public token_name = ;                      
     bytes32 public ens_domain_hash;                     
     string public token_infolink = ;                  
     address public token_smartcontract_address = 0x0;   
     

     
     uint public start     = 0;    
     address public lender = 0x0;  


     
     function isens() constant returns(bool){ return (currenttype==type.enscollateral); }
     function isrep() constant returns(bool){ return (currenttype==type.repcollateral); }
     function getstate() constant returns(state){ return currentstate; }
     function getlender() constant returns(address){ return lender; }     
     function getborrower() constant returns(address){ return borrower; }
     function getwantedwei() constant returns(uint){ return wanted_wei; }
     function gettokenname() constant returns(string){ return token_name; }
     function getdaystolen() constant returns(uint){ return days_to_lend; }
     function getpremiumwei() constant returns(uint){ return premium_wei; }
     function gettokenamount() constant returns(uint){ return token_amount; }     
     function gettokeninfolink() constant returns(string){ return token_infolink; }
     function getensdomainhash() constant returns(bytes32){ return ens_domain_hash; }
     function gettokensmartcontractaddress() constant returns(address){ return token_smartcontract_address; }
               
     
     modifier onlybyledger(){
          require(ledger(msg.sender) == ledger);
          _;
     }

     modifier onlybymain(){
          require(msg.sender == mainaddress);
          _;
     }

     modifier byledgerormain(){
          require(msg.sender == mainaddress || ledger(msg.sender) == ledger);
          _;
     }

     modifier byledgermainorborrower(){
          require(msg.sender == mainaddress || ledger(msg.sender) == ledger || msg.sender == borrower);
          _;
     }

     modifier onlybylender(){
          require(msg.sender == lender);
          _;
     }

     modifier onlyinstate(state state){
          require(currentstate == state);
          _;
     }

     function lendingrequest(address _borrower, int _collateraltype){
          creator = msg.sender;
          ledger = ledger(msg.sender);

          borrower = _borrower;
          mainaddress = ledger.mainaddress();
          wheretosendfee = ledger.wheretosendfee();
          registraraddress = ledger.registraraddress();
          ensregistryaddress = ledger.ensregistryaddress();
                    
          
          if (_collateraltype == 0){
               currenttype = type.tokenscollateral;
          } else if(_collateraltype == 1){
               currenttype = type.enscollateral;
          } else if(_collateraltype == 2){
               currenttype = type.repcollateral;
          } else {
               revert();
          }
          
     }

     function changeledgeraddress(address _new) onlybyledger{
          ledger = ledger(_new);
     }

     function changemainaddress(address _new) onlybymain{
          mainaddress = _new;
     }

     function setdata(uint _wanted_wei, uint _token_amount, uint _premium_wei,
                         string _token_name, string _token_infolink, address _token_smartcontract_address, 
                         uint _days_to_lend, bytes32 _ens_domain_hash) 
               byledgermainorborrower onlyinstate(state.waitingfordata)
     {
          wanted_wei = _wanted_wei;
          premium_wei = _premium_wei;
          token_amount = _token_amount; 
          token_name = _token_name;
          token_infolink = _token_infolink;
          token_smartcontract_address = _token_smartcontract_address;
          days_to_lend = _days_to_lend;
          ens_domain_hash = _ens_domain_hash;

          if(currenttype == type.repcollateral){
               if(ledger.approvereptokens(borrower, wanted_wei)){
                    ledger.lockreptokens(borrower, wanted_wei);
                    currentstate = state.waitingforlender;
               }
          } else {
               currentstate = state.waitingfortokens;
          }
     }

     function cancell() byledgermainorborrower {
          
          if((currentstate != state.waitingfordata) && (currentstate != state.waitingforlender))
               revert();

          if(currentstate == state.waitingforlender){
               
               releasetoborrower();
          }
          currentstate = state.cancelled;
     }

     
     function checktokens() byledgermainorborrower onlyinstate(state.waitingfortokens){
          if(currenttype != type.tokenscollateral){
               revert();
          }

          erc20token token = erc20token(token_smartcontract_address);

          uint tokenbalance = token.balanceof(this);
          if(tokenbalance >= token_amount){
               
               
               currentstate = state.waitingforlender;
          }
     }

     function checkdomain() onlyinstate(state.waitingfortokens){
          
          abstractens ens = abstractens(ensregistryaddress);
          if(ens.owner(ens_domain_hash)==address(this)){
               
               
               currentstate = state.waitingforlender;
               return;
          }
     }

     
     
     
     
     
     function() payable {
          if(currentstate == state.waitingforlender){
               waitingforlender();
          } else if(currentstate == state.waitingforpayback){
               waitingforpayback();
          } else {
               revert(); 
          }
     }

     
     function returntokens() byledgermainorborrower onlyinstate(state.waitingforlender){
          
          releasetoborrower();
          currentstate = state.finished;
     }

     function waitingforlender() payable onlyinstate(state.waitingforlender){
          if(msg.value < wanted_wei.add(lenderfeeamount)){
               revert();
          }

          
          wheretosendfee.transfer(lenderfeeamount);

          
          lender = msg.sender;     

          
          
          borrower.transfer(wanted_wei);

          currentstate = state.waitingforpayback;

          start = now;
     }

     
     
     
     
     function waitingforpayback() payable onlyinstate(state.waitingforpayback){
          if(msg.value < wanted_wei.add(premium_wei)){
               revert();
          }
          
          lender.transfer(msg.value);

          releasetoborrower(); 
          ledger.addreptokens(borrower,wanted_wei);
          currentstate = state.finished; 
     }

     
     function getneededsumbylender() constant returns(uint){
          return wanted_wei.add(lenderfeeamount);
     }

     
     function getneededsumbyborrower()constant returns(uint){
          return wanted_wei.add(premium_wei);
     }

     
     
     function requestdefault() onlyinstate(state.waitingforpayback){
          if(now < (start + days_to_lend * 1 days)){
               revert();
          }

          releasetolender(); 
          
          currentstate = state.default; 
     }

     function releasetolender() internal {
    
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               registrar registrar = registrar(registraraddress);

               ens.setowner(ens_domain_hash,lender);
               registrar.transfer(ens_domain_hash,lender);

          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(lender,tokenbalance);
          }

          ledger.burnreptokens(borrower);
     }

     function releasetoborrower() internal {
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               registrar registrar = registrar(registraraddress);
               ens.setowner(ens_domain_hash,borrower);
               registrar.transfer(ens_domain_hash,borrower);

          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(borrower,tokenbalance);
          }
     }
}

