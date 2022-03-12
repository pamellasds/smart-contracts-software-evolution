pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
import ;
import ;

contract testtokensale {
  uint public initialbalance = 200 finney;

  address factory;

  throwproxy throwproxy;

  function beforeall() {
    factory = address(new minimetokenfactory());
  }

  function beforeeach() {
    throwproxy = new throwproxy(address(this));
  }

  function testhascorrectpriceforstages() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    assert.equal(sale.getprice(10), 3, );
    assert.equal(sale.getprice(13), 3, );
    assert.equal(sale.getprice(14), 3, );
    assert.equal(sale.getprice(15), 1, );
    assert.equal(sale.getprice(18), 1, );
    assert.equal(sale.getprice(19), 1, );

    assert.equal(sale.getprice(9), 0, );
    assert.equal(sale.getprice(20), 0, );
  }

  function testhascorrectpriceformultistage() {
    aragontokensalemock sale = new aragontokensalemock(10, 40, address(this), address(this), 5, 1, 3);
    assert.equal(sale.getprice(10), 5, );
    assert.equal(sale.getprice(19), 5, );
    assert.equal(sale.getprice(20), 3, );
    assert.equal(sale.getprice(25), 3, );
    assert.equal(sale.getprice(30), 1, );
    assert.equal(sale.getprice(39), 1, );

    assert.equal(sale.getprice(9), 0, );
    assert.equal(sale.getprice(41), 0, );
  }

  function testallocatestokensinsale() {
    multisigmock ms = new multisigmock();

    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    sale.setmockedblocknumber(12);
    assert.istrue(sale.proxypayment.value(25 finney)(address(this)), ); 

    sale.setmockedblocknumber(17);
    if (!sale.proxypayment.value(10 finney)(address(this))) throw; 

    assert.equal(erc20(sale.token()).balanceof(address(this)), 85 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 85 finney, );
    assert.equal(ms.balance, 35 finney, );
  }

  function testcannotgettokensinnotinitiatedsale() {
    testtokensale(throwproxy).throwswhengettingtokensinnotinitiatedsale();
    throwproxy.assertthrows();
  }

  function throwswhengettingtokensinnotinitiatedsale() {
    multisigmock ms = new multisigmock();

    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(this), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    

    sale.setmockedblocknumber(12);
    sale.proxypayment.value(50 finney)(address(this));
  }

  function testemergencystop() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    sale.setmockedblocknumber(12);
    assert.istrue(sale.proxypayment.value(15 finney)(address(this)), );
    assert.equal(erc20(sale.token()).balanceof(address(this)), 45 finney, );

    ms.emergencystopsale(address(sale));
    assert.istrue(sale.salestopped(), );

    ms.restartsale(sale);

    sale.setmockedblocknumber(16);
    assert.isfalse(sale.salestopped(), );
    assert.istrue(sale.proxypayment.value(1 finney)(address(this)), );
    assert.equal(erc20(sale.token()).balanceof(address(this)), 46 finney, );
  }

  function testcantbuytokensinstoppedsale() {
    testtokensale(throwproxy).throwswhengettingtokenswithstoppedsale();
    throwproxy.assertthrows();
  }

  function throwswhengettingtokenswithstoppedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);

    ms.emergencystopsale(address(sale));
    sale.proxypayment.value(20 finney)(address(this));
  }

  function testcantbuytokensinendedsale() {
    testtokensale(throwproxy).throwswhengettingtokenswithendedsale();
    throwproxy.assertthrows();
  }

  function throwswhengettingtokenswithendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(21);

    sale.proxypayment.value(20 finney)(address(this));
  }


  function testcantfinalizenotendedsale() {
    testtokensale(throwproxy).throwswhenfinalizingnotendedsale();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingnotendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(19);
    ms.finalizesale(sale);
  }

  function testcantfinalizeifnotmultisig() {
    testtokensale(throwproxy).throwswhenfinalizingifnotmultisig();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingifnotmultisig() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(30);
    sale.finalizesale();
  }

  function testcanfinalizeendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(14 finney)(address(this));

    assert.equal(erc20(sale.token()).balanceof(address(this)), 70 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 70 finney, );

    sale.setmockedblocknumber(21);
    ms.finalizesale(sale);

    assert.equal(erc20(sale.token()).balanceof(address(ms)), 30 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 100 finney, );
  }

  function testtokensarelockedduringsale() {
    testtokensale(throwproxy).throwswhentransferingduringsale();
    throwproxy.assertthrows();
  }

  function throwswhentransferingduringsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(15 finney)(address(this));

    erc20(sale.token()).transfer(0x1, 10 finney);
  }

  function testtokensaretransferrableaftersale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    assert.equal(ant(sale.token()).controller(), address(sale), );

    sale.setmockedblocknumber(12);
    sale.proxypayment.value(15 finney)(address(this));
    sale.setmockedblocknumber(22);
    ms.finalizesale(sale);

    assert.equal(ant(sale.token()).controller(), sale.networkplaceholder(), );

    erc20(sale.token()).transfer(0x1, 10 finney);
    assert.equal(erc20(sale.token()).balanceof(0x1), 10 finney, );
  }

  function testnetworkdeployment() {
    multisigmock devmultisig = new multisigmock();
    multisigmock communitymultisig = new multisigmock();

    aragontokensalemock sale = new aragontokensalemock(10, 20, address(devmultisig), address(communitymultisig), 3, 1, 2);
    devmultisig.deployandsetant(sale);
    devmultisig.activatesale(sale);
    communitymultisig.activatesale(sale);

    assert.equal(ant(sale.token()).controller(), address(sale), );
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(15 finney)(address(this));
    sale.setmockedblocknumber(22);
    devmultisig.finalizesale(sale);

    assert.equal(ant(sale.token()).controller(), sale.networkplaceholder(), );

    dotransfer(sale.token());

    communitymultisig.deploynetwork(sale, new networkmock());

    testtokensale(throwproxy).dotransfer(sale.token());
    throwproxy.assertthrows();
  }

  function dotransfer(address token) {
    erc20(token).transfer(0x1, 10 finney);
  }
}
