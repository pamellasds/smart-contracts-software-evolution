pragma solidity ^0.4.11;

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

     
     event newowner(bytes32 indexed node, bytes32 indexed label, address owner);

     
     event transfer(bytes32 indexed node, address owner);

     
     event newresolver(bytes32 indexed node, address resolver);

     
     event newttl(bytes32 indexed node, uint64 ttl);
}

contract ledger is safemath {
     
     address public mainaddress;
     address public wheretosendfee;
     address public reptokenaddress;
     address public ensregistryaddress;

     mapping (address => mapping(uint => address)) lrsperuser;
     mapping (address => uint) lrscountperuser;

     uint public totallrcount = 0;
     mapping (uint => address) lrs;

     
     uint public borrowerfeeamount = 10000000000000000;

     modifier byanyone(){
          _;
     }

     function ledger(address wheretosendfee_,address reptokenaddress_,address ensregistryaddress_){
          mainaddress = msg.sender;
          wheretosendfee = wheretosendfee_;
          reptokenaddress = reptokenaddress_;
          ensregistryaddress = ensregistryaddress_;
     }

     function getreptokenaddress()constant returns(address out){
          out = reptokenaddress;
          return;
     }

     function getfeesum()constant returns(uint out){
          out = borrowerfeeamount;
          return;
     }

     
     
     function createnewlendingrequest()payable byanyone returns(address out){
          out = newlr(0);
     }

     
     function createnewlendingrequestens()payable byanyone returns(address out){
          out = newlr(1);
     }
     
     function createnewlendingrequestrep()payable byanyone returns(address out){
          out = newlr(2);
     }

     function newlr(int collateraltype)payable byanyone returns(address out){
          
          uint feeamount = borrowerfeeamount;
          if(msg.value<feeamount){
               throw;
          }

          if(!wheretosendfee.call.gas(200000).value(feeamount)()){
               throw;
          }

          
          

          out = new lendingrequest(mainaddress,msg.sender,wheretosendfee,collateraltype,ensregistryaddress);

          
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

     function getlrfundedcount()constant returns(uint out){
          out = 0;

          for(uint i=0; i<totallrcount; ++i){
               lendingrequest lr = lendingrequest(lrs[i]);
               if(lr.getstate()==lendingrequest.state.waitingforpayback){
                    out++;
               }
          }

          return;
     }

     function getlrfunded(uint index) constant returns (address out){
          uint indexfound = 0;
          for(uint i=0; i<totallrcount; ++i){
               lendingrequest lr = lendingrequest(lrs[i]);
               if(lr.getstate()==lendingrequest.state.waitingforpayback){
                    if(indexfound==index){
                         out = lrs[i];
                         return;
                    }

                    indexfound++;
               }
          }
          return;
     }

     function addreptokens(address potentialborrower, uint weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower()==potentialborrower && address(this)==lr.creator()){
               uint reptokens = (weisum/10);
               reptoken.issuetokens(potentialborrower,reptokens);               
          }
     }

     function lockreptokens(address potentialborrower, uint weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower()==potentialborrower && address(this)==lr.creator()){
               uint reptokens = (weisum/10);
               reptoken.locktokens(potentialborrower,reptokens);               
          }
     }

     function unlockreptokens(address potentialborrower, uint weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);
          
          if(lr.borrower()==potentialborrower && address(this)==lr.creator()){
               uint reptokens = (weisum/10);
               reptoken.unlocktokens(potentialborrower,reptokens);               
          }
     }

     function burnreptokens(address potentialborrower){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  
          
          if(lr.borrower()==potentialborrower && address(this)==lr.creator()){
               reptoken.burntokens(potentialborrower);               
          }
     }     

     function approvereptokens(address potentialborrower,uint weisum) returns (bool success){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          success = reptoken.nonlockedtokenscount(potentialborrower) >= weisum;
          return;             
     } 

     function() payable{
          createnewlendingrequest();
     }
}

contract lendingrequest is safemath {
     string public name = ;
     address public creator = 0x0;

     
     uint public lenderfeeamount   = 10000000000000000;
     
     ledger ledger;

     
     address public mainaddress = 0x0;


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


     state public currentstate = state.waitingfordata;

     type public currenttype = type.tokenscollateral;

     address public wheretosendfee = 0x0;
     uint public start = 0;

     
     address public borrower = 0x0;
     uint public wanted_wei = 0;
     uint public token_amount = 0;
     uint public premium_wei = 0;
     string public token_name = ;
     bytes32 public ens_domain_hash; 
     string public token_infolink = ;
     address public token_smartcontract_address = 0x0;
     uint public days_to_lend = 0;

     
     address public ensregistryaddress = 0;

     address public lender = 0x0;

     function getborrower()constant returns(address out){
          out = borrower;
     }

     function getwantedwei()constant returns(uint out){
          out = wanted_wei;
     }

     function getpremiumwei()constant returns(uint out){
          out = premium_wei;
     }

     function gettokenamount()constant returns(uint out){
          out = token_amount;
     }

     function gettokenname()constant returns(string out){
          out = token_name;
     }

     function gettokeninfolink()constant returns(string out){
          out = token_infolink;
     }

     function gettokensmartcontractaddress()constant returns(address out){
          out = token_smartcontract_address;
     }

     function getdaystolen()constant returns(uint out){
          out = days_to_lend;
     }
     
     function getstate()constant returns(state out){
          out = currentstate;
          return;
     }

     function getlender()constant returns(address out){
          out = lender;
     }

     function isens()constant returns(bool out){
          out = (currenttype==type.enscollateral);
     }

     function isrep()constant returns(bool out){
          out = (currenttype==type.repcollateral);
     }


     function getensdomainhash()constant returns(bytes32 out){
          out = ens_domain_hash;
     }


     modifier byanyone(){
          _;
     }

     modifier onlybyledger(){
          if(ledger(msg.sender)!=ledger)
               throw;
          _;
     }

     modifier onlybymain(){
          if(msg.sender!=mainaddress)
               throw;
          _;
     }

     modifier byledgerormain(){
          if((msg.sender!=mainaddress) && (ledger(msg.sender)!=ledger))
               throw;
          _;
     }

     modifier byledgermainorborrower(){
          if((msg.sender!=mainaddress) && (ledger(msg.sender)!=ledger) && (msg.sender!=borrower))
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

     function lendingrequest(address mainaddress_,address borrower_,address wheretosendfee_, int contracttype, address ensregistryaddress_){
          ledger = ledger(msg.sender);

          mainaddress = mainaddress_;
          wheretosendfee = wheretosendfee_;
          borrower = borrower_;
          creator = msg.sender;
          
          if      (contracttype==0){
               currenttype = type.tokenscollateral;
          }else if(contracttype==1){
               currenttype = type.enscollateral;
          }else if(contracttype==2){
               currenttype = type.repcollateral;
          } else {
               throw;
          }

          ensregistryaddress = ensregistryaddress_;
     }

     function changeledgeraddress(address new_)onlybyledger{
          ledger = ledger(new_);
     }

     function changemainaddress(address new_)onlybymain{
          mainaddress = new_;
     }


     function setdata(uint wanted_wei_, uint token_amount_, uint premium_wei_,
          string token_name_, string token_infolink_, address token_smartcontract_address_, uint days_to_lend_, bytes32 ens_domain_hash_) 
               byledgermainorborrower onlyinstate(state.waitingfordata)
     {
          wanted_wei = wanted_wei_;
          premium_wei = premium_wei_;
          token_amount = token_amount_; 
          token_name = token_name_;
          token_infolink = token_infolink_;
          token_smartcontract_address = token_smartcontract_address_;
          days_to_lend = days_to_lend_;
          ens_domain_hash = ens_domain_hash_;

          if(currenttype==type.repcollateral){
               if(ledger.approvereptokens(borrower, wanted_wei)){
                    ledger.lockreptokens(borrower, wanted_wei);
                    currentstate = state.waitingforlender;
               }
          } else {
               currentstate = state.waitingfortokens;
          }
     }

     function cancell() byledgermainorborrower {
          
          if((currentstate!=state.waitingfordata) && (currentstate!=state.waitingforlender))
               throw;

          if(currentstate==state.waitingforlender){
               
               releasetoborrower();
          }
          currentstate = state.cancelled;
     }

     
     function checktokens()byledgermainorborrower onlyinstate(state.waitingfortokens){
          if(currenttype!=type.tokenscollateral){
               throw;
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
          if(currentstate==state.waitingforlender){
               waitingforlender();
          }else if(currentstate==state.waitingforpayback){
               waitingforpayback();
          }
     }

     
     function returntokens() byledgermainorborrower onlyinstate(state.waitingforlender){
          
          releasetoborrower();
          currentstate = state.finished;
     }

     function waitingforlender()payable onlyinstate(state.waitingforlender){
          if(msg.value<safeadd(wanted_wei,lenderfeeamount)){
               throw;
          }

          
          if(!wheretosendfee.call.gas(200000).value(lenderfeeamount)()){
               throw;
          }

          
          lender = msg.sender;     

          
          
          if(!borrower.call.gas(200000).value(wanted_wei)()){
               throw;
          }

          currentstate = state.waitingforpayback;

          start = now;
     }

     
     
     
     
     function waitingforpayback()payable onlyinstate(state.waitingforpayback){
          if(msg.value<safeadd(wanted_wei,premium_wei)){
               throw;
          }
          
          if(!lender.call.gas(2000000).value(msg.value)()){
               throw;
          }

          releasetoborrower(); 
          ledger.addreptokens(borrower,wanted_wei);
          currentstate = state.finished; 
     }

     
     function getneededsumbylender()constant returns(uint out){
          uint total = safeadd(wanted_wei,lenderfeeamount);
          out = total;
          return;
     }

     
     function getneededsumbyborrower()constant returns(uint out){
          uint total = safeadd(wanted_wei,premium_wei);
          out = total;
          return;
     }

     
     
     function requestdefault()onlyinstate(state.waitingforpayback){
          if(now < (start + days_to_lend * 1 days)){
               throw;
          }

          releasetolender(); 
          
          currentstate = state.default; 
     }

     function releasetolender(){
    
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               ens.setowner(ens_domain_hash,lender);

          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(lender,tokenbalance);
          }

          ledger.burnreptokens(borrower);
     }

     function releasetoborrower(){
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               ens.setowner(ens_domain_hash,borrower);
          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(borrower,tokenbalance);
          }
     }
}
