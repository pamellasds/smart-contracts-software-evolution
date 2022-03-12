pragma solidity ^0.4.8;

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

  function testcreatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x2, 2, 1, 2);

    assert.isfalse(sale.isactivated(), );
    assert.equal(sale.totalcollected(), 0, );
  }

  function testcantinitiateincorrectsale() {
    testtokensale(throwproxy).throwifstartpastblocktime();
    throwproxy.assertthrows();
  }

  function throwifstartpastblocktime() {
    new aragontokensalemock(0, 20, 0x1, 0x2, 2, 1, 2);
  }

  function testactivatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    sale.deployant(factory, true);
    sale.activatesale();
    assert.istrue(sale.isactivated(), );
  }

  function testcannotactivatebeforedeployingant() {
    testtokensale(throwproxy).throwswhenactivatingbeforedeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenactivatingbeforedeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    sale.activatesale();
  }

  function testcannotredeployant() {
    testtokensale(throwproxy).throwswhenredeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenredeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    sale.deployant(factory, true);
    sale.deployant(factory, true);
  }

  function testonlymultisigcandeployant() {
    testtokensale(throwproxy).throwswhennonmultisigdeploysant();
    throwproxy.assertthrows();
  }

  function throwswhennonmultisigdeploysant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x3, 2, 1, 2);
    sale.deployant(factory, true);
  }

  function testsetpresaletokens() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), 0x2, 2, 1, 2);
    sale.deployant(factory, true);
    sale.allocatepresaletokens(0x1, 100);
    sale.allocatepresaletokens(0x2, 30);
    sale.allocatepresaletokens(address(this), 20);
    assert.equal(erc20(sale.token()).balanceof(0x1), 100, );
    assert.equal(erc20(sale.token()).totalsupply(), 150, );
  }

  function testcannotsetpresaletokensafteractivation() {
    testtokensale(throwproxy).throwifsetpresaletokensafteractivation();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensafteractivation() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    sale.deployant(factory, true);
    sale.activatesale(); 
    sale.allocatepresaletokens(0x1, 100);
  }

  function testcannotsetpresaletokensaftersalestarts() {
    testtokensale(throwproxy).throwifsetpresaletokensaftersalestarts();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensaftersalestarts() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    sale.deployant(factory, true);
    sale.setmockedblocknumber(13);
    sale.allocatepresaletokens(0x1, 100);
  }

  function testhascorrectpriceforstages() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 2, 1, 2);
    assert.equal(sale.getprice(10), 2, );
    assert.equal(sale.getprice(13), 2, );
    assert.equal(sale.getprice(14), 2, );
    assert.equal(sale.getprice(15), 1, );
    assert.equal(sale.getprice(18), 1, );
    assert.equal(sale.getprice(19), 1, );

    assert.equal(sale.getprice(9), 0, );
    assert.equal(sale.getprice(20), 0, );
  }

  function testhascorrectpriceformultistage() {
    aragontokensalemock sale = new aragontokensalemock(10, 40, address(this), address(this), 3, 1, 3);
    assert.equal(sale.getprice(10), 3, );
    assert.equal(sale.getprice(19), 3, );
    assert.equal(sale.getprice(20), 2, );
    assert.equal(sale.getprice(25), 2, );
    assert.equal(sale.getprice(30), 1, );
    assert.equal(sale.getprice(39), 1, );

    assert.equal(sale.getprice(9), 0, );
    assert.equal(sale.getprice(41), 0, );
  }

  function testallocatestokensinsale() {
    multisigmock ms = new multisigmock();

    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);

    sale.setmockedblocknumber(12);
    assert.istrue(sale.proxypayment.value(25 finney)(address(this)), ); 

    sale.setmockedblocknumber(17);
    if (!sale.proxypayment.value(10 finney)(address(this))) throw; 

    assert.equal(erc20(sale.token()).balanceof(address(this)), 60 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 60 finney, );
    assert.equal(ms.balance, 35 finney, );
  }

  function testcannotgettokensinnotinitiatedsale() {
    testtokensale(throwproxy).throwswhengettingtokensinnotinitiatedsale();
    throwproxy.assertthrows();
  }

  function throwswhengettingtokensinnotinitiatedsale() {
    multisigmock ms = new multisigmock();

    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(this), 2, 1, 2);
    ms.activatesale(sale, factory);
    

    sale.setmockedblocknumber(12);
    sale.proxypayment.value(50 finney)(address(this));
  }

  function testemergencystop() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);

    sale.setmockedblocknumber(12);
    assert.istrue(sale.proxypayment.value(15 finney)(address(this)), );
    assert.equal(erc20(sale.token()).balanceof(address(this)), 30 finney, );

    ms.emergencystopsale(address(sale));
    assert.istrue(sale.salestopped(), );

    ms.restartsale(sale);

    sale.setmockedblocknumber(16);
    assert.isfalse(sale.salestopped(), );
    assert.istrue(sale.proxypayment.value(1 finney)(address(this)), );
    assert.equal(erc20(sale.token()).balanceof(address(this)), 31 finney, );
  }

  function testcantbuytokensinstoppedsale() {
    testtokensale(throwproxy).throwswhengettingtokenswithstoppedsale();
    throwproxy.assertthrows();
  }

  function throwswhengettingtokenswithstoppedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);
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
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);
    sale.setmockedblocknumber(21);

    sale.proxypayment.value(20 finney)(address(this));
  }

  function testcantfinalizenotendedsale() {
    testtokensale(throwproxy).throwswhenfinalizingnotendedsale();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingnotendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);
    sale.setmockedblocknumber(19);
    ms.finalizesale(sale);
  }

  function testcantfinalizeifnotmultisig() {
    testtokensale(throwproxy).throwswhenfinalizingifnotmultisig();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingifnotmultisig() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);
    sale.setmockedblocknumber(30);
    sale.finalizesale();
  }

  function testcanfinalizeendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 2, 1, 2);
    ms.activatesale(sale, factory);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(15 finney)(address(this));

    assert.equal(erc20(sale.token()).balanceof(address(this)), 30 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 30 finney, );

    sale.setmockedblocknumber(21);
    ms.finalizesale(sale);

    assert.equal(erc20(sale.token()).balanceof(address(ms)), 10 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 40 finney, );
  }
}
